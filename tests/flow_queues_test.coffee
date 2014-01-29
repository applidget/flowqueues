###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

FlowQueues = require("../src/flow_queues").FlowQueues
redis = require("redis").createClient()
TaskDescription = require("../src/task_description").TaskDescription
assert = require("assert")

describe "Basic FlowQueues Creation",  ->
  worker = FlowQueues.createWorker(redis)
  worker.overridenJobDir = "#{process.cwd()}/tests/samples"
  firstTaskDesc = new TaskDescription("basic_task")
  secondTaskDesc = new TaskDescription("basic_task2")
  firstTaskDesc.setNextTaskNameForKey("success", secondTaskDesc)
  
  worker.addTaskDescription(firstTaskDesc)
  worker.addTaskDescription(secondTaskDesc)
  
  worker.setFirstTaskName(firstTaskDesc.name)
  it "should now have 2 task descriptions", () ->
    assert.equal(2, Object.keys(worker.taskDescriptions).length)
  # it "should run 2 seconds", (done) ->
  #   worker.work()
  #   @timeout(15000)
  #   block = ()->
  #     worker.stop()
  #     done()
  #   setTimeout(block, 2000)
  it "should have 1 job pending", (done) ->
    payload = {first: "First", second: "Second arg", other_arg: "Other arg"}
    #Let's assume we use the class for enqueuing and working ...
    worker.enqueueTo payload, "main", () ->
      worker.pendingTasksCount firstTaskDesc.name, "main", (count) ->
        assert.equal(1, count)
        done()
    
    
    
  
#TODO
# - Make sure a task from the lowest Q is fetched
#