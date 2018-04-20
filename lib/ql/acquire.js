#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var fs = require("fs");
var pid = process.env.ql_pid;
var lockname = process.env.ql_lock_name;
var fullLockPath = process.env.ql_full_lock_path;
if (!pid) {
    throw new Error('No pid passed via env var ("ql_pid").');
}
if (!lockname) {
    throw new Error('No lockname passed via env var ("ql_lock_name").');
}
var file = path.resolve(process.env.HOME + '/.quicklock/pid_lock_maps/' + pid + '.json');
try {
    fs.writeFileSync(file, '{}', { flag: 'wx' });
}
catch (err) {
}
var locks = require(file);
if (locks[lockname]) {
    throw new Error("Lockname with name \"" + lockname + "\" is already being used, by pid \"" + pid + ".\"");
}
locks[lockname] = {
    date: new Date().toISOString(),
    fullLockPath: fullLockPath
};
fs.writeFileSync(file, JSON.stringify(locks));