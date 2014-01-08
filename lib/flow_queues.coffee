log = require("util").log

class FlowQueues
  constructor: (@workflowName) ->
    @taskDescriptions = []
    @working = false
    @timeoutInterval ||= 500
    @timeOuts = {}
    @queues = []
    
    #TODO: testing, remove this later
    @remainingTasks = 500
  addTaskDescription: (taskDesc) ->
    @taskDescriptions.push taskDesc
  
  @createWorker: ()  =>
    return new FlowQueues()
  
  reserveTask:(taskName) ->
    if @remainingTasks > 0
      @remainingTasks -= 1
      return "Hello"
    return null
    
    
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
    for taskDescription in @taskDescriptions
      do (taskDescription) =>
        @processTaskForName(taskDescription)
          
    
    
  

exports.FlowQueues = FlowQueues