log = require("util").log
TaskPerformer = require("./task_performer").TaskPerformer
Sequencer = require("./sequencer").Sequencer
util = require("util")
async = require "async"
os = require "os"

class FlowQueues
  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @firstTaskName = null
    @working = false
    @timeoutInterval ||= 5000
    @timeOuts = {}
    @queues = ["critical", "main", "low"]
    #TODO: handle this the redis way
    @sequencer = new Sequencer()
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc
    
  hostname:() ->
    return os.hostname()

  setFirstTaskDescription: (fistTaskName) ->
    @firstTaskName = fistTaskName
    
  @createWorker: (dataSource)  =>
    return new FlowQueues(dataSource)
  
  encode: (hash) ->
    return JSON.stringify(hash)
    
  decode: (json) ->
    res = null
    try
      res = JSON.parse(json)
    catch
      #TODO: why is that ?
      log "PARSING ERROR: #{util.inspect(util.inspect(json))}"
    return res
  
  reserveJobOnQueue:(taskName, queue, cbs) ->
    @dataSource.lpop @pendingQueueNameForTaskName(taskName, queue), (err, res) =>
      job = @decode(res)
      cbs(job)
      
  reserveJob: (taskName, foundJobCbs, queue) ->
    queueIndex = 0
    foundJob = null
    #This is an async implementation of a break in a for loop using the "async" framework
    #This determines if we should go for the next queue
    test = () =>
      return !foundJob? && queueIndex < @queues.length

    #Happens when job has been found or all queues are empty
    finalStep = (err) =>
      foundJobCbs(foundJob, @queues[queueIndex])
    
    block = (cbs) =>
      @reserveJobOnQueue taskName, @queues[queueIndex], (job) =>
        if job?
          foundJob = job
        else
          queueIndex += 1
        cbs()
        
    async.whilst test, block, finalStep
    
  jobsDir:() ->
    return @overridenJobDir || process.cwd()

  pendingTasksCount: (taskName, cbs) ->
    @dataSource.llen @pendingQueueNameForTaskName(taskName), (err, res) =>
      cbs(res)

  baseKeyName: ->
    return "flowqueues"
  
  baseQueueNameForTask:(taskName, ignoreHost = false) ->
    interFix = "#{@hostname()}:"
    if ignoreHost == true
      interFix = ""
    return "#{@baseKeyName()}:#{interFix}#{taskName}"
          
  pendingQueueNameForTaskName: (taskName, queue) ->
    ignoreHostName = (taskName == @firstTaskName)
    return "#{@baseQueueNameForTask(taskName, ignoreHostName)}:#{queue}:pending"

  workingSetNameForTaskName:(taskName) ->
    return "#{@baseQueueNameForTask(taskName)}:working"

  workingCountForTaskName:(taskName, cbs) ->
    @dataSource.llen @workingSetNameForTaskName(taskName), (err, length) =>
      cbs(length)

  isWorkerAvailableForTaskName:(taskName, previouslyRemaining, cbs) ->
    @workingCountForTaskName taskName, (count) =>
      taskDescription = @taskDescriptions[taskName]
      status = false
      if count < taskDescription.maxParallelInstances
        status = true
      cbs(status, taskDescription.maxParallelInstances - count)
    
  enqueueForTask:(taskName, job, queue, cbs = null) ->
    encodedJob = @encode(job)
    @dataSource.rpush @pendingQueueNameForTaskName(taskName, queue), encodedJob , (err, _) =>
      if cbs?
        cbs(err)
  
  enqueue:(job, cbs = null) ->
    queue = "main"
    if  @queues.length > 0 
      queue = @queues[0]
    @enqueueTo job, queue, cbs
    
  enqueueTo: (job, queue, cbs = null) ->
    taskDesc = @taskDescriptions[@firstTaskName]
    @enqueueForTask(taskDesc.name, job, queue, cbs)

  registerJobInProgress:(job, taskName, cbs) ->
    #TODO: the encoded data should be already available
    data = @encode(cbs)
    @dataSource.rpush @workingSetNameForTaskName(taskName), data, (err, _) =>
      cbs(err)

  unregisterJobInProgress:(job, taskName, cbs = null) ->
    data = @encode(cbs)
    key = @workingSetNameForTaskName(taskName)
    @dataSource.lrem key, 1, data, (err, _) =>
      if cbs?
        cbs(err)
    
  performTaskOnJob: (job, taskDescription, queue, next,  callback) ->
    #TODO: check if task is modified here. It should be !
    #TODO: register task as running in redis here
    @registerJobInProgress job, taskDescription.name, (err) =>      
      process.nextTick () =>
        TaskPerformer.performTask @jobsDir(), taskDescription, job, (status) =>
          @sequencer.scheduleInvocation (done) =>
            @unregisterJobInProgress job, taskDescription.name, (err) =>
              done()
              nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
              log "Done #{taskDescription.name}!"
              if !nextTaskNameDescription?
                callback()
              else
                @enqueueForTask nextTaskNameDescription.name, job, queue, () =>
                  #TODO: try swaping the two lines. Depth First vs Breadth First execution
                  @processTaskForName nextTaskNameDescription.name
                  callback()
      next()
      
  processTaskForName: (taskName, previouslyRemaining = 0) ->   
    @sequencer.scheduleInvocation (next) =>
      if @timeOuts[taskName]? 
        clearTimeout(@timeOuts[taskName])
        @timeOuts[taskName] = null

      leCallback = (nowRemaining = 0) =>
        @processTaskForName(taskName, nowRemaining)    
    
      schedulePolling =  () =>
        if taskName == @firstTaskName
          @timeOuts[taskName] = setTimeout(leCallback, @timeoutInterval)
        
      @isWorkerAvailableForTaskName taskName, previouslyRemaining, (isAvailable, howMany) =>
        if !isAvailable
          next()
          return
        taskDescription = @taskDescriptions[taskName]
        @reserveJob taskName, (foundJob, queue) =>
          if foundJob?
            log "Got #{taskName} #{util.inspect foundJob}"
            if howMany > 1
              leCallback(howMany - 1)
            @performTaskOnJob(foundJob, taskDescription, queue, next, leCallback)
          else
            next()
            schedulePolling()
    
  stop: () ->
    for key, to in @timeOuts
      do (key, to) ->
        clearTimeout(to)
        
  unregisterWorkingJobsForTask: (taskName, cbs) ->
    @dataSource.del @workingSetNameForTaskName(taskName), (err, _) ->
      cbs()
      
  work: () ->
    if @working == true
      log "Warning: Already working"
      return
    @working = true
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @unregisterWorkingJobsForTask name, () =>
          @processTaskForName(name)

exports.FlowQueues = FlowQueues