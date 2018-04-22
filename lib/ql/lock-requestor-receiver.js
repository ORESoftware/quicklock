#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var json_parser_1 = require("./json-parser");
console.log('in the receiver beginning...');
process.stdin.resume()
    .on('data', function () {
    console.log('data received in receiver...');
})
    .pipe(json_parser_1.createParser()).on(json_parser_1.eventName, function (v) {
    console.log('json received in receiver...', JSON.stringify(v));
    if (v.releaseLock === true && v.isResponse === true && v.lockName) {
        console.log(v.lockName);
        console.log('released.');
    }
    else {
        console.error('lockName not defined.');
    }
});