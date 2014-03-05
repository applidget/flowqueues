###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

class Config

  constructor: (@dataSource) ->
    @jobDescriptions = {}
    @timeoutInterval ||= 5000
    @queues = ["critical", "main", "low"]#TODO: should queues be global or per tasks
    
  jobsDir:() ->
    return @overridenJobDir || process.cwd()
    
  addJobDescription: (jobDesc) ->
    @jobDescriptions[jobDesc.name] = jobDesc
  
exports.Config = Config