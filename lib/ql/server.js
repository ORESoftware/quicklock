#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var net = require("net");
var map = new Map();
var json_parser_1 = require("./json-parser");
var fs = require("fs");
var path = require("path");
var cp = require("child_process");
var dir = path.resolve(process.env.HOME + '/.quicklock');
var portFile = path.resolve(process.env.HOME + '/.quicklock/server-port.json');
process.once('exit', function () {
    fs.writeFileSync(portFile, '', { encoding: 'utf8', flag: 'w' });
});
var s = net.createServer(function (socket) {
    console.log('new connection:', socket.localAddress, socket.address());
    socket.on('data', function (d) {
        console.log('raw data from socket:', String(d));
        socket.write('received_raw_data\n');
    })
        .pipe(json_parser_1.createParser())
        .on(json_parser_1.eventName, function (v) {
        socket.write("received_json => " + JSON.stringify(v) + "\n");
        if (!v) {
            console.error('Parsed JSON is not an object.');
            return;
        }
        if (v.init === true) {
            if (!v.pid) {
                console.error('"pid" property is not defined.');
                return;
            }
            socket.write("received init request!\n");
            var pidString = String(v.pid);
            console.error('setting pid:', pidString);
            socket.ql_pid = pidString;
            v.pid && map.set(pidString, socket);
            return;
        }
        if (v.isRequest === true && v.releaseLock === true && v.lockHolderPID) {
            var keys = Array.from(map.keys());
            keys.forEach(function (k) {
                console.log('here is a lockholder pid:', k);
            });
            socket.write("received release request!\n");
            var s_1;
            if (s_1 = map.get(String(v.lockHolderPID))) {
                socket.write("found socket lock holder for release request!\n");
                json_parser_1.writeToStream(s_1, { releaseLock: true, lockName: v.lockName, isResponse: true });
            }
            else {
                socket.write("no socket connection with pid! " + v.lockHolderPID + "\n");
                console.error('no socket connection with pid:', v.lockHolderPID);
                return;
            }
        }
        if (v.isResponse === true && v.releaseLock === true) {
            socket.write('released\n');
            return;
        }
        console.error('Switch fallthrough:', JSON.stringify(v));
    })
        .once('end', function () {
        console.log('socket disconnect.');
    });
});
s.listen(function () {
    var port = s.address().port;
    cp.execSync("mkdir -p " + dir);
    fs.writeFileSync(portFile, port, { encoding: 'utf8', flag: 'w' });
    console.log('Listening on port:', port);
});
