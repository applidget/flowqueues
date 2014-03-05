###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class JobDescription

  constructor: (@name) ->
    @taskDescriptions = {}
    @firstTaskName = null

  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc

  setFirstTaskName: (fistTaskName) ->
    @firstTaskName = fistTaskName

    
exports.JobDescription = JobDescription