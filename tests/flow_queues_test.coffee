FlowQueues = require("../lib/flow_queues").FlowQueues
assert = require("assert")
describe "FlowQueues",  ->
  it "adds workflow",  ->
    workflow = "fakeworkflow"
    FlowQueues.addWorkflow(workflow)
    queues = FlowQueues.workflows
    assert.equal 1, queues.length
