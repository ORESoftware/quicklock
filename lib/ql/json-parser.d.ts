/// <reference types="node" />
import stream = require('stream');
export declare const marker = "quicklock";
export declare const eventName = "@quicklock-json";
export declare const writeToStream: (strm: stream.Writable, v: any) => void;
export declare const createParser: () => stream.Transform;
