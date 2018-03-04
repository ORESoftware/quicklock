#!/usr/bin/env bash

export ql_quicklock_version="0.0.104"
export ql_source_file="$HOME/.quicklock/ql.sh";

export ql_gray='\033[1;30m'
export ql_magenta='\033[1;35m'
export ql_cyan='\033[1;36m'
export ql_orange='\033[1;33m'
export ql_green='\033[1;32m'
export ql_no_color='\033[0m'



mkdir -p "$HOME/.quicklock"

# if [[ ! -p "$HOME/.quicklock/ql_named_pipe" ]]; then
#    mkfifo "$HOME/.quicklock/ql_named_pipe";
# fi

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

ql_echo_current_lockname (){
   echo $(ql_get_lockname)
}

on_ql_trap (){

#   echo "trippity trappity: $ql_no_more_trap";
#
#   if [[ "$ql_no_more_trap" == "yes" ]]; then
#      return 0;
#   fi

   echo "";
   echo "quicklock: process with pid '$$' caught/trapped a signal.";
#   echo "quicklock: signal trapped: '$1'."
   ql_release_lock
}

ql_unlock_process(){
  kill -SIGUSR1 "$1"  #  kill <pid> given by $1, with SIGUSR1 signal...
#  kill -SIGUSR2 "$1"

#  kill -10 "$1" $ on linux
# echo "$1" > "$HOME/.quicklock/ql_named_pipe"

#  kill -TERM "$1";
}


 on_ql_conditional_exit (){

   if [[ $- == *i* ]]; then
       # if we are in a terminal just return, do not exit.
       # debugging: echo -e "${ql_orange}quicklock: since we are in a terminal, not exiting.${ql_no_color}";
      return 1;
   fi

    # debugging:  echo -e "${ql_orange}quicklock: since we are not in a terminal, we are exiting...${ql_no_color}";

    if [[ "$ql_prevent_exit" == "yes" || "$ql_prevent_exit" == "yes" ]]; then
       return 1;
    fi

    exit 1;

}


 ql_ls () {
   local home="$HOME/.quicklock/locks"
   for i in $(ls "$HOME/.quicklock/locks"); do  echo -e "${ql_cyan}$home/$i${ql_no_color}"; done;
}


ql_write_message () {
    local lockname="$(ql_get_lockname "$1")";
    local pid="$(ql_get_lockowner_pid ${lockname})";
#   local pid="$(ql_get_lockowner_pid | head -n 1)";

   if [[  -z "$pid" ]]; then
       >&2 echo "quicklock: error: no pid could be found.";
       return 1;
   fi

   if [[ ! -p "${lockname}/${pid}" ]]; then
      >&2 echo -e "${ql_orange}quicklock: error - no named piped with path '${lockname}/${pid}'.${ql_no_color}";
      return 1;
   fi

   echo "foo" > "${lockname}/${pid}"
   echo "sent message"
}


ql_get_lockname (){

    local lockname="$1";

    if [[ -z "$lockname" ]]; then
        >&2 echo "quicklock: no lockname is available, defaulting to \$PWD as lockname.";
        lockname="$PWD";
    fi

    lockname=$(echo "${lockname}" | tr "/" _)

    if [[ "$lockname" =~ [^a-zA-Z0-9\-\_] ]]; then
         >&2 echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
        on_ql_conditional_exit
        return 1;
    fi

    if [[ "$lockname" != "$HOME/.quicklock/locks/"* ]]; then
       lockname="$HOME/.quicklock/locks/${lockname}.lock";
    fi

   if [[ -z "$lockname" ]]; then
      >&2 echo "quicklock: no lockname is available, please pass a valid lockname.";
      return 1;
   fi

   echo "$lockname"

}

ql_noop(){
    echo "";
}


 ql_get_lockowner_pid () {

    local lockname="$1";

    if [[ -z "$lockname" ]]; then
      lockname="$(ql_get_lockname)"
    fi

#    local lockname="$(ql_get_lockname "$1" | head -n 1)"

    # echo the contents of the directory, should log PID if exists

    ls "$lockname" || {
       >&2 echo "quicklock: it does not appear that the lock exists for lockname: '$lockname'"
       return 1;
     }
}

ql_remove_all_locks (){
   rm -rf "$HOME/.quicklock/locks/"*
}

