###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

log = require("util").log
exports.run = (jobData, cbs) ->
  console.log "Executing basic job"
  jobData.modifiedBy = "basic_task youhou !!!!"
  cbs("success")
    
