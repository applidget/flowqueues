//Useful helper to debug sync stuff. Picks a color based on its modulo results on the
//number of colors available. It is in js and not coffee script since I could not properly escape the backslash 
//in coffee script. There is probably some available trick for that. 
var colorizeInt = function(id) {
  var reset = '\033[0m';
  var colors = [
    '\033[31m',
    '\033[32m',
    '\033[33m',
    '\033[34m',
    '\033[35m',
    '\033[36m',
    '\033[37m'
  ];
  
    
  var idx = id % colors.length;
  var color = colors[idx];
  return color + id + reset;
}
    
exports.colorizeInt = colorizeInt;