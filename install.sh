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
mkdir -p "$HOME/.quicklock/nodejs"

curl -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/oresoftware/quicklock/master/ql.sh?$(date +%s)" \
--output "$HOME/.quicklock/ql.sh"

cache_location="$(npm config get cache)";

if [[ -z "$cache_location" ]]; then
  cache_location="$HOME/.npm"
fi

# clean the cache.... previously: npm cache clean --force;
rm -rf "$cache_location/quicklock" || {
  echo "no quicklock package in npm cache dir.";
}

(
  cd "$HOME/.quicklock/nodejs" && rm -rf package.json && npm init -f && npm install quicklock@latest
)

echo "";
echo -e "${ql_green} => quicklock download succeeded.${ql_no_color}";
echo -e "${ql_cyan} => To complete installation of 'quicklock' add the following line to your .bash_profile file:${ql_no_color}";
echo "  echo \"loading quicklock\" && . \"\$HOME/.quicklock/ql.sh\"";  # `.` is like `source` but more cross-platform
echo "";


# that's it lulz


