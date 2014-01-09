log = require("util").log

#TODO: integrate notions of queues
class FlowQueues
  constructor: (@dataSource) ->
    log @dataSource
    @taskDescriptions = {}
    @firstTaskName = null
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = []
    
  addTaskDescription: (name, taskDesc) ->
    @taskDescriptions[name] = taskDesc

  setFirstTaskDescription: (fistTaskName) ->
    @firstTaskName = fistTaskName
    
  @createWorker: (dataSource)  =>
    return new FlowQueues(dataSource)
  
  reserveTask:(taskName) ->
    #TODO: implement fetching from redis here
    return null

  jobsDir:() ->
    return @jobsDir || process.cwd()

  baseKeyName: ->
    return "flowqueues"
    
  pendingQueueNameForTaskName: (taskName) ->
    return "#{@baseKeyName()}:#{taskName}:pending"

  enqueue:(job, cbs = null) ->
    taskDesc = @taskDescriptions[@firstTaskName]
    encodedJob = JSON.stringify(job)
    @dataSource.rpush @pendingQueueNameForTaskName(taskDesc.name), encodedJob, (err, res) =>
      if cbs?
        #TODO: do something with the results ...
        cbs()
    
  performTask: (task, taskDescription, callback) ->
    log "performing task #{task}"
    TaskPerformer.performTask @jobsDir, taskDescription, task, (status) ->
      nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
      #TODO:(2) terminate job is nothing after this task
      #TODO:(1) enqueue to next task here. Not sure processTaskForName should be called here
      #TODO: (3) swap the following two lines and see how it affects performance
      @processTaskForName nextTaskNameDescription.name
      callback()

  processTaskForName: (taskName) ->
    if @timeOuts[taskName]? 
      clearTimeout(@timeOuts[taskName])
      @timeOuts[taskName] = null
      
    #Encapsulating the taskName here thanks to js closures. swag
    callback = () =>
      @processTaskForName(taskName)

    log "Searching for task #{taskName}"
    task = @reserveTask(taskName)
    if task?
      taskDescription = @taskDescriptions[taskName]
      @performTask(task, taskDescription, callback)
    else
      log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
      @timeOuts[taskName] = setTimeout(callback, @timeoutInterval)
      
  stop: () ->
    for key, to in @timeOuts
      do (key, to) ->
        clearTimeout(to)
      
  work: () ->
    if @working == true
      log "Warning: Already working"
      return
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @processTaskForName(name)

exports.FlowQueues = FlowQueues