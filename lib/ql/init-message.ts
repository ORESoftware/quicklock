#!/usr/bin/env node
'use strict';

const msg = process.argv[2] || process.env.ql_message;

if(!msg){
  console.error('quicklock: no message defined in ql_init_message.');
  process.exit(1);
}

console.log(msg);
process.stdin.resume().pipe(process.stdout);


