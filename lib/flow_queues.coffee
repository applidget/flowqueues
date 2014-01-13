log = require("util").log
TaskPerformer = require("./task_performer").TaskPerformer
util = require("util")
async = require "async"
os = require "os"

#TODO: integrate notions of queues
class FlowQueues
  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @firstTaskName = null
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = ["critical", "main", "low"]
    #TODO: handle this the redis way
    @processing = {}
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc

  hostname:() ->
    return os.hostname()

  setFirstTaskDescription: (fistTaskName) ->
    @firstTaskName = fistTaskName
    
  @createWorker: (dataSource)  =>
    return new FlowQueues(dataSource)
  
  reserveJob:(taskName, queue, cbs) ->
    #TODO: implement fetching from redis here
    @dataSource.lpop @pendingQueueNameForTaskName(taskName, queue), (err, res) =>
      job = null
      if res?
        #TODO: store the fact that we are working on a job here. Probably a SET, but this requires generating job ids 
        try
          job = JSON.parse(res)
        catch
          #TODO: why is that ?
          log "PARSING ERROR: #{util.inspect(util.inspect(res))}"
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

  enqueueForTask:(taskName, job, queue, cbs = null) ->
    encodedJob = JSON.stringify(job)
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
    
  performTaskOnJob: (job, taskDescription, queue, callback) ->
    @processing[taskDescription.name] = true
    #TODO: check if task is modified here. It should be
    TaskPerformer.performTask @jobsDir(), taskDescription, job, (status) =>
      @processing[taskDescription.name] = false
      nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
      #TODO:(1) terminate job is nothing after this task
      #TODO: (3) swap the following two lines and see how it affects performance
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
    if @processing[taskName] == true
      return

    # #TODO: the following will be asynchronous later
    @processing[taskName] = true

    #Encapsulating the taskName here thanks to js closures. swag
    leCallback = () =>
      @processTaskForName(taskName)

    queueIndex = 0
    foundJob = null
    #This is an async implementation of a break in a for loop using the "async" framework
    #Will determine if we should go for the next queue
    test = () =>
      return !foundJob? && queueIndex < @queues.length
    
    #Happens when job has been found or all queues are empty
    finalStep = (err) =>
      if foundJob?
        log "Got #{taskName}"
        taskDescription = @taskDescriptions[taskName]
        @performTaskOnJob(foundJob, taskDescription, @queues[queueIndex], leCallback)
      else
        @processing[taskName] = false
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
    if @working == true
      log "Warning: Already working"
      return

    @working = true
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @processTaskForName(name)

exports.FlowQueues = FlowQueues