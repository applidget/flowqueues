FlowQueues = require("../lib/flow_queues").FlowQueues
redis = require("redis").createClient()
TaskDescription = require("../lib/task_description").TaskDescription
assert = require("assert")

describe "Basic FlowQueues Creation",  ->
  worker = FlowQueues.createWorker(redis)
  firstTaskDesc = new TaskDescription("firstStep")
  secondTaskDesc = new TaskDescription("secondStep")
  firstTaskDesc.setNextTaskDescription(secondTaskDesc, "success")
  
  worker.addTaskDescription(firstTaskDesc.name, firstTaskDesc)
  worker.addTaskDescription(secondTaskDesc.name, secondTaskDesc.name)
  it "should now have 2 task descriptions", () ->
    assert.equal(2, Object.keys(worker.taskDescriptions).length)
  it "should run 2 seconds", (done) ->
    worker.work()
    @timeout(15000)
    block = ()->
      worker.stop()
      done()
    setTimeout(block, 2000)
    
    
  
#TODO
# - Make sure a task from the lowest Q is fetched
#