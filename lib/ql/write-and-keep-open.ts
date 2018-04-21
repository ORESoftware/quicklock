#!/usr/bin/env node
'use strict';

//core
import util = require('util');

process.stdin.resume()
.on('data',function(d){
   console.log('stdin received:', util.inspect(d));
});

process.once('exit', function () {
   process.stdin.destroy();
});

console.log(process.env.ql_node_value);