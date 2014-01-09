FlowQueues = require("../lib/flow_queues").FlowQueues
redis = require("redis").createClient()
TaskDescription = require("../lib/task_description").TaskDescription
assert = require("assert")

describe "Basic FlowQueues Creation",  ->
  worker = FlowQueues.createWorker(redis)
  firstTaskDesc = new TaskDescription("basic_task")
  secondTaskDesc = new TaskDescription("basic_task")
  firstTaskDesc.setNextTaskDescription(secondTaskDesc, "success")
  
  worker.addTaskDescription(firstTaskDesc.name, firstTaskDesc)
  worker.addTaskDescription(secondTaskDesc.name, secondTaskDesc.name)
  worker.setFirstTaskDescription(firstTaskDesc.name)
  it "should now have 2 task descriptions", () ->
    assert.equal(2, Object.keys(worker.taskDescriptions).length)
  it "should run 2 seconds", (done) ->
    worker.work()
    @timeout(15000)
    block = ()->
      worker.stop()
      done()
    setTimeout(block, 2000)
  it "should have 1 job pending", (done) ->
    payload = {first: "First", second: "Second arg", other_arg: "Other arg"}
    #Let's assume we use the class for enqueuing and working ...
    worker.enqueue(payload, done)
    
    
  
#TODO
# - Make sure a task from the lowest Q is fetched
#