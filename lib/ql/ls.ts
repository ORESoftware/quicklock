#!/usr/bin/env node
'use strict';

import path = require('path');
import fs = require('fs');

import chalk from 'chalk';
const pid = process.env.ql_pid;
const useJSON = process.env.ql_json === "yes";

if (!pid) {
  throw new Error('No pid passed via env var ("ql_pid").');
}

const file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');

try {
  fs.writeFileSync(file, '{}', {flag: 'wx'});
}
catch (err) {
  // ignore
}

const locks = require(file);

Object.keys(locks).forEach(function (k) {
  if (useJSON) {
    console.log(JSON.stringify(locks[k]));
  }
  else {
    console.log(chalk.cyan(locks[k].fullLockPath));
  }
});