#!/bin/bash

set -o errexit
set -o pipefail

stn="https://api.ipify.org"

function usage {
 echo ""
 echo "             Add rule: $0 a -n <rule_name> -s <security_group_id> -f <start_in_tcp_port> -t <end_in_tcp_Port> [-i <ipaddr/cidr>]"
 echo "Update rule (only IP): $0 u -n <rule_name> [-i <ipaddr/cidr>]"
 echo "          Revoke rule: $0 r -n <rule_name> [-d (deletes the rulefile)]"
 echo ""
 exit 1
}

function run {
 set -o errexit
 set -o pipefail

 if [ "$1" = "r" ]; then
    if [[ $# < 2 ]]; then
       echo "1"
    elif [ -f "$2" ]; then
        IFS=',' read -r -a array < "$2"
        aws ec2 revoke-security-group-ingress --group-id ${array[1]} --ip-permissions '[{"IpProtocol": "tcp", "FromPort": '${array[2]}', "ToPort":  '${array[3]}', "IpRanges": [{"CidrIp" : "'${array[0]}'", "Description" : "'$(basename $2)'"}]}]'
        echo "SUCCESS: revoked "$(cat "$2")
        echo "${array[0]},${array[1]},${array[2]},${array[3]},revoked" > $2
        if [ ! -z $3 ]; then
            rm "$2"
        fi
    else
        echo "ERROR: $2 not found, can't revoke!"
    fi
 elif [ "$1" = "a" ]; then
    if [[ $# < 5 ]]; then
        echo "1"
    else
        if [ -z "$6" ]; then
            ip=$(curl -s ${stn})"/32"
        else
            ip="$6"
        fi
        aws ec2 authorize-security-group-ingress --group-id $3 --ip-permissions '[{"IpProtocol": "tcp", "FromPort": '$4', "ToPort": '$5', "IpRanges": [{"CidrIp": "'$ip'", "Description" : "'$(basename $2)'"}]}]'
        echo "$ip,$3,$4,$5" > $2
        echo "SUCCESS: updated security group $3 to allow $ip, (start-tcp-port: $4, end-tcp-port: $5), saved to file $2"
    fi
 else
    echo "1"
 fi
}

echo ""

[ "$1" = "u" ] || [ "$1" = "a" ] || [ "$1" = "r" ] || usage

op="$1"
shift

while getopts "f:t:n:ds:i:" x; do
    case $x in
        n)
            name=${OPTARG}
            ;;
        s)
            sg=${OPTARG}
            ;;
        f)
            from=${OPTARG}
            ;;
        t)
            to=${OPTARG}
            ;;
        d)
            delete=true
            ;;
        i)
            cidr=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ "$op" = "a" ] && [ -v name ]  && [ -f "$name" ]; then
    if [ -v sg ] && [ -v from ] && [ -v to ]; then
        :
    elif [ ! -v sg ] && [ ! -v from ] && [ ! -v to ]; then
        :
    else
        echo "ERROR: $name: need to either give all (security group and ports) or nothing!"
        usage
    fi
elif [ "$op" = "a" ] && [ -v name ] && [ -v sg ] && [ -v from ] && [ -v to ]; then
    :
elif [ "$op" = "u" ] && [ -v name ]; then
    :
elif [ "$op" = "r" ] && [ -v name ]; then
    :
else
    usage
fi

if [ "$op" = "u" ]; then
    if [ -f "$name" ]; then
        IFS=',' read -r -a array < "$name"
        result=$(run r $name)
        if [ $(echo "$result" | cut -c1-8) = "SUCCESS:" ]; then
            echo $result
            result=$(run a "$name" "${array[1]}" "${array[2]}" "${array[3]}" "$cidr")
        fi
    else
        result="ERROR: $name not found. can't update!"
    fi
elif [ "$op" = "a" ]; then
    if [ -f "$name" ]; then
        IFS=',' read -r -a array < "$name"
        if [ "${array[4]}" = "revoked" ]; then
            answer="y"
            if [ -v sg ] || [ -v from ] || [ -v to ]; then
                echo "$name was revoked. Use the revoked configuration instead? revoked configuration: ${array[1]},${array[2]},${array[3]}"
                echo "Answer: y/n"
                read answer
            fi
            if [ "$answer" = "y" ]; then
                sg="${array[1]}"
                from="${array[2]}"
                to="${array[3]}"
            fi
        else
            echo "$name already exists! try update."
            echo "existing configuration: ${array[0]},${array[1]},${array[2]},${array[3]}"
            echo ""
            exit 1
        fi
    fi
    result=$(run "$op" "$name" "$sg" "$from" "$to" "$cidr")
elif [ "$op" = "r" ]; then
    result=$(run "$op" "$name" "$delete")
else
    result=1
fi

if [ "$result" = "1" ]; then
    usage
elif [ "$result" != "0" ] && [[ $(echo "$result" | cut -c1-8) != "SUCCESS:" ]]; then
    echo $result
    exit 1
fi

[ "$result" = "0" ] || echo "$result"
echo ""
