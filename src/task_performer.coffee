###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

require "coffee-script" #in case the job itself is in coffeescript

class TaskPerformer
    
  @performTask: (baseDir, taskDescription, jobData, cbs ) ->
    taskImplementation = require("#{process.cwd()}/#{baseDir}/#{taskDescription.name}").run
    taskCbs = (status) ->
      cbs(status)
    taskImplementation(jobData, taskCbs)
    
exports.TaskPerformer = TaskPerformer