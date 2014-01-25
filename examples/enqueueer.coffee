FlowQueues = require("../src/flow_queues").FlowQueues
ConfigLoader  = require("../src/config_loader").ConfigLoader
redis = require("redis").createClient()

worker = FlowQueues.createWorker(redis)
configLoader = new ConfigLoader(worker)
configLoader.load "./config.yml" 

for i in [1..1000]
  job = {arg1: "arg1", arg2: "arg22"}
  worker.enqueueTo(job, "low")
  
#Wait for a few seconds and close redis connection. This could be better done by using async.parallel for example
#but this is just an example
closeConnection = () ->
  redis.quit()
setTimeout closeConnection, 4000

