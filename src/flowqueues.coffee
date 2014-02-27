###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

ConfigLoader = require("./config_loader").ConfigLoader
Config = require("./config").Config
Worker = require("./worker").Worker
Client = require("./client").Client
WebApp = require("./frontend/webapp").WebApp

createConfig = (dataSource, configPath) ->
  config = new Config(dataSource) 
  configLoader = new ConfigLoader(config)
  configLoader.load configPath
  return config
  
createWorker = (dataSource, configPath)  ->
  client = createClient(dataSource, configPath)
  return new Worker(client)

createClient = (dataSource, configPath) ->
  config = createConfig(dataSource, configPath)
  return new Client(config)
  
createWebApp = (dataSource, configPath) ->
  client = createClient(dataSource, configPath)
  return new WebApp(client).engine

exports.createWorker = createWorker
exports.createClient = createClient
exports.createWebApp = createWebApp