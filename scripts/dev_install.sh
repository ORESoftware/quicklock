#!/usr/bin/env bash


curl -H 'Cache-Control: no-cache' -o- \
https://raw.githubusercontent.com/oresoftware/quicklock/master/install.sh?$(date +%s) | bash