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
__fastPipe_sed_regexp="^s$__fastPipe_notWord"
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
        __fastpipe_led "$@"
    else
        # command not found
        old_command_not_found_handle "$@"
        return $?
    fi

}

# line editor
#   - grep
#   s/ sed
#   1: tail
#   :1 head
__fastpipe_led() {
    local notWord="$__fastPipe_notWord"

    local arg
    local args=()

    local firstCmd=1
    local curCmd=""

    local sedDelim=""
    local sedToken=0
    local sedExpression=""

    for arg in "$@"
    do

        if [ "$curCmd" = "sed" ] && (( 1 <= sedToken && sedToken <= 2))
        then

            sedExpression="$sedExpression${sedDelim}$arg"
            ((sedToken++))

            continue

        elif [ "$curCmd" = "sed" ] && ((sedToken == 3)) 
        then

            sedToken=0

            if [ "${arg:0:1}" = "$sedDelim" ]
            then

                arg="${arg:1}"
                sedExpression="$sedExpression${sedDelim}$arg"

                args+=("'$sedExpression'")

                sedExpression=""
                sedToken=0
                
                continue

            else

                args+=("'$sedExpression$sedDelim'")

                sedExpression=""
                sedToken=0

            fi


        fi

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

            sedDelim="${arg:1:1}"
            sedToken=1
            sedExpression="s"

            args+=("-e")

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

            args+=("tail" "-n" "'$arg'")

        elif [[ "$arg" =~ $__fastPipe_head_regexp ]]
        then
            # head

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

            args+=("head" "-n" "'$arg'")

        else

            args+=("'$arg'")

        fi

    done

    if [ "$curCmd" = "sed" ] && ((sedToken == 3)) 
    then
        args+=("'$sedExpression$sedDelim'")
    fi

    if [ "$FASTPIPE_DEBUG" ]
    then
        echo "${args[@]}"
    fi

    eval "${args[@]}"

}
