###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

helpers = require("./helpers")
Queue = require("./queue").Queue
async = require("async")

class Client

  constructor: (@config) ->
    @dataSource = @config.dataSource
  
  enqueueForTask:(jobName, taskName, job, queue, cbs = null) ->
    encodedJob = helpers.encode(job)
    @dataSource.rpush Queue.pendingQueueNameForTaskName(jobName, taskName, queue), encodedJob , (err, _) =>
      if cbs?
        cbs(err)
  
  enqueue:(jobName, jobData, cbs = null) ->
    queue = "main"
    if  @config.queues.length > 0
      queue = @config.queues[0]
    @enqueueTo jobName, jobData, queue, cbs
    
  enqueueTo: (jobName, jobData, queue, cbs = null) ->
    jobDesc = @config.jobDescriptions[jobName] #TODO: handle not found
    taskDesc = jobDesc.taskDescriptions[jobDesc.firstTaskName]
    @enqueueForTask(jobName, taskDesc.name, jobData, queue, cbs)
  
  pendingTasksCount: (jobName, taskName, cbs) ->
    count = 0
    block = (queue, blockCbs) =>
      @dataSource.llen Queue.pendingQueueNameForTaskName(jobName, taskName, queue), (err, nb) =>
        count += nb
        blockCbs()

    async.each @config.queues, block, (err) =>
      cbs(count)
      
  pendingJobsCount:(jobName, cbs) ->
    jobDesc = @config.jobDescriptions[jobName]
    firstTask = jobDesc.taskDescriptions[jobDesc.firstTaskName]
    @pendingTasksCount jobName, firstTask.name, (nb) =>
      cbs(nb)

  workingTasksCount: (jobName, taskName, cbs) ->
    @dataSource.llen Queue.workingSetNameForTaskName(jobName, taskName), (err, res) =>
      cbs(res)
  
  
exports.Client = Client