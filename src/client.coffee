###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

helpers = require("./helpers")
Queue = require("./queue").Queue

class Client

  constructor: (@config) ->
    @dataSource = @config.dataSource
  
  enqueueForTask:(taskName, job, queue, cbs = null) ->
    encodedJob = helpers.encode(job)
    @dataSource.rpush Queue.pendingQueueNameForTaskName(taskName, queue), encodedJob , (err, _) =>
      if cbs?
        cbs(err)
  
  enqueue:(job, cbs = null) ->
    queue = "main"
    if  @config.queues.length > 0
      queue = @config.queues[0]
    @enqueueTo job, queue, cbs
    
  enqueueTo: (job, queue, cbs = null) ->
    taskDesc = @config.taskDescriptions[@config.firstTaskName]
    @enqueueForTask(taskDesc.name, job, queue, cbs)
  
  pendingTasksCount: (taskName, queue, cbs) ->
    @dataSource.llen Queue.pendingQueueNameForTaskName(taskName, queue), (err, res) =>
      cbs(res)

  workingTasksCount: (taskName, cbs) ->
    @dataSource.llen Queue.workingSetNameForTaskName(taskName), (err, res) =>
      cbs(res)
  
  
exports.Client = Client