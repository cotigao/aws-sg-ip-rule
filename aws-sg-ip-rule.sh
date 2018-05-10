#!/bin/bash

set -o errexit
set -o pipefail

stn="https://api.ipify.org"

function usage {
 echo "             Add rule: $0 a -n <rule_name> -s <security_group_id> -f <start_inbound_tcp_port> -t <end_inbound_tcp_Port>"
 echo "Update rule (only IP): $0 u -n <rule_name>"
 echo "          Revoke rule: $0 r -n <rule_name>"
 exit 1   
}

function run {
 set -o errexit
 set -o pipefail

 if [ "$1" = "r" ]; then
    if [[ $# < 2 ]]; then
       echo "1"
    elif [ -f "$2" ]; then
        IFS=',' read -r -a array < <(cat $2)
        aws ec2 revoke-security-group-ingress --group-id ${array[1]} --ip-permissions '[{"IpProtocol": "tcp", "FromPort": '${array[2]}', "ToPort":  '${array[3]}', "IpRanges": [{"CidrIp" : "'${array[0]}'", "Description" : "'$(basename $2)'"}]}]'
        echo "SUCCESS: revoked "$(cat "$2")
        echo "${array[0]},${array[1]},${array[2]},${array[3]},revoked" > $2
    else
        echo "ERROR: $2 not found, can't revoke!"
    fi
 elif [ "$1" = "a" ]; then
    if [[ $# < 5 ]]; then
        echo "1"
    else
        ip=$(curl -s ${stn})"/32"
        aws ec2 authorize-security-group-ingress --group-id $3 --ip-permissions '[{"IpProtocol": "tcp", "FromPort": '$4', "ToPort": '$5', "IpRanges": [{"CidrIp": "'$ip'", "Description" : "'$(basename $2)'"}]}]'
        echo "$ip,$3,$4,$5" > $2
        echo "SUCCESS: updated security group $3 to allow $ip, (start-tcp-port: $4, end-tcp-port: $5), saved to file $2"
    fi
 else
    echo "1"
 fi
}


[ "$1" = "u" ] || [ "$1" = "a" ] || [ "$1" = "r" ] || usage

op="$1"
shift

while getopts ":f:t:n:s:" x; do
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
        echo "$name already exists!"
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
        IFS=',' read -r -a array < <(cat $name)
        result=$(run r $name)
        if [ $(echo "$result" | cut -c1-8) = "SUCCESS:" ]; then
            echo $result    
            result=$(run a "$name" "${array[1]}" "${array[2]}" "${array[3]}")
        fi
    else
        result="ERROR: $name not found. can't update!"
    fi
elif [ "$op" = "a" ]; then
    if [ -f "$name" ]; then
        IFS=',' read -r -a array < <(cat $name)
        if [ "${array[4]}" = "revoked" ]; then
            answer="y"
            if [ -v sg ] || [ -v from ] || [ -v to ]; then
                echo "$name was revoked. Use the revoked configuration instead? y/n." 
                echo "revoked configuration: ${array[1]},${array[2]},${array[3]}"
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
            exit 1
        fi 
    fi
    result=$(run "$op" "$name" "$sg" "$from" "$to") 
elif [ "$op" = "r" ]; then
    result=$(run "$op" "$name") 
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
