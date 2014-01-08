FlowQueues = require("../lib/flow_queues").FlowQueues
assert = require("assert")
describe "FlowQueues",  ->
  worker = FlowQueues.createWorker()
  it "should add a task description", () ->
    taskDesk = 'fake Desc'
    worker.addTaskDescription(taskDesk)
    assert.equal(1, worker.taskDescriptions.length)
    
    
  
