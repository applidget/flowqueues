###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

#Helper class to gracefully handle blocks of code in sequence
#Usefull to make sure a number of async calls are made in sequence
#and nothing similar is called in between

class Sequencer

  constructor: (args) ->
    @busy = false
    @tasksQueue = []
  
  scheduleInvocation: (fn) ->
    @tasksQueue.push fn
    if @busy == false
      @processNextInvocation()

  processNextInvocation:() ->
    if @tasksQueue.length == 0
      return
    fn = @tasksQueue.shift()
    @busy = true
    fn () =>
      @busy = false
      @processNextInvocation()
  
exports.Sequencer = Sequencer