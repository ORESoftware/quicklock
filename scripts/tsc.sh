#!/usr/bin/env bash

#set -e;

#export ql_prevent_exit="yes";

#tsc -w

. ql.sh;

ql_acquire_lock "$PWD/tsc";


tsc -w;

#sleep 500;

