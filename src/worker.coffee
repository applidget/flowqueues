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
    @working = true
    for name, taskDescription of @config.taskDescriptions
      do (name, taskDescription) =>
        @unregisterWorkingJobsForTask name, () =>
          @processTaskForName(name)
  
  stop: () ->
    for key, to in @timeOuts
      do (key, to) ->
        clearTimeout(to)
  
  unregisterWorkingJobsForTask: (taskName, cbs) ->
    @dataSource.del Queue.workingSetNameForTaskName(taskName), (err, _) ->
      cbs()
  
  processTaskForName: (taskName, previouslyRemaining = 0) ->
    @sequencer.scheduleInvocation (next) =>
      if @timeOuts[taskName]?
        clearTimeout(@timeOuts[taskName])
        @timeOuts[taskName] = null

      leCallback = (nowRemaining = 0) =>
        @processTaskForName(taskName, nowRemaining)
    
      schedulePolling =  () =>
        if taskName == @config.firstTaskName
          @timeOuts[taskName] = setTimeout(leCallback, @config.timeoutInterval)
        
      @isWorkerAvailableForTaskName taskName, previouslyRemaining, (isAvailable, howMany) =>
        if !isAvailable
          next()
          return

        taskDescription = @config.taskDescriptions[taskName]
        @reserveJob taskName, (foundJob, queue) =>
          if foundJob?
            #TODO: add verbosity option to be able to silence this
            log "Got #{taskName} #{util.inspect foundJob}"
            if howMany > 1
              leCallback(howMany - 1)
            @performTaskOnJob(foundJob, taskDescription, queue, next, leCallback)
          else            
            next()
            schedulePolling()
  
  isWorkerAvailableForTaskName:(taskName, previouslyRemaining, cbs) ->
    @workingCountForTaskName taskName, (count) =>
      taskDescription = @config.taskDescriptions[taskName]
      status = false
      if count < taskDescription.concurrency
        status = true
      cbs(status, taskDescription.concurrency - count)

  workingCountForTaskName:(taskName, cbs) ->
    @dataSource.llen Queue.workingSetNameForTaskName(taskName), (err, length) =>
      cbs(length)

  performTaskOnJob: (job, taskDescription, queue, next,  callback) ->
    #TODO: check if task is modified here. It should be !
    #TODO: register task as running in redis here
    @registerJobInProgress job, taskDescription.name, (err) =>
      process.nextTick () =>
        TaskPerformer.performTask @config.jobsDir(), taskDescription, job, (status) =>
          @sequencer.scheduleInvocation (done) =>
            @unregisterJobInProgress job, taskDescription.name, (err) =>
              done()
              nextTaskName = taskDescription.getNextTaskNameForKey(status)
              log "Done #{taskDescription.name}!"
              if !nextTaskName?
                callback()
              else
                @client.enqueueForTask nextTaskName, job, queue, () =>
                  #TODO: try swaping the two lines. Depth First vs Breadth First execution
                  @processTaskForName nextTaskName
                  callback()
      #poor lonely instruction. end for @registerJobInProgress
      next()

  registerJobInProgress:(job, taskName, cbs) ->
    #TODO: the encoded data should be already available
    data = helpers.encode(cbs)
    @dataSource.rpush Queue.workingSetNameForTaskName(taskName), data, (err, _) =>
      cbs(err)

  unregisterJobInProgress:(job, taskName, cbs = null) ->
    data = helpers.encode(cbs)
    key = Queue.workingSetNameForTaskName(taskName)
    @dataSource.lrem key, 1, data, (err, _) =>
      if cbs?
        cbs(err)
  
  reserveJobOnQueue:(taskName, queue, cbs) ->
    @dataSource.lpop Queue.pendingQueueNameForTaskName(taskName, queue), (err, res) =>
      job = helpers.decode(res)
      cbs(job)
      
  reserveJob: (taskName, foundJobCbs, queue) ->
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
      @reserveJobOnQueue taskName, @config.queues[queueIndex], (job) =>
        if job?
          foundJob = job
        else
          queueIndex += 1
        cbs()
        
    async.whilst test, block, finalStep
  
      

exports.Worker = Worker