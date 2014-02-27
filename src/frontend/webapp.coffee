###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

express = require('express');
_ = require("underscore")
class WebApp

  constructor: (@client) ->
    @engine = express();
    @init()

  init: () ->
    @engine.use(express.static("#{__dirname}/public"))
    
    @engine.get "/api/tasks", (req, res) =>
      descriptions = @client.config.taskDescriptions
      keys = _.keys(descriptions)
      body = JSON.stringify(keys)
      res.setHeader "Content-Type", "application/json"
      res.setHeader "Content-Length", Buffer.byteLength(body)
      res.end body
    
exports.WebApp = WebApp