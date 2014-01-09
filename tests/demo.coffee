FlowQueues = require("../lib/flow_queues").FlowQueues
TaskDescription = require("../lib/task_description").TaskDescription

worker = FlowQueues.createWorker()
taskDesk = 'fake_desc'

firstTaskDesc = new TaskDescription("firstStep")
secondTaskDesc = new TaskDescription("secondStep")
firstTaskDesc.setNextTaskDescription(secondTaskDesc, "success")

worker.addTaskDescription(firstTaskDesc.name, firstTaskDesc)
worker.addTaskDescription(secondTaskDesc.name, secondTaskDesc.name)

worker.work()
