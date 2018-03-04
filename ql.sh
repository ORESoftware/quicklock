#!/usr/bin/env bash

export ql_quicklock_version="0.0.104"

export ql_gray='\033[1;30m'
export ql_magenta='\033[1;35m'
export ql_cyan='\033[1;36m'
export ql_orange='\033[1;33m'
export ql_green='\033[1;32m'
export ql_no_color='\033[0m'


ql_log_colors (){
    echo "sourcing quicklock.sh"
    echo -e "${ql_cyan}sourcing quicklock.sh${ql_no_color}";
    echo "${ql_cyan}sourcing quicklock.sh${ql_no_color}";
}

ql_add_color(){
    export ql_gray='\033[1;30m'
    export ql_magenta='\033[1;35m'
    export ql_cyan='\033[1;36m'
    export ql_orange='\033[1;33m'
    export ql_green='\033[1;32m'
    export ql_no_color='\033[0m'
}

ql_print_version (){
  echo "${ql_quicklock_version}";
}

 on_ql_trap (){
   echo "quicklock: process with pid '$$' caught/trapped a signal.";
   echo "quicklock: signal trapped: '$1'."
   ql_release_lock
}

 on_ql_conditional_exit (){

   if [[ $- == *i* ]]; then
       # if we are in a terminal just return, do not exit.
       # debugging: echo -e "${ql_orange}quicklock: since we are in a terminal, not exiting.${ql_no_color}";
      return 1;
   fi

    # debugging:  echo -e "${ql_orange}quicklock: since we are not in a terminal, we are exiting...${ql_no_color}";

    if [[ "$ql_fail_fast" == "yes" || "$ql_fast_fail" == "yes" ]]; then
       exit 1;
    fi

    return 1;

}


 ql_ls () {
   local home="$HOME/.quicklock/locks"
   for i in $(ls "$HOME/.quicklock/locks"); do  echo -e "${ql_cyan}$home/$i${ql_no_color}"; done;
}

 ql_find () {

    local lockname="$quicklock_name";

    if [[ ! -z "$1" ]]; then
      lockname="$1";
    fi

    if [[ -z "$lockname" ]]; then
          echo "quicklock: no lockname is available, defaulting to \$PWD as lockname.";
          lockname="$PWD";
     fi

    if [[ "$lockname" != "$HOME/.quicklock/locks/"* ]]; then

       lockname=$(echo "${lockname}" | tr "/" _)

      if [[ "$lockname" =~ [^a-zA-Z0-9\-\_] ]]; then
        echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
        on_ql_conditional_exit
        return 1;
      fi

       lockname="$HOME/.quicklock/locks/${lockname}.lock";
    fi

   if [[ -z "$lockname" ]]; then
      echo "quicklock: no lockname is available, please pass a valid lockname.";
      return 1;
   fi

    # echo the contents of the directory, should log PID if exists
    ls "$lockname" || {
       echo "quicklock: it does not appear that the lock exists for lockname: '$lockname'"
       return 1;
     }
}

ql_remove_all_locks (){
   rm -rf "$HOME/.quicklock/locks/"*
}


