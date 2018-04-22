#!/usr/bin/env bash

set -e;


mkdir -p "$HOME/.quicklock";
cat ql.sh > "$HOME/.quicklock/ql.sh";
source "$HOME/.quicklock/ql.sh";

npm link -f; #  link quicklock lib

(
  cd "$HOME/.quicklock/nodejs";
  npm link quicklock -f;
)