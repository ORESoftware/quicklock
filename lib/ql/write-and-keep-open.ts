#!/usr/bin/env node
'use strict';

//core
import util = require('util');

if (process.env.ql_read_stdin === 'yes') {
  process.stdin.resume()
  .on('data', function (d) {
    console.log('stdin received:', util.inspect(d));
  });
  
  process.once('exit', function () {
    process.stdin.destroy();
  });
}

const to = parseInt(process.env.ql_timeout || process.env.ql_to || '2000');

console.log(`Timeout of ${to} milliseconds.`);

setTimeout(function () {
  console.error(`Error: timed out after ${to} milliseconds.`);
  process.exit(1);
}, to);

console.log(process.env.ql_node_value);