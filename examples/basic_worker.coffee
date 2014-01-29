###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

FlowQueues = require("../src/flow_queues").FlowQueues
ConfigLoader  = require("../src/config_loader").ConfigLoader
redis = require("redis").createClient()

worker = FlowQueues.createWorker(redis)
configLoader = new ConfigLoader(worker)
configLoader.load "../tests/samples/config.yml" 

worker.work()


#Uncomment to enqueue jobs from here. In general you will enqueue them from another process
# setTimeout enqueue, 5000
