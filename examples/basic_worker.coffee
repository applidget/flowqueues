FlowQueues = require("../lib/flow_queues").FlowQueues
TaskDescription = require("../lib/task_description").TaskDescription
redis = require("redis").createClient()
worker = FlowQueues.createWorker(redis)
worker.overridenJobDir = "#{process.cwd()}/../tests/samples"

firstTaskDesc = new TaskDescription("basic_task")
secondTaskDesc = new TaskDescription("basic_task2")
firstTaskDesc.setNextTaskDescription(secondTaskDesc, "success")
worker.addTaskDescription(firstTaskDesc.name, firstTaskDesc)
worker.addTaskDescription(secondTaskDesc.name, secondTaskDesc)

worker.setFirstTaskDescription(firstTaskDesc.name)

worker.work()
enqueue = () ->
  job = {arg1: "arg1", arg2: "arg22"}
  worker.enqueue(job)
setTimeout enqueue, 5000
