#!/bin/bash

function usage {
    echo "Add back revoked rule(s) : $0 a -n <rulefile1> <rulefile2> ..."
    echo "Update rule(s)           : $0 u -n <rulefile1> <rulefile2> ..."
    echo "Revoke rule(s)           : $0 r -n <rulefile1> <rulefile2> ..." 
    exit 1
}

[ "$1" = "u" ] || [ "$1" = "a" ] || [ "$1" = "r" ] || usage
op="$1"
shift

[ "$1" = "-n" ] || usage
shift

for x in $@; do
    echo "handling rule $x"
    ./aws-sg-ip-rule.sh "$op" -n "$x"
    echo ""
done
