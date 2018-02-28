"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var cp = require("child_process");
var fs = require("fs");
var os = require("os");
var filePath = process.env.QUICKLOCK_FILEPATH;
var grandParentPid = process.env.QUICKLOCK_GRANDPARENT_PID;
var isDarwin = String(os.platform()).toLowerCase() === 'darwin';
if (!filePath) {
    throw new Error('Quicklock error - missing filepath.');
}
if (!grandParentPid) {
    throw new Error('Quicklock error - missing grandParentPid.');
}
process.once('exit', function () {
    fs.unlinkSync(filePath);
});
var k = cp.spawn("bash");
k.stderr.setEncoding('utf8');
k.once('exit', function () {
    try {
        fs.unlinkSync(filePath);
    }
    finally {
        process.exit(0);
    }
});
var cmd = isDarwin ?
    "lsof -p " + grandParentPid + " +r 1 &>/dev/null" :
    "tail --pid=" + grandParentPid + " -f /dev/null";
k.stderr.pipe(process.stderr);
k.stdin.write(cmd);
k.stdin.end('\n');
console.log('quicklock child listening.');
