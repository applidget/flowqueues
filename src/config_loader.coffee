###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

TaskDescription = require("./task_description").TaskDescription
yaml = require('js-yaml')
fs   = require('fs')

class ConfigLoader 

  constructor: (@worker) ->
    #
  load:(file) ->
    conf = yaml.safeLoad(fs.readFileSync(file, 'utf8')).flowqueue_graph
    @worker.overridenJobDir = conf.jobs_dir if conf.jobs_dir
    @worker.setFirstTaskName(conf.first_task)
    for task in conf.tasks
      do (task) =>
        concurrency = task.concurrency || 1
        name = task.name #TODO: handle error if name empty
        next = task.next || {}
        taskDesc = new TaskDescription(name, next, concurrency)
        @worker.addTaskDescription(taskDesc)

exports.ConfigLoader = ConfigLoader