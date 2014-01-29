###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class Config

  constructor: (@dataSource) ->
    @taskDescriptions = {}
    @firstTaskName = null
    @timeoutInterval ||= 5000
    @queues = ["critical", "main", "low"]
    
  addTaskDescription: (taskDesc) ->
    @taskDescriptions[taskDesc.name] = taskDesc

  setFirstTaskName: (fistTaskName) ->
    @firstTaskName = fistTaskName

  jobsDir:() ->
    return @overridenJobDir || process.cwd()
  
exports.Config = Config