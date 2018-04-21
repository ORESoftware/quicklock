#!/usr/bin/env node
'use strict';

import path = require('path');
import fs = require('fs');
import cp = require('child_process');

const pid = process.env.ql_pid;
const isForce = process.env.ql_force === 'yes';

if (!pid) {
  throw new Error('No pid passed via env var ("ql_pid").');
}

const file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');

try {
  // create file if it doesn't exist
  fs.writeFileSync(file, '{}', {flag: 'wx'});
}
catch (err) {
  // ignore
}

const locks = require(file);
const copy = {} as any;

Object.keys(locks).forEach(function (k) {
  const lock = locks[k];
  try {
    if (isForce === true || lock.deleteOnExit === true) {
      const name = lock['fullLockPath'];
      console.log(name);
      cp.execSync(`rm -rf ${name};`);
    }
    else {
      // keep these keys
      copy[k] = locks[k];
    }
  }
  catch (err) {
    console.error(err);
  }
});

fs.writeFileSync(file, JSON.stringify(copy), {flag: 'w'});