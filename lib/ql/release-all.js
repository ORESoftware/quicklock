#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var fs = require("fs");
var cp = require("child_process");
var pid = process.env.ql_pid;
var isForce = process.env.ql_force === 'yes';
if (!pid) {
    throw new Error('No pid passed via env var ("ql_pid").');
}
var file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');
try {
    fs.writeFileSync(file, '{}', { flag: 'wx' });
}
catch (err) {
}
var locks = require(file);
var copy = {};
Object.keys(locks).forEach(function (k) {
    var lock = locks[k];
    try {
        if (isForce === true || lock.deleteOnExit === true) {
            var name = lock['fullLockPath'];
            console.log(name);
            cp.execSync("rm -rf " + name + ";");
        }
        else {
            copy[k] = locks[k];
        }
    }
    catch (err) {
        console.error(err);
    }
});
fs.writeFileSync(file, JSON.stringify(copy), { flag: 'w' });
