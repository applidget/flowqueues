// Generated by CoffeeScript 1.7.1

/*
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
 */

(function() {
  var TaskPerformer;

  require("coffee-script");

  TaskPerformer = (function() {
    function TaskPerformer() {}

    TaskPerformer.performTask = function(baseDir, taskDescription, jobData, cbs) {
      var taskCbs, taskImplementation;
      taskImplementation = require("" + (process.cwd()) + "/" + baseDir + "/" + taskDescription.name).run;
      taskCbs = function(status) {
        return cbs(status);
      };
      return taskImplementation(jobData, taskCbs);
    };

    return TaskPerformer;

  })();

  exports.TaskPerformer = TaskPerformer;

}).call(this);
