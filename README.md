#Flowqueues

Flowqueues is library providing queue based processing for node.js. It is developped using CoffeeScript but is distributed through npm as a regular node.js package through. It is CoffeeScript aware though since it can load and run jobs written in CoffeeScript.

##Installation

    npm install flowqueues
    
[![NPM](https://nodei.co/npm/flowqueues.png?downloads=true&stars=true)](https://nodei.co/npm/flowqueues/)
    
##Features

- Written in [CoffeeScript](http://coffeescript.org/)
- Backed by redis
- Jobs are defined as trees of tasks ([Flow based programming](http://en.wikipedia.org/wiki/Flow-based_programming)) by the application
- Concurrency setting for each task

##Basic usage
A basic example with 2 different processes is included. This show that you don't have to enqueue and process the jobs in the same node.js process
    
##Next steps (upcoming features)

  - Timeout feature: possibility to *kill* a task if it takes too much time
  - Web UI
  - use node.js cluster module to be crash safe like Resque does

## License 

(The MIT License)

Copyright (c) 2014 Applidget SAS &lt;romain.pechayre@applidget.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.