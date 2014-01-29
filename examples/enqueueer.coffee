###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

flowqueues = require("../src/flowqueues")
redis = require("redis").createClient()

enqueuer = flowqueues.createClient(redis, "../tests/samples/config.yml")

for i in [1..3000]
  job = {arg1: "arg1", arg2: "arg22"}
  enqueuer.enqueueTo(job, "low")
  
#Wait for a few seconds and close redis connection. This could be better done by using async.parallel for example
#but this is just an example
closeConnection = () ->
  redis.quit()
setTimeout closeConnection, 4000

