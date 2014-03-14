###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

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

clone = (hash) ->
  return decode(encode(hash))

verbose = () ->
  return vverbose() || process.env.VERBOSE == "true"
  
vverbose = () ->
  return process.env.VVERBOSE == "true"
  
exports.encode = encode
exports.decode = decode
exports.verbose = verbose
exports.vverbose = vverbose