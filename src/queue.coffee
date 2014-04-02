###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###
os = require "os"
util = require "util"

class Queue
  
  constructor: () ->
    # body...
    
  @hostname:() ->
    return os.hostname()
  
  @baseKeyName: ->
    return "flowqueues"
  
  @queueFormat: (jobName, taskName) ->
    return "#{@baseKeyName()}:%s:#{jobName}:#{taskName}"
    
  @baseQueueNameForTask:(jobName, taskName, ignoreHost = false) ->
    interFix = "#{@hostname()}"
    if ignoreHost? && ignoreHost == true
      interFix = "_"
    return util.format(@queueFormat(jobName,taskName), interFix)
          
  @pendingQueueNameForTaskName: (jobName, taskName, queue, ignoreHostName = false) ->
    return "#{@baseQueueNameForTask(jobName, taskName, ignoreHostName)}:#{queue}:pending"
  
  @pendingQueuePattern: (jobName, taskName) ->
    return "#{util.format(@queueFormat(jobName,taskName), "*")}:*:pending"

  @workingSetNameForTaskName:(jobName, taskName) ->
    return "#{@baseQueueNameForTask(jobName,taskName)}:working"
exports.Queue = Queue
  