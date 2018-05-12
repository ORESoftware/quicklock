#!/usr/bin/env bash

export ql_quicklock_version="0.0.104"
export ql_source_file="$HOME/.quicklock/ql.sh";

export ql_gray='\033[1;30m'
export ql_magenta='\033[1;35m'
export ql_cyan='\033[1;36m'
export ql_orange='\033[1;33m'
export ql_green='\033[1;32m'
export ql_no_color='\033[0m'


export PATH="$PATH":"$HOME/.quicklock/nodejs/node_modules/.bin"
chmod u+x "$HOME/.quicklock/nodejs/node_modules/.bin/"*
mkdir -p "$HOME/.quicklock/pid_lock_maps"

# if [[ ! -p "$HOME/.quicklock/ql_named_pipe" ]]; then
#    mkfifo "$HOME/.quicklock/ql_named_pipe";
# fi

ql_tail_server_log(){
    tail -f "$HOME/.quicklock/server.log"
}

ql_tail_debug_log(){
    tail -f "$HOME/.quicklock/debug.log"
}

ql_get_server_port(){
 local port_file="$HOME/.quicklock/server-port.json"
 local my_str=$(cat "$port_file");
 echo "${my_str:-""}"
}

which_nodejs="$(which node)";
if [[ -z "$which_nodejs" ]]; then
    echo "quicklock depends on nodejs, and the 'node' executable."
    echo "quicklock recommends using NVM: https://github.com/creationix/nvm"
fi

# start the nodejs server
ql_start_node_server(){
   echo "starting a new server";
  ( ql_node_server &> "$HOME/.quicklock/server.log" & disown; )
  sleep 1;
}

ql_conditional_start_server(){

    typeset -i my_num=$(ql_get_server_port)

    if [[ -z "$my_num" ]]; then
      ql_kill_node_server;
      ql_start_node_server;
      echo "quicklock: started new tcp server."
      return 0;
    fi

    nc -zv localhost ${my_num}  > /dev/null 2>&1
    local nc_exit="$?"

    if [[ "${nc_exit}" -ne "0" ]]; then
         >&2 echo "quicklock: could not connect at port $my_num, restarting server.";
         >&2 echo "quicklock: to discover port use the ql_get_server_port command".
        ql_kill_node_server;
        ql_start_node_server;
    fi

}


#if [[ -z "$(ql_get_server_port)" ]]; then
#    ql_start_node_server;
# else
#    echo "node server already running";
#fi


ql_source_latest(){
  . "$HOME/.quicklock/ql.sh";
}


ql_uninstall(){
    rm -rf "$HOME/.quicklock"
}

ql_reinstall(){
  ql_uninstall
}


