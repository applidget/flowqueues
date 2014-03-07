###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

TaskPerformer = require("./task_performer").TaskPerformer
Sequencer = require("./sequencer").Sequencer
Queue = require("./queue").Queue
helpers = require("./helpers")
async = require "async"
log = require("util").log
util = require("util")

class Worker

  constructor: (@client) ->
    @config = @client.config
    @dataSource = @config.dataSource
    @working = false
    @sequencer = new Sequencer()
    @timeOuts = {}

  work: () ->
    if @working == true
      log "Warning: Already working"
      return
    log "Flowqueues Starting" if helpers.verbose()
    @working = true
    for jobName, jobDescription of @config.jobDescriptions
      do (jobName, jobDescription) =>         
        for name, taskDescription of jobDescription.taskDescriptions
          do (name, taskDescription) =>
            @unregisterWorkingJobsForTask jobName, name, () =>
              @processTaskForName(jobName, name)
  
  stop: () ->
    for key, to in @timeOuts
      do (key, to) ->
        clearTimeout(to)
  
  unregisterWorkingJobsForTask: (jobName, taskName, cbs) ->
    @dataSource.del Queue.workingSetNameForTaskName(jobName, taskName), (err, _) ->
      cbs()
  
  processTaskForName: (jobName, taskName, previouslyRemaining = 0) ->
    jobDescription = @config.jobDescriptions[jobName]
    @sequencer.scheduleInvocation (next) =>
      if @timeOuts[jobName]?
        clearTimeout(@timeOuts[jobName])
        @timeOuts[jobName] = null

      leCallback = (nowRemaining = 0) =>
        log "*** Looking up #{taskName}" if helpers.vverbose()
        @processTaskForName(jobName, taskName, nowRemaining)
    
      schedulePolling =  () =>
        if taskName == jobDescription.firstTaskName
          @timeOuts[jobName] = setTimeout(leCallback, @config.timeoutInterval)
        
      @isWorkerAvailableForTaskName jobName, taskName, previouslyRemaining, (isAvailable, howMany) =>
        if !isAvailable
          next()
          return

        taskDescription = jobDescription.taskDescriptions[taskName]
        @reserveJob jobName, taskName, (foundJob, queue) =>
          if foundJob?
            log "Got #{taskName} #{util.inspect foundJob}" if helpers.verbose()
            if howMany > 1
              leCallback(howMany - 1)
            @performTaskOnJob(jobName, foundJob, taskDescription, queue, next, leCallback)
          else            
            next()
            schedulePolling()
  
  isWorkerAvailableForTaskName:(jobName, taskName, previouslyRemaining, cbs) ->
    @client.workingTasksCount jobName, taskName, (count) =>
      jobDescription = @config.jobDescriptions[jobName]
      taskDescription = jobDescription.taskDescriptions[taskName]
      status = false
      if count < taskDescription.concurrency
        status = true
      cbs(status, taskDescription.concurrency - count)

  
  performTaskOnJob: (jobName, job, taskDescription, queue, next,  callback) ->
    @registerJobInProgress jobName, job, taskDescription.name, (err) =>
      process.nextTick () =>
        TaskPerformer.performTask @config.jobsDir(), taskDescription, job, (status) =>
          @sequencer.scheduleInvocation (done) =>
            @unregisterJobInProgress jobName, job, taskDescription.name, (err) =>
              done()
              nextTaskName = taskDescription.getNextTaskNameForKey(status)
              log "Done #{taskDescription.name}!" if helpers.verbose()
              if !nextTaskName?
                callback()
              else
                @client.enqueueForTask jobName, nextTaskName, job, queue, () =>
                  #TODO: try swaping the two lines. Depth First vs Breadth First execution
                  @processTaskForName jobName, nextTaskName
                  callback()
      #poor lonely instruction. end for @registerJobInProgress
      next()

  registerJobInProgress:(jobName, jobData, taskName, cbs) ->
    data = helpers.encode(jobData)
    @dataSource.rpush Queue.workingSetNameForTaskName(jobName, taskName), data, (err, _) =>
      cbs(err)

  unregisterJobInProgress:(jobName, jobData, taskName, cbs = null) ->
    data = helpers.encode(jobData)
    key = Queue.workingSetNameForTaskName(jobName, taskName)
    @dataSource.lrem key, 1, data, (err, _) =>
      if cbs?
        cbs(err)
  
  reserveJobOnQueue:(jobName, taskName, queue, cbs) ->
    @dataSource.lpop Queue.pendingQueueNameForTaskName(jobName, taskName, queue), (err, res) =>
      job = helpers.decode(res)
      cbs(job)
      
  reserveJob: (jobName, taskName, foundJobCbs, queue) ->
    queueIndex = 0
    foundJob = null
    #This is an async implementation of a break in a for loop using the "async" framework
    #This determines if we should go for the next queue
    test = () =>
      return !foundJob? && queueIndex < @config.queues.length

    #Happens when job has been found or all queues are empty
    finalStep = (err) =>
      foundJobCbs(foundJob, @config.queues[queueIndex])
    
    block = (cbs) =>
      @reserveJobOnQueue jobName, taskName, @config.queues[queueIndex], (job) =>
        if job?
          foundJob = job
        else
          queueIndex += 1
        cbs()
        
    async.whilst test, block, finalStep
  
      

exports.Worker = Worker