log = require("util").log
exports.run = (jobData) ->
  log "Executing basic job"
  @register("success")
    
