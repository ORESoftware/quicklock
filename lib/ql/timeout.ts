#!/usr/bin/env node
'use strict';

let to = parseInt(process.env.ql_timeout || process.env.ql_to || '2000');

if (process.argv[2]) {
  to = parseInt(process.argv[2]);
}

process.stdin.resume().pipe(process.stdout);

process.once('exit', function () {
  process.stdin.end();
  process.stdin.destroy();
});

setTimeout(function () {
  console.error(`quicklock: timed out after ${to} milli-seconds.`);
  process.exit(1);
}, to);