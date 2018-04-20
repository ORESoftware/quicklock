#!/usr/bin/env node
'use strict';

import {createParser, eventName, writeToStream} from './json-parser';

process.stdin.resume()
.pipe(createParser()).on(eventName, function (v: any) {
  if(v.releaseLock === true && v.lockName){
    console.log(v.lockName);
  }
  else{
    console.error('lockName not defined.')
  }
});




