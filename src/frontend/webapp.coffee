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
    @engine.use(express.static("#{__dirname}/public"))
    
    @engine.get "/api/jobs", (req, res) =>
      jobDescriptions = @client.config.jobDescriptions
      keys = _.keys(jobDescriptions)
      descriptions = []
      block = (key, cbs) =>
        @client.pendingJobsCount key, (pending) =>
          descriptions.push { name: key, pending: pending }
          cbs()
        
      async.each keys, block, (err) =>
        body = JSON.stringify(descriptions)
        res.setHeader "Content-Type", "application/json"
        res.setHeader "Content-Length", Buffer.byteLength(body)
        res.end body
    
exports.WebApp = WebApp