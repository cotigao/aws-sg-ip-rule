#!/bin/bash

function usage {
    echo "Add back revoked rule(s) : $0 a [-i <ipaddr/cidr>] <rule_name1> <rule_name1> ..."
    echo "          Update rule(s) : $0 u [-i <ipaddr/cidr>] <rule_name1> <rule_name2> ..."
    echo "          Revoke rule(s) : $0 r [-d (deletes the rulefile)] <rule_name1> <rule_name2> ..."
    exit 1
}

[ "$1" = "u" ] || [ "$1" = "a" ] || [ "$1" = "r" ] || usage
op="$1"
shift

while getopts "i:d" x; do
    case $x in
        i)
            ip="-i ${OPTARG}"
            ;;
        d)
            delete="-d"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $(expr $OPTIND - 1)

for x in $@; do
    echo "handling rule $x"
    ./aws-sg-ip-rule.sh "$op" $delete $ip -n "$x"
    echo ""
done
