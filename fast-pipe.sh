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
 
    local cmd="$1"

    if [[ "$cmd" =~ ^\+?[0-9]:$ ]]
    then
        # tail
        shift
        tail -n "${cmd/:/}" "$@"
    elif [[ "$cmd" =~ ^:-?[0-9]$ ]]
    then
        # head
        shift
        head -n "${cmd/:/}" "$@"
    elif [[ "$cmd" =~ ^s! ]]
    then
        # sed 
        sub "$@"
    elif [[ "$cmd" =~ ^\\.*\\$ ]]
    then
        # grep 
        multi_grep "$@" 
    else
        # command not found
        old_command_not_found_handle "$@"
        return $?
    fi
        
    return 127

}

# Substitute with sed.
# sub "s/pattern/replacement/flags" "s/pattern/replacement/flags" "s/pattern/replacement/flags" ...
# is run as: sed -e "s/pattern/replacement/flags" -e ...
sub() {
    local args=()
    local s

    for s in "$@"
    do
        args+=("-e" "$s")
    done

    sed "${args[@]}"
}


multi_grep() {
    local arg
    local args=()

    for arg in "$@"
    do
        if [[ "$arg" =~ ^\\.*\\$ ]]
        then
            # remove leading and trailing \
            arg="$(echo "$arg" | sed -e 's/^\\\|\\$//g')"
            args+=("-e" "$arg")
        else
            args+=("$arg")
        fi
    done

    grep "${arg[@]}"

}

# short alias for grep
g() {
    grep "$@"
}

# short alias for highlighting text with grep 
gh() {
    grep -e ^ -e "$@"
}
