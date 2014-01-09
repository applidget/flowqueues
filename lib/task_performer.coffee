require "coffee-script" #in case the job itself is in coffeescript

class TaskPerformer
    
  @performTask: (baseDir, taskDescription, jobData, cbs ) ->
    console.log "Base dir: #{baseDir}"
    taskImplementation = require("#{baseDir}/#{taskDescription.name}").run
    task = new Object()
    task.impl = taskImplementation
    task.register = (status) ->
      cbs(status)
    task.impl(jobData)
    
exports.TaskPerformer = TaskPerformer