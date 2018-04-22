#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var json_parser_1 = require("./json-parser");
process.stdin.resume()
    .on('data', function (v) {
    console.error('json received in lock holder receiver...', v);
})
    .pipe(json_parser_1.createParser()).on(json_parser_1.eventName, function (v) {
    console.error('json received in receiver...', JSON.stringify(v));
    if (v.releaseLock === true && v.isRequest === true && v.lockName) {
        console.log(v.lockName);
        console.log('released.');
    }
    else {
        console.error('lockName not defined.');
    }
});
