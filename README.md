#Flowqueues

Flowqueues is library providing queue based processing for node.js. It is developped using CoffeeScript but is distributed through npm as a regular node.js package through. It is CoffeeScript aware though since it can load and run jobs written in CoffeeScript.

##Installation
[![NPM](https://nodei.co/npm/flowqueues.png?downloads=true&stars=true)](https://nodei.co/npm/flowqueues/)

    npm install flowqueues
    


##Features

- Written in [CoffeeScript](http://coffeescript.org/)
- Backed by redis
- Jobs are defined as trees of tasks ([Flow based programming](http://en.wikipedia.org/wiki/Flow-based_programming)) by the application
- Concurrency setting for each task
- Dequeues jobs based on a list of queues

##Basic usage

First require `flowqueues` and `redis` and create a redisClient as you usually do:

    var flowqueues = require('flowqueues')
    var redis = require("redis")
    var redisClient = redis.createClient()
    

Create an enqueuer like so (**NB**: the config should describe all available types of jobs, which is not the case at this moment) and enqueue some job:

    var flowqueuesClient = flowqueues.createClient(redisClient, "../tests/samples/config.yml");
    var jobData = {arg1: "arg1", arg2: "arg2"};
    
    // As simple as 
    flowqueuesClient.enqueue("JobType1", jobData); //Which will enqueue to default queue (described in config maybe)

    //Or
    flowqueuesClient.enqueueTo("JobType1", jobData, "critical"); //overrides queue described in config

    //Or
    flowqueuesClient.enqueueTo("JobType1", jobData, "critical", function(err){
      //enqueuing is async and we may want to wait
    });

Here is how to create a worker. It can be loaded on different process than the enqueuer. The only think that matters is the configuration:
    
    var worker = flowqueues.createWorker(redisClient, "../tests/samples/config.yml");
    worker.work();
    
To load the web frontend from a express.js app, assuming it already exists (as `app` local variable):

    var flowQueuesUI = flowqueues.createWebApp(redisClient, "../tests/samples/config.yml")
    app.use("/flowqueues", flowQueuesUI);
    
##Environment variables

The following environment variables allow you to control the behaviour of flowqueues :

  - QUEUES (default: "critical,main,low") : this must be a comma separated list of queue names that you want flowqueues to process. The order of processing will depend on the order defined in this variable
  - INTERVAL (default: 5000) : the amount of time in mimmiseconds that flowqueues workers wait before polling the queues when they has nothing to do. Flowqueues workers become idle when there is nothing left to do. Change INTERVAL to a lower value if you need better responsiveness. Be aware though that this can affect CPU
  - `VERBOSE=true`,`VVERBOSE=true` : this controls the verbosity of flowqueues. `VVERBOSE=true` talks a lot more than `VERBOSE=true`

##Next steps (upcoming features)

  - use node.js cluster module to be crash safe like Resque does

##Target API


In addition to that, flowqueues will provide a binary allowing you to launch it using a single command line like this:
    
    $flowqueues work -c ../tests/samples/config.yml

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