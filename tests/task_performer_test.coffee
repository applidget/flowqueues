TaskDescription = require("../lib/task_description").TaskDescription
TaskPerformer = require("../lib/task_performer").TaskPerformer
FlowQueues = require("../lib/flow_queues").FlowQueues

assert = require("assert")

describe "TaskPerformer testing",  ->
  redis = {} #fake redis
  worker = FlowQueues.createWorker(redis)
  worker.overridenJobDir = "./samples"
  basicTaskDesc = new TaskDescription("basic_task")
  it "should perform a basic task", (done) ->
    taskPerformer = TaskPerformer.performTask "#{process.cwd()}/samples", basicTaskDesc , {}, (status) ->
      done()
    