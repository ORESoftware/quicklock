#!/usr/bin/env node
'use strict';

import path = require('path');
import fs = require('fs');

const pid = process.env.ql_pid;
const lockname = process.env.ql_lock_name;
const fullLockPath = process.env.ql_full_lock_path;


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

if(locks[lockname]){
  throw new Error(`Lockname with name "${lockname}" is already being used, by pid "${pid}."`);
}

const stamp = Date.now();

locks[lockname] = {
  date: new Date(stamp).toISOString(),
  timestamp: stamp,
  fullLockPath: fullLockPath,
  lockname: lockname,
  deleteOnExit: true
};

fs.writeFileSync(file, JSON.stringify(locks));