#!/usr/bin/env bash

set -e;

cd "$HOME"

mkdir -p "$HOME/.quicklock/locks"

curl -f https://raw.githubusercontent.com/oresoftware/quicklock/master/ql.sh --output "$HOME/.quicklock/ql.sh"

echo "To complete installation of 'quicklock' add the following line to your .bash_profile file:";

echo ". \"$HOME/.quicklock/ql.sh\"";

