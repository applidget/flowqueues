###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

flowqueues = require("../src/flowqueues")
redis = require("redis").createClient()

express = require('express')
app = express()


ui = flowqueues.createWebApp(redis, "../tests/samples/config.yml")
app.use("/flowqueues", ui)

app.listen(8124);
console.log('Listening on port 8124');

