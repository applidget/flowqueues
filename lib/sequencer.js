// Generated by CoffeeScript 1.7.1

/*
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
 */

(function() {
  var Sequencer;

  Sequencer = (function() {
    function Sequencer(args) {
      this.busy = false;
      this.tasksQueue = [];
    }

    Sequencer.prototype.scheduleInvocation = function(fn) {
      this.tasksQueue.push(fn);
      if (this.busy === false) {
        return this.processNextInvocation();
      }
    };

    Sequencer.prototype.processNextInvocation = function() {
      var fn;
      if (this.tasksQueue.length === 0) {
        return;
      }
      fn = this.tasksQueue.shift();
      this.busy = true;
      return fn((function(_this) {
        return function() {
          _this.busy = false;
          return _this.processNextInvocation();
        };
      })(this));
    };

    return Sequencer;

  })();

  exports.Sequencer = Sequencer;

}).call(this);
