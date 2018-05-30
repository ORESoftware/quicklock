#!/usr/bin/env node
'use strict';

import net = require('net');
const map = new Map();
import {createParser, eventName, writeToStream} from './json-parser';
import fs = require('fs');
import path = require('path');
import cp = require('child_process');
import {Socket} from "net";

const dir = path.resolve(process.env.HOME + '/.quicklock');
const portFile = path.resolve(process.env.HOME + '/.quicklock/server-port.json');

export interface QuicklockSocket extends Socket {
  ql_pid?: string
}

process.once('exit', function () {
  // clear out the file
  fs.writeFileSync(portFile, '', {encoding: 'utf8', flag: 'w'});
});

const s = net.createServer(function (socket: QuicklockSocket) {
  
  console.log('new connection:', socket.localAddress, socket.address());
  
  socket.on('data', function (d) {
    console.log('raw data from socket:', String(d));
    socket.write('received_raw_data\n');
  })
  .pipe(createParser())
  .on(eventName, function (v: any) {
    
    socket.write(`received_json => ${JSON.stringify(v)}\n`);
    
    if (!v) {
      console.error('Parsed JSON is not an object.');
      return;
    }
    
    if (v.init === true) {
      
      if (!v.pid) {
        console.error('"pid" property is not defined.');
        return;
      }
      
      socket.write(`received init request!\n`);
      
      const pidString = String(v.pid);
      console.error('setting pid:', pidString);
      socket.ql_pid = pidString;
      v.pid && map.set(pidString, socket);
      return;
    }
    
    if (v.isRequest === true && v.releaseLock === true && v.lockHolderPID) {
      
      let keys = Array.from(map.keys());
      
      keys.forEach(function (k) {
        console.log('here is a lockholder pid:', k);
      });
      
      socket.write(`received release request!\n`);
      
      let s;
      if (s = map.get(String(v.lockHolderPID))) {
        socket.write(`found socket lock holder for release request!\n`);
        writeToStream(s, {releaseLock: true, lockName: v.lockName, isResponse: true});
      }
      else {
        socket.write(`no socket connection with pid! ${v.lockHolderPID}\n`);
        console.error('no socket connection with pid:', v.lockHolderPID);
        return;
      }
    }
    
    if (v.isResponse === true && v.releaseLock === true) {
      socket.write('released\n');
      return;
    }
    
    // Switch fallthrough: {"quicklock":true,"releaseLock":true,"lockName":"a","isRequest":true,"lockHolderPID":"9190"}
    console.error('Switch fallthrough:', JSON.stringify(v));
    
  })
  .once('end', function () {
    console.log('socket disconnect.');
  });
  
});

s.listen(function () {
  // use an emphemeral port
  const port = s.address().port;
  cp.execSync(`mkdir -p ${dir}`);
  fs.writeFileSync(portFile, port, {encoding: 'utf8', flag: 'w'});
  console.log('Listening on port:', port);
});

