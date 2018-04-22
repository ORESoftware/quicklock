#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

process.stdin.resume()
.on('data', function(v){
  console.error('json received in lock requestor receiver...', v);
})
.pipe(createParser()).on(eventName, function (v: any) {
  
  console.error('json received in receiver...', JSON.stringify(v));
  
  if(v.releaseLock === true && v.isResponse === true && v.lockName){
    console.log(v.lockName);
    console.log('released.');
  }
  else{
    console.error('lockName not defined.')
  }
});




