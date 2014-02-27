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
    
    @engine.get "/api/tasks", (req, res) =>
      descriptions = @client.config.taskDescriptions
      keys = _.keys(descriptions)
      descriptions = []
      block = (key, cbs) =>
        count = @client.pendingTasksCount key, "main", (count) =>
          console.log("Count for #{key} is #{count}")          
          descriptions.push {name: key, pending: count}
          cbs()
        
      async.each keys, block, (err) =>
        console.log "Err is #{util.inspect(descriptions)}"
        body = JSON.stringify(descriptions)
        res.setHeader "Content-Type", "application/json"
        res.setHeader "Content-Length", Buffer.byteLength(body)
        res.end body
    
exports.WebApp = WebApp