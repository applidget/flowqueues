###
Flowqueues - Queue based programming for node.js
(c) Copyright 2014 Applidget SAS
Released under the MIT License
###

#Useful helper to debug sync stuff. Picks a color based on its modulo results on the
#number of colors available. It is in js and not coffee script since I could not properly escape the backslash 
#in coffee script. There is probably some available trick for that. 

colorizeInt = (id) ->
  reset = "\u001b[0m"
  colors = ["\u001b[31m", "\u001b[32m", "\u001b[33m", "\u001b[34m", "\u001b[35m", "\u001b[36m", "\u001b[37m"]
  idx = id % colors.length
  color = colors[idx]
  color + id + reset

exports.colorizeInt = colorizeInt