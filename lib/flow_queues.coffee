class FlowQueues
  constructor: () ->
    @taskDescriptions = []
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions.push taskDesc
  
  @createWorker: ()  =>
    return new FlowQueues()
  

exports.FlowQueues = FlowQueues