log = require("util").log
TaskPerformer = require("./task_performer").TaskPerformer
util = require("util")
async = require "async"
os = require "os"

class FlowQueues
  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @firstTaskName = null
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = ["critical", "main", "low"]
    #TODO: handle this the redis way
    @lockedForSearch = {}
    
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
  
  reserveJob:(taskName, queue, cbs) ->
    @dataSource.lpop @pendingQueueNameForTaskName(taskName, queue), (err, res) =>
      job = @decode(res)
      cbs(job)

  jobsDir:() ->
    return @overridenJobDir || process.cwd()

  pendingTasksCount: (taskName, cbs) ->
    @dataSource.llen @pendingQueueNameForTaskName(taskName), (err, res) =>
      cbs(res)

  baseKeyName: ->
    return "flowqueues"
  
  baseQueueNameForTask:(taskName) ->
    return "#{@baseKeyName()}:#{@hostname()}:#{taskName}"
          
  pendingQueueNameForTaskName: (taskName, queue) ->
    return "#{@baseQueueNameForTask(taskName)}:#{queue}:pending"

  workingSetNameForTaskName:(taskName) ->
    return "#{@baseQueueNameForTask()}:working"

  workingCountForTaskName:(taskName, cbs) ->
    #TODO replug this later on
    cbs(0)
    # @dataSource.llen @workingSetNameForTaskName(taskName), (err, length) =>
    #   cbs(length)

  isWorkerAvailableForTaskName:(taskName, cbs) ->
    if @lockedForSearch[taskName] == true
      cbs(false)
      return      
    @lockedForSearch[taskName] = true
    @workingCountForTaskName taskName, (count) =>
      taskDescription = @taskDescriptions[taskName]
      status = false
      if count < taskDescription.maxParallelInstances
        status = true
      @lockedForSearch[taskName] = false
      cbs(status)
    
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

    cbs(null)
    # #TODO: the encoded data should be already available
    # data = @encode(cbs)
    # @dataSource.rpush @workingSetNameForTaskName(taskName), data, (err, _) =>
    #   cbs(err)

  unregisterJobInProgress:(job, taskName, cbs = null) ->
    #TODO: replug this later on
    cbs(null)
    # 
    # data = @encode(cbs)
    # key = @workingSetNameForTaskName(taskName)
    # @dataSource.lrem key, 0, data, (err, _) =>
    #   if cbs?
    #     cbs(err)
      
  performTaskOnJob: (job, taskDescription, queue, callback) ->
    #@lockedForSearch[taskDescription.name] = true

    #TODO: check if task is modified here. It should be !
    #TODO: register task as running in redis here
    @registerJobInProgress job, taskDescription.name, (err) =>      
      #Redis has taken over on the lock ...
      TaskPerformer.performTask @jobsDir(), taskDescription, job, (status) =>
        #@lockedForSearch[taskDescription.name] = false
        @unregisterJobInProgress job, taskDescription.name, (err) =>
          nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
          log "Done #{taskDescription.name}!"
          if !nextTaskNameDescription?
            callback()
          else
            @enqueueForTask nextTaskNameDescription.name, job, queue, () =>
              @processTaskForName nextTaskNameDescription.name
              callback()

  processTaskForName: (taskName) ->
    if @timeOuts[taskName]? 
      clearTimeout(@timeOuts[taskName])
      @timeOuts[taskName] = null
    
    #TODO: handle this in a smarter way
    @isWorkerAvailableForTaskName taskName, (isAvailable) =>
      if !isAvailable
        log "Task #{taskName}  locked !"
        return

      taskDescription = @taskDescriptions[taskName]
      log "Task #{taskName} not locked"
      #TODO: the following will be asynchronous later

      #Encapsulating the taskName here thanks to js closures. swag
      leCallback = () =>
        @processTaskForName(taskName)

      queueIndex = 0
      foundJob = null
      #This is an async implementation of a break in a for loop using the "async" framework
      #This determines if we should go for the next queue
      test = () =>
        return !foundJob? && queueIndex < @queues.length
    
      #Happens when job has been found or all queues are empty
      finalStep = (err) =>
        @lockedForSearch[taskName] = false
        if foundJob?
          log "Got #{taskName}"
          @performTaskOnJob(foundJob, taskDescription, @queues[queueIndex], leCallback)
        else
          if taskName == @firstTaskName
            #log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
            @timeOuts[taskName] = setTimeout(leCallback, @timeoutInterval)
        
      block = (cbs) =>
        @reserveJob taskName, @queues[queueIndex], (job) =>
          if job?
            foundJob = job
          else
            queueIndex += 1
          cbs()
      async.whilst test, block, finalStep
    
  stop: () ->
    for key, to in @timeOuts
      do (key, to) ->
        clearTimeout(to)
      
  work: () ->
    console.log "start working"
    if @working == true
      log "Warning: Already working"
      return

    @working = true
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @processTaskForName(name)

exports.FlowQueues = FlowQueues