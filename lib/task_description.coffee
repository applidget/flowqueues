class TaskDescription

  constructor: (@name, @nextDictionary = {}, @maxParallelInstances = 1, @timeout = null) -> {}

  #returnCode is a string is will typically be either "success" or "failure", bu we
  setNextTaskDescription: (otherTask, returnCode) ->
    @nextDictionary[returnCode] = otherTask
    
exports.TaskDescription = TaskDescription