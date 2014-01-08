log = require("util").log

class FlowQueues
  constructor: (@workflowName) ->
    @taskDescriptions = []
    @working = false
    @timeoutInterval ||= 5000
    @timeOuts = {}
    @queues = []
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions.push taskDesc
  
  @createWorker: ()  =>
    return new FlowQueues()
  
  reserveTask:(taskName) ->
    #TODO
    return null
    
  performTask: (task, callback) ->
    log "performing task #{taskName}"
    #TODO
    callback()
    
  processTaskForName: (taskName) ->
    callback = () ->
      #closures are so magical ...
      processTaskForName(taskName)
    log "Searching for task #{taskName}"
    task = @reserveTask(taskName)
    
    if task?
      @performTask(task, callback)
    else
      log "Will search again for task #{taskName} in #{@timeoutInterval} milliseconds"
      #TODO: do something is a timeOut is already registered here
      @timeOuts[taskName] = setTimeout(callback, @timeoutInterval)
      
  work: () ->
    if @working == true
      #TODO: output some warning here
      return
    for taskDescription in @taskDescriptions
      do (taskDescription) =>
        @processTaskForName(taskDescription)
          
            
    
  #coffeescript syntax makes is difficult with the regular syntax :)
  reversedTimeout = (time, cbs) ->
    return setTimeout(cbs, time)
  
    
    
    
  

exports.FlowQueues = FlowQueues