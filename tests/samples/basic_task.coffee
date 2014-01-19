log = require("util").log
exports.run = (jobData) ->
  console.log "Executing basic job"
  jobData.modifiedBy = "basic_task youhou !!!!"
  @register("success")
    