ql_get_next_int(){
   ( ql_acquire_lock ql_int_lock ) &> /dev/null
   local my_file="$HOME/.quicklock/next_int.json"
   touch "$my_file"
   local my_str=$(cat "$my_file");
   typeset -i my_num="${my_str:-"1"}"
   echo "$((++my_num))" | tee "$my_file"
   ( ql_release_lock ql_int_lock --force )   &> /dev/null
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

ql_echo_current_lockname (){
   echo $(ql_get_lockname)
}

on_ql_trap (){

   echo "";
   echo "quicklock: process with pid '$$' caught/trapped a signal.";
#   echo "quicklock: signal trapped: '$1'."

   ql_pid="$$" ql_node_release_all

#   ql_pid="$$" ql_node_release_all | while read lock; do
#     ql_release_lock "${lock}"
#   done;
}

ql_ps(){
  echo -e "${ql_gray}quicklock: current process id: $$, parent process id: $(ps -o ppid= -p $$)${ql_no_color}."
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

ql_match_arg(){
    # checks to see if the first arg, is among the remaining args
    # for example  ql_match_arg --json --json # yes
    first_item="$1";
    shift;
        for var in "$@"; do
            if [[ "$var" == "$first_item" ]]; then
              echo "yes";
              return 0;
            fi
        done
    return 1;
}

ql_kill_node_server(){
  echo "" > "$HOME/.quicklock/server-port.json"
  pkill -c -f "bin/ql_node_server" | while read line; do echo "Server instances killed: $line"; done;
}

ql_join_arry_to_json(){
      local arr=( "$@" );
      local len=${#arr[@]}

      if [[ ${len} -eq 0 ]]; then
        >&2 echo "Error: Length of input array needs to be at least 2.";
         return 1;
      fi

      if [[ $((len%2)) -eq 1 ]]; then
         >&2 echo "Error: Length of input array needs to be even (key/value pairs).";
         return 1;
      fi

      local data="";
      local foo=0;
      for i in "${arr[@]}"; do
          local char=","
          if [ $((++foo%2)) -eq 0 ]; then
               char=":";
          fi

          local first="${i:0:1}";  # read first charc

          local app="\"$i\""

          if [[ "$first" == "^" ]]; then
            app="${i:1}"  # remove first char
          fi

          data="$data$char$app";

      done

      data="${data:1}";  # remove first char
      echo "{$data}";    # add braces around the string
}


ql_ls () {
   local my_array=( "$@" );
   local ql_all=$(ql_match_arg "-a" "${my_array[@]}");

   if [[ "$ql_all" == "yes" ]]; then
      ql_ls_all $@;
      return 0;
   fi

   ql_json=$(ql_match_arg "--json" "${my_array[@]}");
   ql_pid="$$" ql_json="$ql_json" ql_node_ls_all;
}

ql_ls_all () {
   local home="$HOME/.quicklock/locks"
   for i in $(ls "$HOME/.quicklock/locks"); do
        echo -e "${ql_cyan}$home/$i${ql_no_color}";
   done;
}


ql_write_message () {
    local lockname="$(ql_get_lockname "$1")";
    local pid="$(ql_get_lockowner_pid ${lockname})";

   if [[  -z "$pid" ]]; then
       >&2 echo "quicklock: error: no pid could be found.";
       return 1;
   fi

   if [[ ! -p "${lockname}/${pid}" ]]; then
      >&2 echo -e "${ql_orange}quicklock: error - no named piped with path '${lockname}/${pid}'.${ql_no_color}";
      return 1;
   fi

   echo "foo" > "${lockname}/${pid}";
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
        on_ql_conditional_exit;
        return 1;
    fi

    if [[ "$lockname" != "$HOME/.quicklock/locks/"* ]]; then
       lockname="$HOME/.quicklock/locks/${lockname}.lock";
    fi

   if [[ -z "$lockname" ]]; then
      >&2 echo "quicklock: no lockname is available, please pass a valid lockname.";
      return 1;
   fi

   echo "$lockname";
}

ql_noop(){
    echo "";
}


ql_get_lockowner_pid () {

    local lockname="$(ql_get_lockname "$1")";

    if [[ -z "$lockname" ]]; then
        >&2 echo "quicklock: no lockname available.";
       return 1;
    fi

#    local lockname="$(ql_get_lockname "$1" | head -n 1)"
    # echo the contents of the directory, should log PID if exists

#    ls "$lockname" || {
#       >&2 echo "quicklock: it does not appear that the lock exists for lockname: '$lockname'"
#       return 1;
#     }

     # there are multiple files in the $lockname folder, we pick one of them (77148.input or 77148.output)
    ls "$lockname" | head -n 1 | cut -d '.' -f 1
}

ql_remove_all_locks (){
   local count=$(find "$HOME/.quicklock/locks" -mindepth 1 -maxdepth 1 -type d | wc -l);
   typeset -i my_num="${count}"
   rm -rf "$HOME/.quicklock/locks";
   mkdir -p "$HOME/.quicklock/locks";
   rm -rf "$HOME/.quicklock/pid_lock_maps";
   mkdir -p "$HOME/.quicklock/pid_lock_maps";
   echo "quicklock: ${my_num} lock(s) removed.";
}

ql_remove_locks(){
  local pid="$$";
  declare -i count=0;
  ql_pid="$pid" ql_node_ls_all | while read line; do
    count=$((count+1));
    echo "count: $count";
    echo "deleting lock: $line";
    rm -rf "$line";
  done;
  echo "quicklock: $count lock(s) removed."
}

ql_on_named_pipe_msg (){

  echo -e "quicklock: received piped message.";
  local ql_msg="$1";
  echo -e "${ql_magenta}quicklock: releasing lock because of piped message.${ql_no_color}";
  ql_release_lock;
}

ql_acquire_lock () {

   local my_array=( "$@" );
   local name="${1}"  # the lock name is the first argument, if that is empty, then set the lockname to $PWD

  if [[ -z "$name" ]]; then
     echo -e "${ql_orange}quicklock: warning - no quicklock_name available so defaulted to \$PWD.${ql_no_color}"
     name="$PWD";
  fi

  mkdir -p "$HOME/.quicklock/locks";

  local fle=$(echo "${name}" | tr "/" _);

  if [[ "$fle" =~ [^a-zA-Z0-9\-\_] ]]; then
    echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
    echo -e "${ql_magenta}quicklock: could not acquire lock with desired name -> '$fle'.${ql_no_color}"
    on_ql_conditional_exit
    return 1;
  fi

   local qln="$HOME/.quicklock/locks/${fle}.lock"

   mkdir "${qln}" &> /dev/null || {
    echo -e "${ql_magenta}quicklock: could *NOT* acquire lock with path '${qln}'${ql_no_color}";

    local pid_inside="$(ql_get_lockowner_pid "${fle}" 2> /dev/null)";

    if [[ "$pid_inside" == "$$" ]]; then
        echo -e "${ql_magenta}quicklock: this process already owns the desired lock.${ql_no_color}";
    else
        echo -e "${ql_magenta}quicklock: someone else is using that lockname (pid=$pid_inside).${ql_no_color}";
#        echo -e "${ql_magenta}quicklock: to ask them to release the lock use 'ql_ask_release $pid_inside $name').${ql_no_color}";
    fi

    on_ql_conditional_exit;
    return 1;
  }

  local ql_keep=$(ql_match_arg "--keep" "${my_array[@]}")

  # use node.js process to register lockname with this pid
  ql_keep="$ql_keep" ql_pid="$$" ql_lock_name="$fle" ql_full_lock_path="$qln" ql_node_acquire;

   local my_input="${qln}/$$"
   mkfifo "$my_input";

#  local my_input="${qln}/$$.input"
#  local my_output="${qln}/$$.output"
#
#  if [[ ! -f "${my_input}" ]]; then
#     # if the file does not exist we create it
#     mkfifo "${my_input}" &> /dev/null;  # add the PID inside the lock dir
#  fi
#
#   if [[ ! -f "${my_output}" ]]; then
#     # if the file does not exist we create it
#     mkfifo "${my_output}" &> /dev/null;  # add the PID inside the lock dir
#  fi

  trap on_ql_trap EXIT HUP QUIT TERM;
#   echo "input fifo: ${my_input}";
#   echo "output fifo: ${my_output}"
   echo -e "${ql_green}quicklock: acquired lock with name '${qln}'${ql_no_color}";

}

ql_go_home(){
  cd "$HOME/.quicklock";
  echo "$PWD";
}

ql_get_fifo(){
    local pid1="$1";
    local lock_name="$2";
    local full_lock_path=$(ql_get_lockname "$lock_name")
    local pid2=$(ql_get_lockowner_pid "$lock_name")
    if [[ "$pid1" != "$pid2" ]]; then
        >&2 echo "quicklock: pids are not equal, cannot retrieve fifo.";
        >&2 echo "quicklock: pid 1: $pid1";
        >&2 echo "quicklock: pid 2: $pid2";
        return 1;
    fi
    echo "$full_lock_path/$pid2"
}


ql_ask_release(){

   local pid="$1"
   local lock_name="$2"

   if [[ -z "$pid" ]]; then
      >&2 echo "need to pass pid as first argument.";
      return 1;
   fi

    if [[ -z "$lock_name" ]]; then
       >&2 echo "need to pass a lock_name as second argument.";
      return 1;
   fi

   echo "quicklock: request release of lock that is held by pid: $pid";

   local my_fifo="$(ql_get_fifo "$pid" "$lock_name")";
   local input_fifo="$my_fifo.input"
   local output_fifo="$my_fifo.output"

   # json=$(ql_join_arry_to_json quicklock ^true)

   if [[ -z "$input_fifo" ]]; then
     >&2 echo "Could not locate lock holder process.";
     return 1;
   fi

    if [[ -z "$output_fifo" ]]; then
     >&2 echo "Could not locate lock holder process.";
     return 1;
   fi

  local json=`cat <<EOF
  {"quicklock":true,"releaseLock":true,"lockName":"${lock_name}","isRequest":true,"lockHolderPID":"${pid}"}
EOF`

     set -o pipefail;

     (
        ql_node_value="$json" ql_write_and_keep_open  | while read line; do
              echo "writing this to input fifo: $line" >> "${input_fifo}" ;
              echo "$line" >> "${input_fifo}" ;
         done &
     ) &> /dev/null

    #    trap -- '' PIPE
    # | ql_timeout 2600

      echo "input fifo: ${input_fifo}";
      echo "output fifo: ${output_fifo}";

      tail -n0 -f "${output_fifo}" | ql_timeout 3600 | ql_receiver_lock_requestor | while read response; do
         echo "response from lock holder: $response";
         if [[ "$response" == "released" ]]; then
            echo "quicklock: Lock was released.";
            return 0;
         fi
      done;

     local exit_code=$?;
     set +o pipefail;
     #  trap - PIPE;

     if [[ "${exit_code}" -eq "0" ]]; then
        echo "quicklock: lock was released!";
        return 0;
     fi

    >&2 echo "quicklock: could not release lock.";
    return 1;
}


ql_start_test(){
  . ql.sh;
  ql_remove_all_locks;
  pgrep -f ".quicklock" | xargs kill -9
}

ql_connect(){
    ql_conditional_start_server;
}


ql_conditional_release(){
#   while read line; do ql_release_lock "$line"; done;
   while read line; do
       echo "got some stdin: $line" >> "$HOME/.quicklock/debug.log";
       echo "got some stdin: $line";
   done;
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


ql_release_lock_force(){
    ql_release_lock "$@" --force
}

ql_release_lock () {

    local my_array=( "$@" );
    local quicklock_name="";
    local is_force=$(ql_match_arg "--force" "${my_array[@]}")

    if [[ "${is_force}" == "yes" ]]; then
      echo -e "${ql_magenta}quicklock: warning using --force.${ql_no_color}";
    fi

   if [[ ! -z "$1" && "$1" != "--force" ]]; then
        quicklock_name="${1}";

    elif [[ -z "${quicklock_name}" ]]; then
        echo -e "${ql_orange}quicklock: warning - no quicklock_name available so defaulted to \$PWD.${ql_no_color}";
        quicklock_name="$PWD";
   fi

   local ql_full_lock_path="$quicklock_name";

   if [[ "$quicklock_name" != "$HOME/.quicklock/locks/"* ]]; then

       quicklock_name=$(echo "${quicklock_name}" | tr "/" _)

      if [[ "$quicklock_name" =~ [^a-zA-Z0-9\-\_] ]]; then
        echo -e "${ql_magenta}quicklock: lockname has invalid chars - must be alpha-numeric chars only.${ql_no_color}"
        echo -e "${ql_magenta}quicklock: could not release lock with desired name -> '$fle'.${ql_no_color}"
        on_ql_conditional_exit
        return 1;
      fi

       ql_full_lock_path="$HOME/.quicklock/locks/${quicklock_name}.lock";
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
    # local pid_inside="$(ls "${quicklock_name}" | head -n 1)";
   local pid_inside="$(ls "${ql_full_lock_path}" 2> /dev/null)";


   if [[ "${is_force}" != "yes" && ! -z "${pid_inside}" ]]; then
     if [[ "$current_pid" != "$pid_inside" ]]; then
     >&2 echo -e "${ql_magenta}quicklock: without using --force, cannot release lock that was initiated by a different pid.${ql_no_color}";
     return 1;
     fi
   fi

   if [[ -z "$pid_inside" ]]; then
      pid_inside="$$";
   fi

   # delete the lock in pid_lock_maps folder
   ql_pid="$pid_inside" \
   ql_lock_name="$quicklock_name" \
   ql_full_lock_path="$ql_full_lock_path" \
   ql_node_release;

   local exit_code="$?"

   if [[  "$exit_code" -ne "0" ]]; then
        >&2 echo -e "${ql_orange}quicklock warning: could not delete lock from lock maps dir.${ql_no_color}";
   fi

   # delete the main lock dir
   rm -r "${ql_full_lock_path}" &> /dev/null && {
        echo -e "${ql_cyan}quicklock: lock with name '${quicklock_name}' was released.${ql_no_color}";
   } ||
   {
        >&2 echo -e "${ql_magenta}quicklock: no lock existed for lock '${ql_full_lock_path}'.${ql_no_color}";
        ql_maybe_fail;
   };

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

ql_release_all_locks(){
  # this is just an alias
  ql_remove_all_locks
}



# export all of the functions
export -f ql_add_colors;
export -f ql_add_color;
export -f ql_no_color;
export -f ql_no_colors;
export -f ql_get_next_int;
export -f ql_release_all_locks
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
export -f ql_match_arg;
export -f ql_ps;
export -f ql_join_arry_to_json;
export -f ql_connect;
export -f ql_source_latest;
export -f ql_kill_node_server;
export -f ql_conditional_release;
export -f ql_get_server_port;
export -f ql_conditional_start_server;
export -f ql_tail_server_log;
export -f ql_tail_debug_log;


# that's it lulz


