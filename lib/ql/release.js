#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var fs = require("fs");
var pid = process.env.ql_pid;
var lockname = process.env.ql_lock_name;
var fulllockpath = process.env.ql_full_lock_path;
var isForce = process.env.ql_use_force === "yes";
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
if (!locks[lockname]) {
    console.error("Warning: Lockname with name \"" + lockname + "\" does not exist for pid \"" + pid + "\".");
}
delete locks[lockname];
fs.writeFileSync(file, JSON.stringify(locks));
