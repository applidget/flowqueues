FlowQueues = require("../lib/flow_queues").FlowQueues
assert = require("assert")
describe "FlowQueues",  ->
  worker = FlowQueues.createWorker()
  taskDesk = 'fake_desc'
  worker.addTaskDescription(taskDesk)
  it "should add a task description", () ->
    assert.equal(1, worker.taskDescriptions.length)
  it "should be working", () ->
    worker.work()
    
    
  
