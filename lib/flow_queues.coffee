log = require("util").log

class FlowQueues
  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = []
    
  addTaskDescription: (name, taskDesc) ->
    @taskDescriptions[name] = taskDesc
  
  @createWorker: ()  =>
    return new FlowQueues()
  
  reserveTask:(taskName) ->
    return null

  jobsDir:() ->
    return @jobsDir || process.cwd()
    
  performTask: (task, callback) ->
    log "performing task #{task}"
    #TODO
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
      @performTask(task, callback)
    else
      log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
      @timeOuts[taskName] = setTimeout(callback, @timeoutInterval)
      
  work: () ->
    if @working == true
      log "Warning: Already working"
      return
    for name, taskDescription of @taskDescriptions
      do (name, taskDescription) =>
        @processTaskForName(name)

exports.FlowQueues = FlowQueues