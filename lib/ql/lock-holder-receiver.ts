#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

process.stdin.resume()
// .on('data', function(v){
//   console.log('json received in lock holder receiver...', v);
//   console.error('json received in lock holder receiver...', v);
// })
.pipe(createParser()).on(eventName, function (v: any) {

  console.log('json received in lock holder receiver...', JSON.stringify(v));

  if(v.releaseLock === true && v.isRequest === true && v.lockName){
    console.log(v.lockName);
    console.log('released.');
  }
  else{
    console.log('lockName not defined in lock holder receiver.');
    console.error('lockName not defined in lock holder receiver.')
  }
});




