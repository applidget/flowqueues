log = require("util").log
TaskPerformer = require("./task_performer").TaskPerformer

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
  
  reserveJob:(taskName, cbs) ->
    #TODO: implement fetching from redis here
    @dataSource.lpop @pendingQueueNameForTaskName(taskName), (err, res) =>
      job = null
      if res?
        #TODO: store the fact that we are working on a job here. Probably a SET, but this requires generating job ids 
        job = JSON.parse(res)
      cbs(job)

  jobsDir:() ->
    return @overridenJobDir || process.cwd()

  baseKeyName: ->
    return "flowqueues"
    
  pendingQueueNameForTaskName: (taskName) ->
    return "#{@baseKeyName()}:#{taskName}:pending"

  enqueueForTask:(taskName, job, cbs = null) ->
    @dataSource.rpush @pendingQueueNameForTaskName(taskName), job, (err, res) =>
      if cbs?
        #TODO: do something with the results ...
        cbs()
  
  enqueue:(job, cbs = null) ->
    taskDesc = @taskDescriptions[@firstTaskName]
    encodedJob = JSON.stringify(job)
    @enqueueForTask(taskDesc.name, encodedJob, cbs)
    
  performTaskOnJob: (task, taskDescription, callback) ->
    log "performing task #{task}"
    #TODO: check if task is modified here. It should be
    TaskPerformer.performTask @jobsDir(), taskDescription, task, (status) ->
      nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
      #TODO:(2) terminate job is nothing after this task
      #TODO:(1) enqueue to next task here. Not sure processTaskForName should be called here
      #TODO: (3) swap the following two lines and see how it affects performance
      @enqueueForTask(nextTaskNameDescription.name, encodedJob, cbs)      
      @processTaskForName nextTaskNameDescription.name
      callback()

  processTaskForName: (taskName) ->
    if @timeOuts[taskName]? 
      clearTimeout(@timeOuts[taskName])
      @timeOuts[taskName] = null
      
    #Encapsulating the taskName here thanks to js closures. swag
    leCallback = () =>
      @processTaskForName(taskName)

    log "Searching for task #{taskName}"
    @reserveJob taskName, (job) =>      
      if job?
        log "Found #{taskName}"
        taskDescription = @taskDescriptions[taskName]
        @performTaskOnJob(job, taskDescription, leCallback)
      else
        log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
        @timeOuts[taskName] = setTimeout(leCallback, @timeoutInterval)
      
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