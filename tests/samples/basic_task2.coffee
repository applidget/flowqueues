exports.run = (jobData) ->
  console.log "Executing basic job (Second kind)"
  cb = () =>
    @register "success"
  setTimeout cb, 200
  
    
