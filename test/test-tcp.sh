#!/usr/bin/env bash


exec 3<>"/dev/tcp/localhost/$(ql_get_server_port)" # persistent file descriptor

exec 3<>`nc localhost $(ql_get_server_port)` # persistent file descriptor
