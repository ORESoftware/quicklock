'use strict';

import cp = require('child_process');
import fs = require('fs');
import path = require('path');
import os = require('os');

const filePath = process.env.QUICKLOCK_FILEPATH;
const grandParentPid = process.env.QUICKLOCK_GRANDPARENT_PID;
const isDarwin = String(os.platform()).toLowerCase() === 'darwin';

if (!filePath) {
  throw new Error('Quicklock error - missing filepath.');
}

if (!grandParentPid) {
  throw new Error('Quicklock error - missing grandParentPid.');
}

process.once('exit', function () {
  console.error('unlock process is exiting...');
  fs.rmdirSync(filePath);
});

const strm = fs.createWriteStream(process.cwd() + '/debug-unlock.log');
strm.write('filepath in unlock:' + filePath);


const k = cp.spawn(`bash`, [], {
  detached: true
});

k.stderr.setEncoding('utf8');
k.stdout.setEncoding('utf8');

k.stderr.pipe(strm, {end: false});
k.stdout.pipe(strm, {end: false});

k.once('exit', function () {
  console.log('wait process is exiting.');
  try {
    fs.rmdirSync(filePath);
  }
  finally {
    process.exit(0);
  }
});

// tail --pid=11666  # tail --pid=11666 -f /dev/null

const linuxExec = path.resolve(__dirname + '/../bin/linux_waiter');
const darwinExec = path.resolve(__dirname + '/../bin/kqueue_darwin');

const cmd = isDarwin ?
  // `lsof -p ${grandParentPid} +r 1 &>/dev/null` :
  `${darwinExec} ${grandParentPid}` :
  `${linuxExec} ${grandParentPid}`;

k.stderr.pipe(process.stderr);

k.stdin.write(cmd);
k.stdin.end('\n');

console.log('quicklock child listening.');