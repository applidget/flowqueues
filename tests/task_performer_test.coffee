###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

TaskDescription = require("../src/task_description").TaskDescription
TaskPerformer = require("../src/task_performer").TaskPerformer
FlowQueues = require("../src/flow_queues").FlowQueues

assert = require("assert")

describe "TaskPerformer testing",  ->
  basicTaskDesc = new TaskDescription("basic_task")
  it "should perform a basic task", (done) ->
    taskPerformer = TaskPerformer.performTask "#{process.cwd()}/tests/samples", basicTaskDesc , {arg1: "arg1"}, (status) ->
      done()
    