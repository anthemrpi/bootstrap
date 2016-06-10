#!/bin/bash

# This script copies a new version of bootstrap onto the host
# machine, based on using the LAN1 IP. It requires passwords
# a few times (scp, ssh, sudo), but no other input.
#
# Input is possible, but a two-second timeout on most commands
# defaults to continue

git pull
scp bootstrap.sh anthem@172.24.1.94:~/bootstrap/
ssh anthem@172.24.1.94 bash ~/bootstrap/bootstrap.sh
