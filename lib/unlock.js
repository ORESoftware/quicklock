'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var cp = require("child_process");
var fs = require("fs");
var path = require("path");
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
    console.error('unlock process is exiting...');
    fs.rmdirSync(filePath);
});
var strm = fs.createWriteStream(process.cwd() + '/debug-unlock.log');
strm.write('filepath in unlock:' + filePath);
var k = cp.spawn("bash", [], {
    detached: true
});
k.stderr.setEncoding('utf8');
k.stdout.setEncoding('utf8');
k.stderr.pipe(strm, { end: false });
k.stdout.pipe(strm, { end: false });
k.once('exit', function () {
    console.log('wait process is exiting.');
    try {
        fs.rmdirSync(filePath);
    }
    finally {
        process.exit(0);
    }
});
var linuxExec = path.resolve(__dirname + '/../bin/linux_waiter');
var darwinExec = path.resolve(__dirname + '/../bin/kqueue_darwin');
var cmd = isDarwin ?
    darwinExec + " " + grandParentPid :
    linuxExec + " " + grandParentPid;
k.stderr.pipe(process.stderr);
k.stdin.write(cmd);
k.stdin.end('\n');
console.log('quicklock child listening.');