ql_on_named_pipe_msg (){

  echo -e "quicklock: received piped message.";
  local ql_msg="$1";
  echo -e "${ql_magenta}quicklock: releasing lock because of piped message.${ql_no_color}"
  ql_release_lock

#     exit 1;
#     trap - EXIT;

}

ql_acquire_lock () {

  local name="${1}"  # the lock name is the first argument, if that is empty, then set the lockname to $PWD

  if [[ -z "$name" ]]; then
     echo -e "${ql_orange}quicklock: warning - no quicklock_name available so defaulted to \$PWD.${ql_no_color}"
     name="$PWD";
  fi

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

  my_named_pipe="${qln}/$$"
  mkfifo "${my_named_pipe}" &> /dev/null;  # add the PID inside the lock dir

  export ql_current_lockname="${qln}";
  trap on_ql_trap EXIT;

    #  trap on_ql_trap USR1;
    #  trap on_ql_trap USR2;
    #  trap on_ql_trap SIGUSR1;
    #  trap on_ql_trap SIGUSR2;
    #  trap on_ql_trap SIGHUP;
    #  trap on_ql_trap HUP;


  echo -e "${ql_gray}quicklock: process id requesting lock: $$, parent process id: $(ps -o ppid= -p $$)${ql_no_color}."
  echo -e "${ql_green}quicklock: acquired lock with name '${qln}'${ql_no_color}"

  if [[ "$ql_allow_ipc" == "yes" ]]; then

    echo -e "quicklock: process is reading from named pipe to listen for incoming messages regarding releasing lock.";
    while read line; do ql_on_named_pipe_msg "$line" "$$"; done < ${my_named_pipe} &

  fi

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

# mod: example
# txt: this module is an example for documentation.
#      The txt sections as also opt and env ones can
#      be multiline if lines are kept vertical aligned.

# fun: sum num1 num2
# txt: sum two numbers and output the result
# opt: num1: the first number to sum
# opt: num2: the second number to sum
# use: sum 1 3
# api: sum
ql_release_lock_force(){
  ql_release_lock "$@" --force
}


ql_release_lock () {

    local quicklock_name="$ql_current_lockname";
    local is_force="nope";

    local last="$(echo ${@: -1})"
    if [[ "${last}" == "--force" ]]; then
      echo -e "${ql_magenta}quicklock: warning using --force.${ql_no_color}";
      is_force="yes"
    fi

   if [[ ! -z "$1" && "$1" != "--force" ]]; then
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

   local current_pid="$$"
#   local pid_inside="$(ls "${quicklock_name}" | head -n 1)";
   local pid_inside="$(ls "${quicklock_name}" 2> /dev/null)";


   if [[ "${is_force}" != "yes" && ! -z "${pid_inside}" ]]; then
     if [[ "$current_pid" != "$pid_inside" ]]; then
     >&2 echo -e "${ql_magenta}quicklock: without using --force, cannot release lock that was initiated by a different pid.${ql_no_color}";
     return 1;
     fi
   fi


   rm -r "${quicklock_name}" &> /dev/null &&
   { echo -e "${ql_cyan}quicklock: lock with name '${quicklock_name}' was released.${ql_no_color}";  } ||
   { >&2 echo -e "${ql_magenta}quicklock: no lock existed for lockname '${quicklock_name}'.${ql_no_color}"; ql_maybe_fail; }

   export ql_no_more_trap="yes";
   trap - EXIT; # clear/unset trap
   trap ql_noop EXIT;

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
  # this is just an alias
  ql_no_color
}

ql_add_colors(){
  # this is just an alias
 ql_add_color
}

# export all of the functions

export -f ql_add_colors;
export -f ql_add_color;

export -f ql_no_color;
export -f ql_no_colors;

export -f ql_remove_all_locks
export -f ql_maybe_fail;
export -f on_ql_conditional_exit;
export -f on_ql_trap;
export -f ql_acquire_lock;
export -f ql_release_lock;
export -f ql_get_lockowner_pid;
export -f ql_ls;
export -f ql_print_version;
export -f ql_unlock_process;
export -f ql_on_named_pipe_msg;
export -f ql_echo_current_lockname;
export -f ql_get_lockname;
export -f ql_write_message;
export -f ql_noop;

# that's it lulz


