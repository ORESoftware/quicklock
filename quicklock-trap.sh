#!/usr/bin/env bash


function onqltrap {
   echo "quicklock: process with pid $$ was trapped.";
   ql_release_lock
}

function qltrap {
   trap onqltrap EXIT;
}

function ql_acquire_lock {
  set -e;
  name="${1:-$PWD}"
  mkdir -p "$HOME/.quicklock/locks"
  fle=$(echo "${name}" | tr "/" _)
  qln="$HOME/.quicklock/locks/${fle}.lock"
  mkdir "${qln}" || { echo "quicklock: could not acquire lock."; exit 1; }
  export quicklock_name="${qln}";
  trap onqltrap EXIT;
  echo "quicklock: acquired lock with name '${qln}'."
}

function ql_maybe_fail {
  if [[ "$1" == "true" ]]; then
      echo "quicklock: exiting with 1 since fail flag was set for your 'ql_release_lock' command. "
      exit 1;
  fi
}

function ql_release_lock () {

   if [[ -z "${quicklock_name}" ]]; then
     echo "quicklock: no lockname was defined. (\$quicklock_name was not set).";
     ql_maybe_fail "$1";
     return 0;
   fi

   if [[ "$HOME" == "${quicklock_name}" ]]; then
     echo "quicklock: dangerous value set for \$quicklock_name variable..was equal to user home directory, not good.";
     ql_maybe_fail "$1"
     return 0;
   fi

   rm -rf "${quicklock_name}" || { echo "quicklock: no lock existed"; ql_maybe_fail "$1"; }
   echo "quicklock: lock with name '${quicklock_name}' was released.";
   trap - EXIT  # clear trap

}


