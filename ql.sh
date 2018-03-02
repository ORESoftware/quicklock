#!/usr/bin/env bash

ql_gray='\033[1;30m'
ql_magenta='\033[1;35m'
ql_cyan='\033[1;36m'
ql_orange='\033[1;33m'
ql_green='\033[1;32m'
ql_no_color='\033[0m'

function on_ql_trap {
   echo "quicklock: process with pid $$ was trapped.";
   ql_release_lock
}

function on_ql_conditional_exit {
   if [ -t 1 ]; then        # tty -s
        # if we are in a terminal just return, do not exit.
        echo -e "${ql_orange}quicklock: since we are in a terminal, not exiting.${ql_no_color}";
        return 0;
    else
        echo -e "quicklock: since we are not in a terminal, we are exiting...";
        exit 1;
    fi
}


function ql_ls {
   for i in $(ls "$HOME/.quicklock/locks"); do  echo -e "${ql_cyan}$HOME/.quicklock/locks/$i${ql_no_color}"; done;
}

function ql_find {
    for f in "$HOME/.quicklock/locks"/*; do
      echo -e "${ql_cyan}$f${ql_no_color}"
    done
}

function ql_acquire_lock {
  ##### //////////////////////////////////////////////////////////////////////////////////////////
  set -e;

  name="${1:-$PWD}"  # the lock name is the first argument, if that is empty, then set the lockname to $PWD
  mkdir -p "$HOME/.quicklock/locks"
  fle=$(echo "${name}" | tr "/" _)

  if [[ "$fle" =~ [^a-zA-Z0-9\-] ]]; then
    echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
    echo -e "${ql_magenta}quicklock: could not acquire lock.${ql_no_color}"
    on_ql_conditional_exit
    return 0;
  fi

  qln="$HOME/.quicklock/locks/${fle}.lock"

  mkdir "${qln}" &> /dev/null || {
    echo -e "${ql_magenta}quicklock: could not acquire lock with name '${qln}'${ql_no_color}.";
    on_ql_conditional_exit;
    return 0;
  }

  export quicklock_name="${qln}";  # export the var *only if* above mkdir command succeeds
  trap on_ql_trap EXIT;
  echo -e "${ql_green}quicklock: acquired lock with name '${qln}'${ql_no_color}."
  #### \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
}


function ql_maybe_fail {
  ##### //////////////////////////////////////////////////////////////////////////////////////////
  if [[ "$ql_fail_fast" == "yes" ]]; then
      echo -e "${ql_magenta}quicklock: exiting with 1 since fail flag was set for your 'ql_release_lock' command.${ql_no_color}"
      on_ql_conditional_exit;
      return 0;
  fi
  #### \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
}


function ql_release_lock () {

   if [[ ! -z "$1" ]]; then
        quicklock_name="$1";
   fi

   if [[ "$quicklock_name" != "$HOME/.quicklock/locks/"* ]]; then
       quicklock_name="$HOME/.quicklock/locks/${quicklock_name}.lock";
   fi

   if [[ -z "${quicklock_name}" ]]; then
     echo -e "${ql_orange}quicklock: no lockname was defined. (\$quicklock_name was not set).${ql_no_color}";
     ql_maybe_fail;
     return 0;
   fi

   if [[ "$HOME" == "${quicklock_name}" ]]; then
     echo -e "${ql_orange}quicklock: dangerous value set for \$quicklock_name variable..was equal to user home directory, not good.${ql_no_color}";
     ql_maybe_fail;
     return 0;
   fi

   rm -r "${quicklock_name}" &> /dev/null &&
   { echo -e "${ql_green}quicklock: lock with name '${quicklock_name}' was released.${ql_no_color}";  } ||
   { echo -e "${ql_magenta}quicklock: no lock existed for lockname '${quicklock_name}'.${ql_no_color}"; ql_maybe_fail; }
   trap - EXIT  # clear/unset trap

}


