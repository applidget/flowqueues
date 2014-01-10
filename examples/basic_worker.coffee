FlowQueues = require("../lib/flow_queues").FlowQueues
TaskDescription = require("../lib/task_description").TaskDescription
redis = require("redis").createClient()

worker = FlowQueues.createWorker(redis)
worker.overridenJobDir = "#{process.cwd()}/../tests/samples"

firstTaskDesc = new TaskDescription("basic_task")
secondTaskDesc = new TaskDescription("basic_task2")

firstTaskDesc.setNextTaskDescription("success", secondTaskDesc)

worker.addTaskDescription(firstTaskDesc)
worker.addTaskDescription(secondTaskDesc)

worker.setFirstTaskDescription(firstTaskDesc.name)

worker.work()

enqueue = () ->
  for i in [1..10]
    job = {arg1: "arg1", arg2: "arg22"}
    worker.enqueue(job)

#Uncomment to enqueue jobs from here. In general you will enqueue them from another process
# setTimeout enqueue, 5000
