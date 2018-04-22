#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var util = require("util");
if (process.env.ql_read_stdin === 'yes') {
    process.stdin.resume()
        .on('data', function (d) {
        console.log('stdin received:', util.inspect(d));
    });
    process.once('exit', function () {
        process.stdin.destroy();
    });
}
var to = parseInt(process.env.ql_timeout || process.env.ql_to || '0');
if (to) {
    setTimeout(function () {
        console.error("Error: timed out after " + to + " milliseconds.");
        process.exit(1);
    }, to);
}
console.log(process.env.ql_node_value);
