###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class TaskDescription

  constructor: (@name, @nextDictionary = {}, @concurrency = 1, @timeout = null) -> {}

  #returnCode is a string is will typically be either "success" or "failure", bu we
  setNextTaskNameForKey: (key, otherTaskName) ->
    @nextDictionary[key] = otherTaskName

  getNextTaskNameForKey: (key) ->
    return @nextDictionary[key]
    
exports.TaskDescription = TaskDescription