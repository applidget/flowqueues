Sequencer = require("../src/sequencer").Sequencer
assert = require("assert")

describe "Sequencer testing", ->
  sequencer = new Sequencer()
  results = []
  it "should perform the 2 tasks one after the other", (done) ->
    fn1 = (ok) ->
      results.push "fn1"
      ok()
      assert.equal("fn2", results.shift())
      done()
      
    fn2 = (ok) ->
      block = () ->
        results.push "fn2"
        ok()
      setTimeout(block, 1000)
    sequencer.scheduleInvocation fn2
    sequencer.scheduleInvocation fn1
    
    