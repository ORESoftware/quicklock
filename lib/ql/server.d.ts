/// <reference types="node" />
import { Socket } from "net";
export interface QuicklockSocket extends Socket {
    ql_pid?: number;
}
