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

__fastPipe_notWord="[^[:alnum:]_]"
__fastPipe_grep_regexp="^-$"
__fastPipe_sed_regexp="^s$notWord"

command_not_found_handle() {

    # lots of code taken from https://www.linuxjournal.com/content/bash-command-not-found
 
    local cmd="$1"
    local notWord="$__fastPipe_notWord"
    local grep_regexp="$__fastPipe_grep_regexp"
    local sed_regexp="$__fastPipe_sed_regexp"

    if [[ "$cmd" =~ ^\+?[0-9]+:$ ]]
    then
        # tail

        local one="${cmd/:/}"

        if [ "$one" = "0" ]
        then
            one=10
        fi

        shift

        tail -n "$one" "$@"

    elif [[ "$cmd" =~ ^:-?[0-9]+$ ]]
    then
        # head

        local one="${cmd/:/}"

        if [ "$one" = "0" ]
        then
            one=10
        fi

        shift

        head -n "$one" "$@"
    else
        if [[ "$cmd" =~ $sed_regexp || "$cmd" =~ $grep_regexp ]]
        then
            led "$@"
        else
            # command not found
            old_command_not_found_handle "$@"
            return $?
        fi
    fi
        
    return 127

}

multi_sed() {
    local arg
    local args=()
    local notWord="$__fastPipe_notWord"
    local regexp="$__fastPipe_sed_regexp"

    for arg in "$@"
    do
        if [[ "$arg" =~ $regexp ]]
        then
            args+=("-e" "$arg")
        else
            args+=("$arg")
        fi
    done

    sed "${args[@]}"
}

# line editor
#   - grep
#   s/ sed
#   1: tail
#   :1 head
led() {
    local arg
    local args=()

    local firstCmd=1
    local curCmd=""

    for arg in "$@"
    do
        if [ "$arg" = "-" ]
        then

            if [ "$curCmd" != "grep" ]
            then
                curCmd="grep"
                if !((firstCmd))
                then
                    args+=("|")
                fi
                firstCmd=0
                args+=("grep")
            fi

            args+=("-e")

            continue

        elif [[ "$arg" =~ s$notWord ]]
        then
            
            if [ "$curCmd" != "sed" ]
            then
                curCmd="sed"
                if !((firstCmd))
                then
                    args+=("|")
                fi
                firstCmd=0
                args+=("sed")
            fi

            args+=("-e" "$arg")

            continue

        fi

        args+=("$arg")

    done

    eval "${args[@]}"

}

# short alias for grep
g() {
    grep "$@"
}

# short alias for highlighting text with grep 
gh() {
    grep -e ^ -e "$@"
}
