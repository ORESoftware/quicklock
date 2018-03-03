#!/usr/bin/env bash


set -e;

source ./ql.sh

export ql_fast_fail="yes"

ql_release_lock ttt

echo "zooom"