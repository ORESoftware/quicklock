#!/usr/bin/env node
'use strict';

import path = require('path');
import fs = require('fs');

const pid = process.env.ql_pid;
const lockname = process.env.ql_lock_name;
const isForce = process.env.ql_force === 'yes';


if(!pid){
  throw new Error('No pid passed via env var ("ql_pid").');
}

if(!lockname){
  throw new Error('No lockname passed via env var ("ql_lock_name").');
}

const file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');

try{
  fs.writeFileSync(file, '{}', {flag:'wx'});
}
catch(err){
  // ignore
}

const locks = require(file);

Object.keys(locks).forEach(function(k){
  const lock = locks[k];
  try{
    if(isForce === true || lock.deleteOnExit === true){
      fs.unlinkSync(lock['fullLockPath']);
    }
  }
  catch(err){
    console.error(err);
  }
});