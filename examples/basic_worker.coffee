###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

flowqueues = require("../src/flowqueues")
redis = require("redis").createClient()

worker = flowqueues.createWorker(redis, "../tests/samples/config.yml")
worker.work()


#Uncomment to enqueue jobs from here. In general you will enqueue them from another process
# setTimeout enqueue, 5000
