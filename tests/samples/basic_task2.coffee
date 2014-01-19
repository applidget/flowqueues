log = require("util").log

exports.run = (jobData) ->
  log "Executing basic job (Second kind)"
  log "Modified or not : #{jobData.modifiedBy}"
  cb = () =>
    @register "success"
  setTimeout cb, 2000
  
    
