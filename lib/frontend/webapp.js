// Generated by CoffeeScript 1.7.1

/*
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
 */

(function() {
  var WebApp, async, express, queue, util, _;

  express = require('express');

  _ = require("underscore");

  queue = require("../queue");

  async = require("async");

  util = require("util");

  WebApp = (function() {
    function WebApp(client) {
      this.client = client;
      this.engine = express();
      this.init();
    }

    WebApp.prototype.init = function() {
      this.engine.use(express["static"]("" + __dirname + "/public"), express.methodOverride());
      this.engine.get("/api/jobs", (function(_this) {
        return function(req, res) {
          var block, descriptions, jobDescriptions, keys;
          jobDescriptions = _this.client.config.jobDescriptions;
          keys = _.keys(jobDescriptions);
          descriptions = [];
          block = function(key, cbs) {
            return _this.client.pendingJobsCount(key, function(pending) {
              descriptions.push({
                name: key,
                pending: pending
              });
              return cbs();
            });
          };
          return async.each(keys, block, function(err) {
            return res.json(descriptions);
          });
        };
      })(this));
      return this.engine.get("/api/jobs/:jobName/tasks", (function(_this) {
        return function(req, res) {
          var block, descriptions, job, jobName, keys;
          jobName = req.params.jobName;
          job = _this.client.config.jobDescriptions[jobName];
          keys = job.taskNames;
          descriptions = [];
          block = function(key, cbs) {
            return _this.client.pendingTasksCount(jobName, key, function(pending) {
              return _this.client.workingTasksCount(jobName, key, function(working) {
                descriptions.push({
                  name: key,
                  working: working,
                  pending: pending
                });
                return cbs();
              });
            });
          };
          return async.each(keys, block, function(err) {
            return res.json(_.sortBy(descriptions, "name"));
          });
        };
      })(this));
    };

    return WebApp;

  })();

  exports.WebApp = WebApp;

}).call(this);
