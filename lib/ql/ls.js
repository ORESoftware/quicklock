#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var path = require("path");
var fs = require("fs");
var pid = process.env.ql_pid;
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
    console.log(JSON.stringify(locks[k]));
});
