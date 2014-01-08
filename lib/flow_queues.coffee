class FlowQueues
  constructor: (args) ->
    # body...
  @addWorkflow: (wf)  =>
    if ! @workflows?
      @workflows = []
    @workflows.push wf
    console.log("workflow added")
    

    
exports.FlowQueues = FlowQueues