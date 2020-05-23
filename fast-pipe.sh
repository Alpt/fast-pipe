#!/bin/bash

if declare -f command_not_found_handle > /dev/null 
then
    # save command_not_found_handle in old_command_not_found_handle
    eval "$(echo "old_command_not_found_handle()"; declare -f command_not_found_handle | tail -n +2)"
else
    old_command_not_found_handle() {
        echo "$1: command not found"
        return 127
    }
fi

command_not_found_handle() {

    # lots of code taken from https://www.linuxjournal.com/content/bash-command-not-found
 
    # check if we are in a pipe, otherwise fail as usual
    if [ -t 0 ]
    then
        old_command_not_found_handle "$@"
        return $?
    fi

    cmd="$1"

    if [[ "$cmd" =~ ^+?[0-9]:$ ]]
    then
        shift
        tail -n "$cmd" "$@"
    elif [[ "$cmd" =~ ^:-?[0-9]$ ]]
    then
        shift
        head -n "$cmd" "$@"
    else
        grep "$@"
    fi
        
    return 127

}

# Substitute with sed.
# sub "s/pattern/replacement/flags" "s/pattern/replacement/flags" "s/pattern/replacement/flags" ...
# is run as: sed -e "s/pattern/replacement/flags" -e ...
sub() {
    args=("-e" "$1")
    while shift
    do
        args+=("-e")
        args+=("$1")
        shift
    done
    sed "${args[@]}"
}

::() {
    grep "$@"
}
