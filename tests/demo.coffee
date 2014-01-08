FlowQueues = require("../lib/flow_queues").FlowQueues

worker = FlowQueues.createWorker()
taskDesk = 'fake_desc'
worker.addTaskDescription(taskDesk)

worker.addTaskDescription("task2")
worker.addTaskDescription("task4")
worker.addTaskDescription("task5")

worker.work()
