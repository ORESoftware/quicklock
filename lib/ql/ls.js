#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var fs = require("fs");
var chalk_1 = require("chalk");
var pid = process.env.ql_pid;
var useJSON = process.env.ql_json === "yes";
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
Object.keys(locks).forEach(function (k) {
    if (useJSON) {
        console.log(JSON.stringify(locks[k]));
    }
    else {
        console.log(chalk_1.default.cyan(locks[k].fullLockPath));
    }
});
