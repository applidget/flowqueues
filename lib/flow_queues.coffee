log = require("util").log
TaskPerformer = require("./task_performer").TaskPerformer
util = require("util")

#TODO: integrate notions of queues
class FlowQueues
  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @firstTaskName = null
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = []
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc

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
        try
          job = JSON.parse(res)
        catch
          #TODO: why is that ?
          console.log "PARSING ERROR #{util.inspect(util.inspect(res))}"
      cbs(job)

  jobsDir:() ->
    return @overridenJobDir || process.cwd()


  pendingTasksCount: (taskName, cbs) ->
    @dataSource.llen @pendingQueueNameForTaskName(taskName), (err, res) =>
      cbs(res)
  baseKeyName: ->
    return "flowqueues"
          
  pendingQueueNameForTaskName: (taskName) ->
    return "#{@baseKeyName()}:#{taskName}:pending"

  enqueueForTask:(taskName, job, cbs = null) ->
    encodedJob = JSON.stringify(job)
    @dataSource.rpush @pendingQueueNameForTaskName(taskName), encodedJob , (err, _) =>
      if cbs?
        cbs(err)
  
  enqueue:(job, cbs = null) ->
    taskDesc = @taskDescriptions[@firstTaskName]
    @enqueueForTask(taskDesc.name, job, cbs)
    
  performTaskOnJob: (job, taskDescription, callback) ->
    #TODO: check if task is modified here. It should be
    TaskPerformer.performTask @jobsDir(), taskDescription, job, (status) =>
      nextTaskNameDescription = taskDescription.getNextTaskDescription(status)
      #TODO:(1) terminate job is nothing after this task
      #TODO: (3) swap the following two lines and see how it affects performance
      console.log "Done !"
      if !nextTaskNameDescription?
        callback()
      else
        @enqueueForTask nextTaskNameDescription.name, job, () =>
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
        #TODO: #architecture decide wether we should be able to enqueue stuff directly on intermediate task
        if taskName == @firstTaskName
          @timeOuts[taskName] = setTimeout(leCallback, @timeoutInterval)
      
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