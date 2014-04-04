###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class Config

  constructor: (@dataSource) ->
    @jobDescriptions = {}
    @timeoutInterval ||= 5000
    queues_config_var = process.env["QUEUES"]
    if queues_config_var?
      @queues = queues_config_var.split(",")
    else
      @queues = ["critical", "main", "low"]#TODO: should queues be global or per tasks
    
  jobsDir:() ->
    return @overridenJobDir || process.cwd()
    
  addJobDescription: (jobDesc) ->
    @jobDescriptions[jobDesc.name] = jobDesc
  
exports.Config = Config