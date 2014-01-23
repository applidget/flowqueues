#Flowqueues

Flowqueues is library providing queue based processing for node.js. It is developped using Coffee Script but is distributed as a regular javascript package. It is Coffee Script aware though since it can load and run jobs written in Coffee Script.

##Features

- Written in Coffee Script
- Backed by redis
- Jobs are defined as sequence of tasks (Flow based programming) by the application
- Support accurate concurrency tuning for each task

##Installation

Flowqueues in currently under **development**, so it is not yet distributed in npm. See next section to try it out. 


##Want to try it ?
A basic example with 2 different processes is included. This show that you don't have to enqueue and process the jobs in the same node.js process:

  - Install node.js and coffee-script
  - clone this project
  - Go to /examples
  - (First process) launch the example worker: `coffee basic_worker.coffee`
  - (Second process) Go to another window and launch the enqueuer process: `coffee enqueuer.coffee`

##Next steps

  - Make a config class or a config parser to be able to load the same config from different files and DRY
  - Release in npm 
  - Timeout feature: possibility to *kill* a task if it takes too much time

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