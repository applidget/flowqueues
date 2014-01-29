util = require("util")

encode = (hash) ->
  return JSON.stringify(hash)
  
decode = (json) ->
  res = null
  try
    res = JSON.parse(json)
  catch
    #TODO: why is that ?
    log "PARSING ERROR: #{util.inspect(util.inspect(json))}"
  return res
  
exports.encode = encode
exports.decode = decode