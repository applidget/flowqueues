###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class JobDescription

  constructor: (@name) ->
    @taskDescriptions = {}
    #Task description names are stored in array to preserve order
    @taskNames = []
    @firstTaskName = null

  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc
    @taskNames.push taskDesc.name

  setFirstTaskName: (fistTaskName) ->
    @firstTaskName = fistTaskName

    
exports.JobDescription = JobDescription