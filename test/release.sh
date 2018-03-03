#!/usr/bin/env bash

#ps -p $PID -o pid=

set -e;

source ./ql.sh

ql_acquire_lock # "$PWD"

echo "foo"

ql_release_lock