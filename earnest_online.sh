#!/bin/bash

# Bootstrap a system controller installation
# (c) Anthem Displays, 2016

function isyes {
    if [ "$1" = "Y" ] || [ "$1" = "y" ] || [ "$1" = "" ]; then
        # Return 0 = true
        return 0
    else
        # Return 1 = false
        return 1
    fi
}

if [ `whoami` == "root" ]; then
    echo "Running normally as root..."
else
    echo "You need to run this command with \"sudo\""
    exit
fi

echo "-------------------------------------------"
echo "TRYING TO GET ONLINE"
for i in `seq 1 4`;
do
    echo "TRYING TO PING $i ..."

    ping -c 1 8.8.8.8

    if [ $? -eq 0 ]; then
        echo "Ping was successful, we are online"
        break
    fi

    echo Trying DHCP via 172.24.0.1
    ip route del default via 192.168.0.1
    ip route add default via 172.24.0.1
    dhclient -1 -pf /run/dhclient.p4p1.pid -lf /var/lib/dhcp/dhclient.p4p1.leases p4p1 &
    dhclient -1 -pf /run/dhclient.p1p1.pid -lf /var/lib/dhcp/dhclient.p1p1.leases p1p1 &

    sleep 1
    echo "Waiting 1..."
    sleep 1
    echo "Waiting 2..."
    sleep 1
    echo "Waiting 3..."
    sleep 1
    echo "Waiting 4..."
    sleep 1
    echo "Waiting 5..."
    sleep 1

    if [ $i -eq 4 ]; then
        echo "-------------------------------------------"
        echo "ERROR: UNABLE TO GET ONLINE, PLEASE CONNECT AN ETHERNET CABLE"
        exit
    fi
done

