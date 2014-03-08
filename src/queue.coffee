###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###
os = require "os"

class Queue

  constructor: () ->
    # body...
  @hostname:() ->
    return os.hostname()
  
  @baseKeyName: ->
    return "flowqueues"
  
  @baseQueueNameForTask:(jobName, taskName, ignoreHost = false) ->
    interFix = "#{@hostname()}:"
    if ignoreHost == true
      interFix = ""
    return "#{@baseKeyName()}:#{interFix}#{jobName}:#{taskName}"
          
  @pendingQueueNameForTaskName: (jobName, taskName, queue) ->
    ignoreHostName = (taskName == @firstTaskName)
    return "#{@baseQueueNameForTask(jobName, taskName, ignoreHostName)}:#{queue}:pending"

  @workingSetNameForTaskName:(jobName, taskName) ->
    return "#{@baseQueueNameForTask(jobName,taskName)}:working"
exports.Queue = Queue
  