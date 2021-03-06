###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

express = require('express');
_ = require("underscore")
queue = require("../queue")
async = require("async")
util = require("util")

class WebApp

  constructor: (@client) ->
    @engine = express();
    @init()

  init: () ->
    @engine.use(
      express.static("#{__dirname}/public"),
      express.methodOverride()
    )
    
    @engine.get "/api/jobs", (req, res) =>
      jobDescriptions = @client.config.jobDescriptions
      keys = _.keys(jobDescriptions)
      descriptions = []
      block = (key, cbs) =>
        @client.pendingJobsCount key, (pending) =>
          descriptions.push { name: key, pending: pending }
          cbs()
        
      async.each keys, block, (err) =>
        res.json descriptions

    @engine.get "/api/jobs/:jobName/tasks", (req, res) =>
      jobName = req.params.jobName
      job = @client.config.jobDescriptions[jobName]
      keys = job.taskNames
      descriptions = []
      block = (key, cbs) =>
        @client.pendingTasksCount jobName, key, (pending) =>
          @client.workingTasksCount jobName, key, (working) =>
            descriptions.push {name: key, working: working, pending: pending }
            cbs()
      
      async.each keys, block, (err) =>
        res.json _.sortBy(descriptions, "name")

    
exports.WebApp = WebApp