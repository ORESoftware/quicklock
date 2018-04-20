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
  ql_pid?: number
}

const s = net.createServer(function (socket: QuicklockSocket) {
  
  console.log('new connection:', socket.localAddress, socket.address());
  
  socket.on('data', function (d) {
      console.log('raw data from socket:', String(d));
  })
  .pipe(createParser())
  .on(eventName, function (v: any) {
  
    socket.write('received\n');
    
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
      
      let s;
      if (s = map.get(v.lockHolderPID)) {
        writeToStream(s, {releaseLock: true, lockName: v.lockName});
      }
      else {
        console.error('no socket connection with pid:', v.lockHolderPID);
      }
    }
    
    if(v.isResponse === true && v.releaseLock === true){
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
  // use an emphemeral port
  const port = s.address().port;
  cp.execSync(`mkdir -p ${dir}`);
  fs.writeFileSync(portFile, port, {encoding: 'utf8', flag: 'w'});
  console.log('Listening on port:', port);
});

