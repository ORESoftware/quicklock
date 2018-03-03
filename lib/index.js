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
var quicklocksHm = path.resolve(quicklockHome + '/locks');
try {
    fs.mkdirSync(quicklockHome);
}
catch (err) {
    if (!/file already exists/gi.test(String(err.message))) {
        throw err;
    }
}
try {
    fs.mkdirSync(quicklocksHm);
}
catch (err) {
    if (!/file already exists/gi.test(String(err.message))) {
        throw err;
    }
}
var cleanMutexKey = path.resolve(quicklocksHm + '/' + String(mutexKey).replace(/\W+/g, '_') + '.lock');
console.log('quicklock: quicklock mutex key:', cleanMutexKey);
try {
    var files = fs.readdirSync(quicklocksHm);
    console.log('the files before:', files);
    fs.mkdirSync(cleanMutexKey);
    console.log('created mutex key dir.');
    files = fs.readdirSync(quicklocksHm);
    console.log('the files after:', files);
}
catch (err) {
    console.error('quicklock:', err.message);
    console.error('quicklock: to remove lock, delete that file manually.');
    process.exit(1);
}
var unlockProcess = path.resolve(__dirname + '/unlock.js');
var k = cp.spawn("node", [unlockProcess], {
    detached: true,
    env: Object.assign({}, process.env, {
        QUICKLOCK_FILEPATH: cleanMutexKey,
        QUICKLOCK_GRANDPARENT_PID: String(grandParentPid)
    })
});
k.unref();
var stdout = '';
k.stdout.on('data', function (d) {
    stdout += String(d);
    if (/quicklock child listening/ig.test(stdout)) {
        k.stdout.removeAllListeners();
        k.unref();
    }
});
