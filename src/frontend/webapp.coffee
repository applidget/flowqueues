###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

express = require('express');

class WebApp

  constructor: (@client) ->
    @engine = express();
    @init()

  init: () ->
    @engine.use(express.static("#{__dirname}/public"))
    
    @engine.get "/dashboard", (req, res) ->
      body = "Hello World"
      res.setHeader "Content-Type", "text/plain"
      res.setHeader "Content-Length", Buffer.byteLength(body)
      res.end body
    
exports.WebApp = WebApp