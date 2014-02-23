###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

log = require("util").log

exports.run = (jobData, cbs) ->
  log "Executing basic job (Second kind)"
  log "Modified or not : #{jobData.modifiedBy}"
  cb = () =>
    cbs "success"
  setTimeout cb, 2000
  
    
