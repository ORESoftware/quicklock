"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var cp = require("child_process");
var fs = require("fs");
var filePath = process.env.QUICKLOCK_FILEPATH;
var grandParentPid = process.env.QUICKLOCK_GRANDPARENT_PID;
if (!filePath) {
    throw new Error('Quicklock error - missing filepath.');
}
if (!grandParentPid) {
    throw new Error('Quicklock error - missing grandParentPid.');
}
process.once('exit', function () {
    fs.unlinkSync(filePath);
});
setInterval(function () {
    try {
        cp.execSync("ps -p " + grandParentPid);
    }
    catch (err) {
        try {
            fs.unlinkSync(filePath);
        }
        finally {
            process.exit(0);
        }
    }
}, 500);
console.log('quicklock child listening.');
