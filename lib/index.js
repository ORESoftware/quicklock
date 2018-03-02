#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var fs = require("fs");
var path = require("path");
var cp = require("child_process");
var grandParentPid = parseInt(process.argv[2] || "0");
if (!grandParentPid) {
    throw new Error('quicklock: no pid passed at command line.');
}
console.log('quicklock: parent pid:', grandParentPid);
var mutexKey = process.argv[3];
if (!mutexKey) {
    console.error('quicklock warning: using pwd as default value for mutex key.');
    mutexKey = process.cwd();
}
var home = process.env.HOME;
var quicklockHome = path.resolve(home + '/.quicklock');
try {
    fs.mkdirSync(quicklockHome);
}
catch (err) {
    if (!/file already exists/gi.test(String(err.message))) {
        throw err;
    }
}
var cleanMutexKey = path.resolve(quicklockHome + '/' + String(mutexKey).replace(/\W+/g, '_'));
try {
    fs.writeFileSync(cleanMutexKey, String(process.pid), { flag: 'wx' });
}
catch (err) {
    console.error('quicklock:', err.message);
    console.error('quicklock: to remove lock, delete that file manually.');
    process.exit(1);
}
var unlockProcess = path.resolve(__dirname + '/unlock.js');
var to = setTimeout(function () {
    console.error('Could not launch quicklock child.');
    process.exit(1);
}, 3000);
var k = cp.spawn("node", [unlockProcess], {
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
var stdout = '';
k.stdout.on('data', function (d) {
    stdout += String(d);
    if (/quicklock child listening/ig.test(stdout)) {
        clearTimeout(to);
        process.exit(0);
    }
});
