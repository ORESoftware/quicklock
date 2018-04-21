#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

console.log('in the receiver beginning...');

process.stdin.resume()
.on('data', function(){
   console.log('data received in receiver...');
})
.pipe(createParser()).on(eventName, function (v: any) {
  
  console.log('json received in receiver...', JSON.stringify(v));
  
  if(v.releaseLock === true && v.isResponse === true && v.lockName){
    console.log(v.lockName);
    console.log('released.');
  }
  else{
    console.error('lockName not defined.')
  }
});




