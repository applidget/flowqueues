// Generated by CoffeeScript 1.7.1

/*
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
 */

(function() {
  var Client, Config, ConfigLoader, WebApp, Worker, createClient, createConfig, createWebApp, createWorker;

  ConfigLoader = require("./config_loader").ConfigLoader;

  Config = require("./config").Config;

  Worker = require("./worker").Worker;

  Client = require("./client").Client;

  WebApp = require("./frontend/webapp").WebApp;

  createConfig = function(dataSource, configPath) {
    var config, configLoader;
    config = new Config(dataSource);
    configLoader = new ConfigLoader(config);
    configLoader.load(configPath);
    return config;
  };

  createWorker = function(dataSource, configPath) {
    var client;
    client = createClient(dataSource, configPath);
    return new Worker(client);
  };

  createClient = function(dataSource, configPath) {
    var config;
    config = createConfig(dataSource, configPath);
    return new Client(config);
  };

  createWebApp = function(dataSource, configPath) {
    var client;
    client = createClient(dataSource, configPath);
    return new WebApp(client).engine;
  };

  exports.createWorker = createWorker;

  exports.createClient = createClient;

  exports.createWebApp = createWebApp;

}).call(this);
