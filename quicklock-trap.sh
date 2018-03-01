#!/usr/bin/env bash


function onqltrap {
  echo "process with pid $$ was trapped.";
   rm -rf "${quicklock_name}";
}

function qltrap {
   trap onqltrap EXIT;
}

function qlstart {
#  set -e;
  name="${1:-$(pwd)}"
  mkdir -p "$HOME/.quicklock/locks"
  fle=$(echo "${name}" | tr "/" _)
  qln="$HOME/${fle}.lock"
  mkdir  "${qln}" || { echo "quicklock could not acquire lock."; exit 1; }
  export quicklock_name="${qln}";
  trap onqltrap EXIT;
}

echo "sourced";

#function qlstartold {
#   mkdir -p "$HOME/.quicklock/fifo"
#   rm "$HOME/.quicklock/fifo/$$.fifo"
#   mkfifo "$HOME/.quicklock/fifo/$$.fifo"
#}

