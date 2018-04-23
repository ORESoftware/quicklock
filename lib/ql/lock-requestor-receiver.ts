#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

process.stdin.resume()
.on('data', function(v){
  console.log('raw data received in lock requestor receiver...', String(v));
  console.error('raw data received in lock requestor receiver...', String(v));
})
.pipe(createParser()).on(eventName, function (v: any) {
  
  console.log('json received in lock requestor receiver...', JSON.stringify(v));
  
  if(v.releaseLock === true && v.isResponse === true && v.lockName){
    console.log(v.lockName);
    console.log('released.');
  }
  else{
    console.error('no action taken in lock requestor receiver.')
  }
});




