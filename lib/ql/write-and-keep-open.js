#!/usr/bin/env node
'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
var util = require("util");
process.stdin.resume()
    .on('data', function (d) {
    console.log('stdin received:', util.inspect(d));
});
process.once('exit', function () {
    process.stdin.destroy();
});
console.log(process.env.ql_node_value);
