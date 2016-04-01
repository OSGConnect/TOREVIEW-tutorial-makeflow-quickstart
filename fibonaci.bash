#!/bin/bash

fib2() {
    local f
    ((f=$1+$2))
    printf '%i %i\n' "$f" "$1"
}

fib()
{
    local i j
    j=$1
    shift
    for((i=1; i<j; ++i)); do
        set -- $(fib2 ${1-1} ${2-0})
        printf '%s\n' "${1-$i}"
    done
}

#Main Program.
fib "$1"

