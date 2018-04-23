#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

process.stdin.resume()
// .on('data', function(v){
//   console.log('json received in lock holder receiver...', v);
//   console.error('json received in lock holder receiver...', v);
// })
.pipe(createParser()).on(eventName, function (v: any) {
  
  console.log('json received in lock holder...', JSON.stringify(v));
  
  if (v.releaseLock === true && v.isRequest === true && v.lockName) {
    console.log(JSON.stringify({quicklock: true, isResponse: true, lockName: v.lockName, released: true}));
    console.log(v.lockName);
    console.log('released.');
  }
  else {
    console.error('no action taken in lock holder receiver.')
  }
});




