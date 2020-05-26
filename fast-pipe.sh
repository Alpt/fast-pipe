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
__fastPipe_tail_regexp="^\+?[0-9]+:$"
__fastPipe_head_regexp="^:-?[0-9]+$"

command_not_found_handle() {

    # lots of code taken from https://www.linuxjournal.com/content/bash-command-not-found
 
    local cmd="$1"
    local notWord="$__fastPipe_notWord"
    local grep_regexp="$__fastPipe_grep_regexp"
    local sed_regexp="$__fastPipe_sed_regexp"


    if [[ "$cmd" =~ $sed_regexp || "$cmd" =~ $grep_regexp || "$cmd" =~ $__fastPipe_tail_regexp || "$cmd" =~ $__fastPipe_head_regexp ]]
    then
        led "$@"
    else
        # command not found
        old_command_not_found_handle "$@"
        return $?
    fi

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

        elif [[ "$arg" =~ $__fastPipe_tail_regexp ]]
        then
            # tail

            arg="${arg/:/}"

            if [ "$arg" = "0" ]
            then
                arg=10
            fi

            if !((firstCmd))
            then
                args+=("|")
            fi
            firstCmd=0

            args+=("tail" "-n" "$arg")

        elif [[ "$cmd" =~ $__fastPipe_head_regexp ]]
        then
            # tail

            arg="${arg/:/}"

            if [ "$arg" = "0" ]
            then
                arg=10
            fi

            if !((firstCmd))
            then
                args+=("|")
            fi
            firstCmd=0

            args+=("head" "-n" "$arg")

        else

            args+=("$arg")

        fi

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
