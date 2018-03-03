#!/usr/bin/env bash

set -e;

ql_gray='\033[1;30m'
ql_magenta='\033[1;35m'
ql_cyan='\033[1;36m'
ql_orange='\033[1;33m'
ql_green='\033[1;32m'
ql_no_color='\033[0m'


cd "$HOME"

mkdir -p "$HOME/.quicklock/locks"

curl -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/oresoftware/quicklock/master/ql.sh?$(date +%s)" \
--output "$HOME/.quicklock/ql.sh"

echo "";
echo -e "${ql_green} => quicklock download succeeded.${ql_no_color}";
echo -e "${ql_cyan} => To complete installation of 'quicklock' add the following line to your .bash_profile file:${ql_no_color}";
echo "  echo \"loading quicklock\" && . \"\$HOME/.quicklock/ql.sh\"";  # `.` is like `source` but more cross-platform
echo "";


# that's it lulz


