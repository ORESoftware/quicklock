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
var s = net.createServer(function (socket) {
    console.log('new connection:', socket.localAddress, socket.address());
    socket.on('data', function (d) {
        console.log('raw data from socket:', String(d));
        socket.write('received_data\n');
    })
        .pipe(json_parser_1.createParser())
        .on(json_parser_1.eventName, function (v) {
        socket.write('received_json\n');
        if (!v) {
            console.error('Parsed JSON is not an object.');
            return;
        }
        if (v.init === true) {
            if (!Number.isInteger(v.pid)) {
                console.error('"pid" property is not an integer.');
                return;
            }
            console.error('setting pid');
            socket.ql_pid = v.pid;
            v.pid && map.set(v.pid, socket);
            return;
        }
        if (v.isRequest === true && v.releaseLock === true && Number.isInteger(v.lockHolderPID)) {
            var s_1;
            if (s_1 = map.get(v.lockHolderPID)) {
                json_parser_1.writeToStream(s_1, { releaseLock: true, lockName: v.lockName });
            }
            else {
                console.error('no socket connection with pid:', v.lockHolderPID);
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
