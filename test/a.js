"use strict";
exports.__esModule = true;
var suman = require("suman");
var Test = suman.init(module);
Test.create('fage', function (b) {
    var _a = b.getHooks(), describe = _a.describe, it = _a.it;
    describe('foo', function (b) {
        it('is cool', function (t) {
            t.assert(false);
        });
    });
});
