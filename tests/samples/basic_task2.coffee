log = require("util").log

exports.run = (jobData) ->
  log "Executing basic job (Second kind)"
  cb = () =>
    @register "success"
  setTimeout cb, 2000
  
    
