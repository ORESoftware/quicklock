#!/usr/bin/env node
'use strict';

import fs = require('fs');
import path = require('path');
import cp  = require('child_process');

const grandParentPid = parseInt(process.argv[2] || "0");

if (!grandParentPid) {
  throw new Error('quicklock: no pid passed at command line.')
}

// const magicStrings = [process.argv.indexOf('-m'), process.argv.indexOf('--mutex')].map(v => Math.max(v, 0));
//
// const magicIndex = magicStrings.reduce(function (a, b) {
//   if (a && b) throw new Error('--mutex and -m are clashing at the command line.');
//   if (!(a || b)) throw new Error('neither --mutex nor -m were passed at the command line.');
//   return a || b;
// });

let mutexKey = process.argv[3];

if (!mutexKey) {
  console.error('quicklock warning: using pwd as default value for mutex key.');
  // throw new Error('Missing argument after --mutex flag.');
  mutexKey = process.cwd()
}

const home = process.env.HOME;
const quicklockHome = path.resolve(home + '/.quicklock');

try {
  fs.mkdirSync(quicklockHome);
}
catch (err) {
  if (!/file already exists/gi.test(String(err.message))) {
    throw err;
  }
}

const cleanMutexKey = path.resolve(quicklockHome + '/' + String(mutexKey).replace(/\W+/g, '_'));

// console.log('quicklock: quicklock mutex key:', cleanMutexKey);

// process.once('exit', function () {
//   fs.unlinkSync(cleanMutexKey);
// });
//
// process.once('exit', function () {
//   fs.unlinkSync(cleanMutexKey);
// });
//

// process.once('exit', function () {
//   fs.unlinkSync(cleanMutexKey);
// });

try {
  fs.writeFileSync(cleanMutexKey, String(process.pid), {flag: 'wx'});
}
catch (err) {
  console.error('quicklock:', err.message);
  console.error('quicklock: to remove lock, delete that file manually.');
  process.exit(1);
}

// const parentPid = cp.execSync(`ps -o ppid=${process.pid}`);
// console.log('parentPid:', parentPid);

const unlockProcess = path.resolve(__dirname + '/unlock.js');

const to = setTimeout(function () {
  console.error('Could not launch quicklock child.');
  process.exit(1);
}, 3000);

const k = cp.spawn(`node`, [unlockProcess], {
  detached: true,
  env: Object.assign({}, process.env, {
    QUICKLOCK_FILEPATH: cleanMutexKey,
    QUICKLOCK_GRANDPARENT_PID: String(grandParentPid)
  })
});

k.stdout.setEncoding('utf8');
k.stderr.setEncoding('utf8');
k.stderr.pipe(process.stderr);

k.once('exit', function () {
  fs.unlinkSync(cleanMutexKey);
});

let stdout = '';

k.stdout.on('data', function (d) {
  stdout += String(d);
  if (/quicklock child listening/ig.test(stdout)) {
    clearTimeout(to);
    process.exit(0);
  }
});

