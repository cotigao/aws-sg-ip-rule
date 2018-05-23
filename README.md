# aws-sg-ip-rule
## CLI to add, update and revoke an inbound access rule for dynamic public IPs
```

./aws-sg-ip-rule.sh -h
             Add rule: ./aws-sg-ip-rule.sh a [-i <ipaddr/cidr>] -s <security_group_id> -f <start_in_tcp_port> -t <end_in_tcp_Port> -n <rule_name>

Update rule (only IP): ./aws-sg-ip-rule.sh u [-i <ipaddr/cidr>] -n <rule_name>

          Revoke rule: ./aws-sg-ip-rule.sh r [-d (deletes the rulefile)] -n <rule_name>
```


### To add a inbound rule from your current IP (SSH access)
```
./aws-sg-ip-rule.sh a -n rules/allow-xyz-to-ssh -s sg-1234abcd -f 22 -t 22
```


### To add a inbound rule from your current IP (range of ports)
```
./aws-sg-ip-rule.sh a -n rules/allow-xyz-range -s sg-1234abcd -f 3300 -t 3310
```

The above commands allow access to the specified ports(s) from your current IP.



### If you want to provide the IP address/range (note: should always be a CIDR notation)
```
./aws-sg-ip-rule.sh a -n rules/allow-xyz-range -i 10.0.0.0/8 -s sg-1234abcd -f 3300 -t 3310
```

**Add rule** creates a rulefile with the same name as the rule.
`rule_name` refers to the rulefile path.
rulefile holds the info related to the rule.



### To update an existing rule (only updates the public IP)
```
./aws-sg-ip-rule.sh u -n rules/allow-xyz-to-ssh
```

Updates the rule with your new public IP



### If you want to provide the IP address/range (note: should always be a CIDR notation)
```
./aws-sg-ip-rule.sh u -n rules/allow-xyz-to-ssh -i 10.0.0.0/8
```


### To revoke a rule
```
./aws-sg-ip-rule.sh r -n rules/allow-xyz-to-ssh
```

Revokes the rule. i.e removes the access to the port(s) in ```allow-xyz-to-ssh``` from the IP in ```allow-xyz-to-ssh```



### To add back a revoked rule (provided the rulefile is not deleted externally)
```
./aws-sg-ip-rule.sh a -n rules/allow-xyz-to-ssh
```

Adds back the revoked rule.



### To handle multiple rules at once
```
./coverfire.sh -h

Add back revoked rule(s) : ./coverfire.sh a [-i <ipaddr/cidr>] <rule_name1> <rule_name1> ...

          Update rule(s) : ./coverfire.sh u [-i <ipaddr/cidr>] <rule_name1> <rule_name2> ...

          Revoke rule(s) : ./coverfire.sh r [-d (deletes the rulefiles)] <rule_name1> <rule_name2> ...
```


