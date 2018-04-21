#!/usr/bin/env bash

set -e;

cat ql.sh > "$HOME/.quicklock/ql.sh";
source "$HOME/.quicklock/ql.sh";

npm link  #  link quicklock lib

(
  cd "$HOME/.quicklock/nodejs";
  npm link quicklock;
)