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
  
  @baseQueueNameForTask:(taskName, ignoreHost = false) ->
    interFix = "#{@hostname()}:"
    if ignoreHost == true
      interFix = ""
    return "#{@baseKeyName()}:#{interFix}#{taskName}"
          
  @pendingQueueNameForTaskName: (taskName, queue) ->
    ignoreHostName = (taskName == @firstTaskName)
    return "#{@baseQueueNameForTask(taskName, ignoreHostName)}:#{queue}:pending"

  @workingSetNameForTaskName:(taskName) ->
    return "#{@baseQueueNameForTask(taskName)}:working"
exports.Queue = Queue
  