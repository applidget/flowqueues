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
    @timeoutInterval ||= 5000
    @timeOuts = {}
    @queues = ["fourth", "fifth", "critical", "main", "low"]
    #TODO: handle this the redis way
    @lockedForSearch = {}
    @nbWorkingTasksByName = {}
    @lockedCountForTaskName = {}
    
    @backendRequestBusy = false
    @backendRequestsQueue = []
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc

  scheduleBackendRequest: (request) ->
    @backendRequestsQueue.push request
    if @backendRequestBusy == false
      @processBackendRequest()

  processBackendRequest:() ->
    if @backendRequestsQueue.length == 0
      return
    request = @backendRequestsQueue.shift()
    @backendRequestBusy = true
    request () =>
      @backendRequestBusy = false
      @processBackendRequest()
  
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
      @unlockTaskName(taskName)
      foundJobCbs(foundJob, @queues[queueIndex])
    
    block = (cbs) =>
      @reserveJobOnQueue taskName, @queues[queueIndex], (job) =>
        if job?
          foundJob = job
        else
          queueIndex += 1
        cbs()
        
  
    @lockTaskName(taskName)
    async.whilst test, block, finalStep
    
  jobsDir:() ->
    return @overridenJobDir || process.cwd()

  pendingTasksCount: (taskName, cbs) ->
    @dataSource.llen @pendingQueueNameForTaskName(taskName), (err, res) =>
      cbs(res)

  baseKeyName: ->
    return "flowqueues"
  
  #TODO: at least the first queue in the workflow must be hostname independant 
  baseQueueNameForTask:(taskName) ->
    return "#{@baseKeyName()}:#{@hostname()}:#{taskName}"
          
  pendingQueueNameForTaskName: (taskName, queue) ->
    return "#{@baseQueueNameForTask(taskName)}:#{queue}:pending"

  workingSetNameForTaskName:(taskName) ->
    return "#{@baseQueueNameForTask(taskName)}:working"

  workingCountForTaskName:(taskName, cbs) ->
    @dataSource.llen @workingSetNameForTaskName(taskName), (err, length) =>
      cbs(length)

  isWorkerAvailableForTaskName:(taskName, previouslyRemaining, cbs) ->
    if previouslyRemaining > 0
      cbs(true, previouslyRemaining)
    if @isTaskNameLocked(taskName) == true
      cbs(false, 0)
      return      
    @lockTaskName(taskName)
    @workingCountForTaskName taskName, (count) =>
      taskDescription = @taskDescriptions[taskName]
      status = false
      if count < taskDescription.maxParallelInstances
        status = true
      @unlockTaskName(taskName)
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
    @lockTaskName(taskName)
    data = @encode(cbs)
    key = @workingSetNameForTaskName(taskName)
    @dataSource.lrem key, 0, data, (err, _) =>
      @unlockTaskName(taskName)
      if cbs?
        cbs(err)
  
  lockTaskName: (taskName) ->
    @lockedCountForTaskName[taskName] ||= 0
    @lockedCountForTaskName[taskName] += 1
    #log " ----------> Task #{taskName} lock closed (#{@lockedCountForTaskName[taskName]})"
    @lockedForSearch[taskName] = true

  unlockTaskName: (taskName) ->
    @lockedCountForTaskName[taskName] ||= 0
    @lockedCountForTaskName[taskName] -= 1
    #log "------------------> Task #{taskName} lock open (#{@lockedCountForTaskName[taskName]})"
    # if @lockedCountForTaskName[taskName] > 0
#       log " !!!!!!!!!!!!!!!!!!! Task #{taskName} still locked (#{@lockedCountForTaskName[taskName]})"
    @lockedForSearch[taskName] = false
  
  isTaskNameLocked: (taskName) ->
    @lockedCountForTaskName[taskName] ||= 0
    return @lockedCountForTaskName[taskName] > 0
    
  performTaskOnJob: (job, taskDescription, queue, next,  callback) ->
    #TODO: check if task is modified here. It should be !
    #TODO: register task as running in redis here
    @nbWorkingTasksByName[taskDescription.name] ||= 0
    @nbWorkingTasksByName[taskDescription.name] += 1
    @lockTaskName(taskDescription.name)
    @registerJobInProgress job, taskDescription.name, (err) =>      
      @unlockTaskName(taskDescription.name)
      #TODO: next tick
      #Redis has taken over on the lock ...
      next()
      TaskPerformer.performTask @jobsDir(), taskDescription, job, (status) =>
        @scheduleBackendRequest (done) =>
          @unregisterJobInProgress job, taskDescription.name, (err) =>
            done()
            @nbWorkingTasksByName[taskDescription.name] -= 1
            nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
            log "Done #{taskDescription.name}!"
            if !nextTaskNameDescription?
              callback()
            else
              @enqueueForTask nextTaskNameDescription.name, job, queue, () =>
                @processTaskForName nextTaskNameDescription.name
                callback()
  
  processTaskForName: (taskName, previouslyRemaining = 0) ->
    @scheduleBackendRequest (next) =>
      log "Process"
      #Why Are we here ? 
      #1. Timeout fired
      #2. Task Completed
      if @timeOuts[taskName]? 
        clearTimeout(@timeOuts[taskName])
        @timeOuts[taskName] = null

      leCallback = (nowRemaining = 0) =>
        @processTaskForName(taskName, nowRemaining)    
    
      schedulePolling =  () =>
        if taskName == @firstTaskName
          #log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
          @timeOuts[taskName] = setTimeout(leCallback, @timeoutInterval)
        
      #TODO: handle this in a smarter way
      @isWorkerAvailableForTaskName taskName, previouslyRemaining, (isAvailable, howMany) =>
        if !isAvailable
          #log "!!!!!!!!!!!!! Task #{taskName}  locked !"
          #schedulePolling(taskName)
          next()
          return
        taskDescription = @taskDescriptions[taskName]
        #log "Task #{taskName} not locked"
        @reserveJob taskName, (foundJob, queue) =>
          #TODO the issue here is that the number of remaining slots is no longer true
          if foundJob?
            log "Got #{taskName} (#{howMany})"
            #will be unlocked later (after being registered)
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
      
  work: () ->
    if @working == true
      log "Warning: Already working"
      return
    
    @working = true
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @processTaskForName(name)

exports.FlowQueues = FlowQueues