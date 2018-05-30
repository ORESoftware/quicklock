#!/usr/bin/env node
'use strict';

import path = require('path');
import fs = require('fs');

const pid = process.env.ql_pid;
const lockname = process.env.ql_lock_name;
const fulllockpath = process.env.ql_full_lock_path;
const isForce = process.env.ql_use_force === "yes";

if (!pid) {
  throw new Error('No pid passed via env var ("ql_pid").');
}

if (!lockname) {
  throw new Error('No lockname passed via env var ("ql_lock_name").');
}

const file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');

try {
  fs.writeFileSync(file, '{}', {flag: 'wx'});
}
catch (err) {
  // ignore
}

const locks = require(file);

if (!locks[lockname]) {
  console.error(`Warning: Lockname with name "${lockname}" does not exist for pid "${pid}".`);
}

// try{
//   fs.unlinkSync(fulllockpath);
// }
// catch(err){
//   if(!isForce){
//     console.error(`Could not delete lock with name ${lockname} and with path "${fulllockpath}".`);
//     throw err;
//   }
// }

delete locks[lockname];
fs.writeFileSync(file, JSON.stringify(locks));