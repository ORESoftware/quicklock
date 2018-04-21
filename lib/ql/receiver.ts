#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

console.log('in the receiver beginning...');

process.stdin.resume()
.on('data', function(){
   console.log('data received in receiver...');
})
.pipe(createParser()).on(eventName, function (v: any) {
  if(v.releaseLock === true && v.isResponse === true && v.lockName){
    console.log(v.lockName);
  }
  else{
    console.error('lockName not defined.')
  }
});




