// Generated by CoffeeScript 1.7.1

/*
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
 */

(function() {
  var Client, Queue, async, helpers;

  helpers = require("./helpers");

  Queue = require("./queue").Queue;

  async = require("async");

  Client = (function() {
    function Client(config) {
      this.config = config;
      this.dataSource = this.config.dataSource;
    }

    Client.prototype.enqueueForTask = function(jobName, taskName, job, queue, ignoreHost, cbs) {
      var encodedJob;
      if (cbs == null) {
        cbs = null;
      }
      encodedJob = helpers.encode(job);
      return this.dataSource.rpush(Queue.pendingQueueNameForTaskName(jobName, taskName, queue, ignoreHost), encodedJob, (function(_this) {
        return function(err, _) {
          if (cbs != null) {
            return cbs(err);
          }
        };
      })(this));
    };

    Client.prototype.enqueue = function(jobName, jobData, cbs) {
      var queue;
      if (cbs == null) {
        cbs = null;
      }
      queue = "main";
      if (this.config.queues.length > 0) {
        queue = this.config.queues[0];
      }
      return this.enqueueTo(jobName, jobData, queue, cbs);
    };

    Client.prototype.enqueueTo = function(jobName, jobData, queue, cbs) {
      var jobDesc, taskDesc;
      if (cbs == null) {
        cbs = null;
      }
      jobDesc = this.config.jobDescriptions[jobName];
      taskDesc = jobDesc.taskDescriptions[jobDesc.firstTaskName];
      return this.enqueueForTask(jobName, taskDesc.name, jobData, queue, true, cbs);
    };

    Client.prototype.pendingTasksCount = function(jobName, taskName, cbs) {
      var block, count;
      count = 0;
      block = (function(_this) {
        return function(key, blockCbs) {
          return _this.dataSource.llen(key, function(err, nb) {
            count += nb;
            return blockCbs();
          });
        };
      })(this);
      return this.dataSource.keys(Queue.pendingQueuePattern(jobName, taskName), (function(_this) {
        return function(err, list) {
          return async.each(list, block, function(err) {
            return cbs(count);
          });
        };
      })(this));
    };

    Client.prototype.pendingJobsCount = function(jobName, cbs) {
      var firstTask, jobDesc;
      jobDesc = this.config.jobDescriptions[jobName];
      firstTask = jobDesc.taskDescriptions[jobDesc.firstTaskName];
      return this.pendingTasksCount(jobName, firstTask.name, (function(_this) {
        return function(nb) {
          return cbs(nb);
        };
      })(this));
    };

    Client.prototype.workingTasksCount = function(jobName, taskName, cbs) {
      return this.dataSource.llen(Queue.workingSetNameForTaskName(jobName, taskName), (function(_this) {
        return function(err, res) {
          return cbs(res);
        };
      })(this));
    };

    return Client;

  })();

  exports.Client = Client;

}).call(this);