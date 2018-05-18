# aws-sg-ip-rule
## CLI to add, update and revoke an inbound access rule for dynamic public IPs
```
./aws-sg-ip-rule.sh -h

Add rule: ./aws-sg-ip-rule.sh a -n <rule_name> -s <security_group_id> -f <start_inbound_tcp_port> -t <end_inbound_tcp_port>

Update rule (only IP): ./aws-sg-ip-rule.sh u -n <rule_name>

Revoke rule: ./aws-sg-ip-rule.sh r -n <rule_name>
```

### To add a inbound rule from your current IP (SSH access)
```
./aws-sg-ip-rule.sh a -n allow-xyz-to-ssh -s sg-1234abcd -f 22 -t 22
```

### To add a inbound rule from your current IP (range of ports)
```
./aws-sg-ip-rule.sh a -n allow-xyz-range -s sg-1234abcd -f 3300 -t 3310
```

The above commands allow access to the specified ports(s) from your current IP.
**Add rule** creates a rulefile in the same directory as the script and with the same name as the rule.
rulefile holds the info related to the rule.


### To update an existing rule (only updates the public IP)
```
./aws-sg-ip-rule.sh u -n allow-xyz-to-ssh
```

Updates the rule with your new public IP


### To revoke a rule
```
./aws-sg-ip-rule.sh r -n allow-xyz-to-ssh
```

Removes the rule. i.e removes the access to the port(s) in ```allow-xyz-to-ssh``` from the IP in ```allow-xyz-to-ssh```


### To add back a revoked rule (provided the rule-file is not deleted externally)
```
./aws-sg-ip-rule.sh a -n allow-xyz-to-ssh
```

Adds back the revoked rule.


### To handle multiple rules at once
```
./coverfire.sh -h
```


