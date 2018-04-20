'use strict';

import stream = require('stream');
import {Stream, Writable} from "stream";

/////////////////////////////////////////////////////////////////////////

export const marker = 'quicklock';
export const eventName = '@quicklock-json';

export const writeToStream = function (strm: Writable, v: any) {
  v[marker] = true;
  strm.write(JSON.stringify(v) + '\n');
};

export const createParser = function () {
  
  let lastLineData = '';
  
  const strm = new stream.Transform({
    
    objectMode: true,
    
    transform(chunk: any, encoding: string, cb: Function) {
      
      let data = String(chunk);
      if (lastLineData) {
        data = lastLineData + data;
      }
      
      let lines = data.split('\n');
      lastLineData = lines.splice(lines.length - 1, 1)[0];
      
      lines.forEach(l => {
        try {
          // l might be an empty string; ignore if so
          l && this.push(JSON.parse(l));
        }
        catch (err) {
          // noop
        }
      });
      
      cb();
      
    },
    
    flush(cb: Function) {
      if (lastLineData) {
        try {
          this.push(JSON.parse(lastLineData));
        }
        catch (err) {
          // noop
        }
      }
      lastLineData = '';
      cb();
    }
  });
  
  strm.on('data', function (d: any) {
    // console.log('data up in here:', d, d[marker]);
    if (d && d[marker] === true) {
      // console.log('emitting the thing', 'eventname:', eventName);
      strm.emit(eventName, d);
    }
  });
  
  return strm;
  
};