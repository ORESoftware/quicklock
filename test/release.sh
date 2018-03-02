#!/usr/bin/env bash

#ps -p $PID -o pid=


source /Users/alexamil/WebstormProjects/oresoftware/quicklock/ql.sh

ql_acquire_lock # "$PWD"

echo "foo"

ql_release_lock