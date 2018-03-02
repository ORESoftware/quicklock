'use strict';

import cp = require('child_process');
import fs = require('fs');
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
  fs.unlinkSync(filePath);
});

const k = cp.spawn(`bash`);

k.stderr.setEncoding('utf8');

k.once('exit', function () {
  try {
    fs.unlinkSync(filePath);
  }
  finally {
    process.exit(0);
  }
});

// tail --pid=11666  # tail --pid=11666 -f /dev/null

const cmd = isDarwin ?
  // `lsof -p ${grandParentPid} +r 1 &>/dev/null` :
  `${__dirname}/kq ${grandParentPid}` :
  `tail --pid=${grandParentPid} -f /dev/null`;

k.stderr.pipe(process.stderr);
k.stdin.write(cmd);
k.stdin.end('\n');

console.log('quicklock child listening.');