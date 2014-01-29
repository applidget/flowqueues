###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

require "coffee-script" #in case the job itself is in coffeescript

class TaskPerformer
    
  @performTask: (baseDir, taskDescription, jobData, cbs ) ->
    taskImplementation = require("#{baseDir}/#{taskDescription.name}").run
    task = new Object()
    task.impl = taskImplementation
    task.register = (status) ->
      cbs(status)
    task.impl(jobData)
    
exports.TaskPerformer = TaskPerformer