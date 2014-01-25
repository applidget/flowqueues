FlowQueues = require("../src/flow_queues").FlowQueues
ConfigLoader  = require("../src/config_loader").ConfigLoader
redis = require("redis").createClient()

worker = FlowQueues.createWorker(redis)
configLoader = new ConfigLoader(worker)
configLoader.load "./config.yml" 

worker.work()


#Uncomment to enqueue jobs from here. In general you will enqueue them from another process
# setTimeout enqueue, 5000
