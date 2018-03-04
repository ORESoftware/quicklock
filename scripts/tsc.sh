#!/usr/bin/env bash

set -e;

export ql_prevent_exit="yes";

ql_acquire_lock a

tsc -w