###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

TaskDescription = require("./task_description").TaskDescription
JobDescription = require("./job_description").JobDescription

yaml = require('js-yaml')
fs   = require('fs')

class ConfigLoader 

  constructor: (@config) ->
    #
    
  load:(file) ->
    conf = yaml.safeLoad(fs.readFileSync(file, 'utf8')).flowqueues_config
    @config.overridenJobDir = conf.jobs_dir if conf.jobs_dir
    for workflow in conf.workflows #TODO: should this be called jobDesc or Workflow ? 
      do (workflow) =>
        jobDesc = new JobDescription workflow.name
        @config.addJobDescription jobDesc
        jobDesc.setFirstTaskName(workflow.first_task)
        for task in workflow.tasks
          do (task) =>
            concurrency = task.concurrency || 1
            name = task.name #TODO: handle error if name empty
            next = task.next || {}
            taskDesc = new TaskDescription(name, next, concurrency)
            jobDesc.addTaskDescription(taskDesc)

exports.ConfigLoader = ConfigLoader