ql_acquire_lock () {

  local name="${1:-$PWD}"  # the lock name is the first argument, if that is empty, then set the lockname to $PWD
  mkdir -p "$HOME/.quicklock/locks"
  fle=$(echo "${name}" | tr "/" _)

  if [[ "$fle" =~ [^a-zA-Z0-9\-\_] ]]; then
    echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
    echo -e "${ql_magenta}quicklock: could not acquire lock with desired name -> '$fle'.${ql_no_color}"
    on_ql_conditional_exit
    return 1;
  fi

  local qln="$HOME/.quicklock/locks/${fle}.lock"

  mkdir "${qln}" &> /dev/null || {
    echo -e "${ql_magenta}quicklock: could not acquire lock with name '${qln}'${ql_no_color}";
    echo -e "${ql_magenta}quicklock: someone else is using that lockname.${ql_no_color}";
    on_ql_conditional_exit;
    return 1;
  }

  mkdir "${qln}/$$";  # add the PID inside the lock dir
  export quicklock_name="${qln}";  # export the var *only if* above mkdir command succeeds

  trap on_ql_trap EXIT;
  trap on_ql_trap INT;
  trap on_ql_trap TERM;
  trap on_ql_trap SIGINT;
  trap on_ql_trap SIGTERM;
  trap on_ql_trap SIGHUP;
  trap on_ql_trap SIGTRAP;

  echo "process has trapped all signals.";
#  trap on_ql_trap SIGINT;
#  trap on_ql_trap SIGTERM;
#  trap on_ql_trap SIGHUP
#  trap on_ql_trap HUP;

  echo "process id requesting lock: $$"
  echo "parent of id: $(ps -o ppid= -p $$)";
  echo -e "${ql_green}quicklock: acquired lock with name '${qln}'${ql_no_color}"
#  wait;

}


 ql_maybe_fail () {

  if [[ "$ql_fail_fast" == "yes" || "$ql_fast_fail" == "yes" ]]; then
      echo -e "${ql_magenta}quicklock: exiting with 1 since fail flag was set for your 'ql_release_lock' command.${ql_no_color}"
      on_ql_conditional_exit;
      return 1;
  else
      echo -e "${ql_orange}quicklock: \"\$ql_fail_fast\" was not set to \"yes\", so no error occurs if no lock was released.${ql_no_color}";
      return 1;
  fi

}


 ql_release_lock () {

   if [[ ! -z "$1" ]]; then
        quicklock_name="${1}";

   elif [[ -z "${quicklock_name}" ]]; then
        echo -e "${ql_orange}quicklock: warning - no quicklock_name available so defaulted to \$PWD.${ql_no_color}";
        quicklock_name="$PWD";
   fi

   if [[ "$quicklock_name" != "$HOME/.quicklock/locks/"* ]]; then

       quicklock_name=$(echo "${quicklock_name}" | tr "/" _)

      if [[ "$quicklock_name" =~ [^a-zA-Z0-9\-\_] ]]; then
        echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
        echo -e "${ql_magenta}quicklock: could not release lock with desired name -> '$fle'.${ql_no_color}"
        on_ql_conditional_exit
        return 1;
      fi

       quicklock_name="$HOME/.quicklock/locks/${quicklock_name}.lock";
   fi

   if [[ -z "${quicklock_name}" ]]; then
     echo -e "${ql_orange}quicklock: no lockname was defined. (\$quicklock_name was not set).${ql_no_color}";
     ql_maybe_fail;
     return 1;
   fi

   if [[ "$HOME" == "${quicklock_name}" ]]; then
     echo -e "${ql_orange}quicklock: dangerous value set for \$quicklock_name variable..was equal to user home directory, not good.${ql_no_color}";
     ql_maybe_fail;
     return 1;
   fi

   rm -r "${quicklock_name}" &> /dev/null &&
   { echo -e "${ql_green}quicklock: lock with name '${quicklock_name}' was released.${ql_no_color}";  } ||
   { echo -e "${ql_magenta}quicklock: no lock existed for lockname '${quicklock_name}'.${ql_no_color}"; ql_maybe_fail; }

   trap - EXIT; # clear/unset trap
   trap - SIGINT; # clear/unset trap
   trap - SIGTERM; # clear/unset trap
   trap - INT; # clear/unset trap
   trap - TERM; # clear/unset trap
   trap - SIGHUP; # clear/unset trap
   trap - SIGTRAP; # clear/unset trap

}

ql_no_color () {
    export ql_gray=''
    export ql_magenta=''
    export ql_cyan=''
    export ql_orange=''
    export ql_green=''
    export ql_no_color=''
}

ql_no_colors(){
  ql_no_color
}

ql_add_colors(){
 ql_add_color
}

# export all of the functions

export -f ql_add_colors;
export -f ql_add_color;

export -f ql_no_color;
export -f ql_no_colors;

export -f ql_remove_all_locks
export -f ql_log_colors;
export -f ql_maybe_fail;
export -f on_ql_conditional_exit;
export -f on_ql_trap;
export -f ql_acquire_lock;
export -f ql_release_lock;
export -f ql_find;
export -f ql_ls;
export -f ql_print_version;


# that's it lulz

