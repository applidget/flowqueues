###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

express = require('express');

class WebApp

  constructor: () ->
    @engine = express();
    @init()

  init: () ->
    @engine.get "/dashboard", (req, res) ->
      body = "Hello World"
      res.setHeader "Content-Type", "text/plain"
      res.setHeader "Content-Length", Buffer.byteLength(body)
      res.end body
    
exports.WebApp = WebApp