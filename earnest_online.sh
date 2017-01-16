#!/bin/bash

# Bootstrap a system controller installation
# (c) Anthem Displays, 2016

if [ `whoami` == "root" ]; then
    echo "Running normally as root..."
else
    echo "You need to run this command with \"sudo\""
    exit
fi

ip route del default via 192.168.0.1
ip route add default via 172.24.0.1

