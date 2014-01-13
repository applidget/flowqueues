FlowQueues = require("../lib/flow_queues").FlowQueues
TaskDescription = require("../lib/task_description").TaskDescription
redis = require("redis").createClient()

worker = FlowQueues.createWorker(redis)
# worker.overridenJobDir = "#{process.cwd()}/../tests/samples"

firstTaskDesc = new TaskDescription("basic_task")
secondTaskDesc = new TaskDescription("basic_task2")

firstTaskDesc.setNextTaskDescription("success", secondTaskDesc)

worker.addTaskDescription(firstTaskDesc)
worker.addTaskDescription(secondTaskDesc)

worker.setFirstTaskDescription(firstTaskDesc.name)

for i in [1..100000]
  job = {arg1: "arg1", arg2: "arg22"}
  worker.enqueue_to(job, "low")
  
#Wait for a few seconds and close redis connection. This could be better doe by using async.parallel for example
#but this is just an example
closeConnection = () ->
  redis.quit()
setTimeout closeConnection, 4000

