###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

TaskDescription = require("./task_description").TaskDescription
yaml = require('js-yaml')
fs   = require('fs')

class ConfigLoader 

  constructor: (@config) ->
    #
  load:(file) ->
    workflows = yaml.safeLoad(fs.readFileSync(file, 'utf8')).workflows
    for workflow in workflows
      do (workflow) ->
        @config.overridenJobDir = conf.jobs_dir if conf.jobs_dir
        @config.setFirstTaskName(conf.first_task)
        for task in conf.tasks
          do (task) =>
            concurrency = task.concurrency || 1
            name = task.name #TODO: handle error if name empty
            next = task.next || {}
            taskDesc = new TaskDescription(name, next, concurrency)
            @config.addTaskDescription(taskDesc)

exports.ConfigLoader = ConfigLoader