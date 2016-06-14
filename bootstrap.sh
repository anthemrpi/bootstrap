#!/bin/bash

# Bootstrap a system controller installation
# (c) Anthem Displays, 2016

if [ `whoami` == "root" ]; then
    echo "Running normally as root..."
else
    echo "You need to run this command with \"sudo\""
    exit
fi

echo "-------------------------------------------"
echo "TRYING TO GET ONLINE"
ip route del default via 192.168.0.1
ip route add default via 10.1.10.1
dhclient -1 -pf /run/dhclient.p4p1.pid -lf /var/lib/dhcp/dhclient.p4p1.leases p4p1 &
dhclient -1 -pf /run/dhclient.p1p1.pid -lf /var/lib/dhcp/dhclient.p1p1.leases p1p1 &

for i in `seq 1 3`;
do
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

    echo "TRYING TO PING $i ..."

    ping -c 1 8.8.8.8

    if [ $? -eq 0 ]; then
        echo "Ping was successful, we are online"
        break
    fi

    if [ $i -eq 3 ]; then
        echo "-------------------------------------------"
        echo "ERROR: UNABLE TO GET ONLINE, PLEASE CONNECT AN ETHERNET CABLE"
        exit
    fi
done

cd /home/anthem/bootstrap/
if [ $? -ne 0 ]; then echo "ERROR: Could not go to /home/anthem/bootstrap/"; exit; fi

ntpdate ntp.ubuntu.com
# Reset undoes any changes made by copy.sh
read -t 2 -p "Continue resetting git repository? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    sudo -u anthem git reset --hard
fi
sudo -u anthem git pull
if [ $? -ne 0 ]; then echo "ERROR: Could pull remote git repository"; exit; fi

# Hmm, in case it hasn't been cloned before, we could detect it this way
#if [ $? -ne 0 ]; then
#    sudo -u anthem git clone https://github.com/anthemrpi/bootstrap.git
#    if [ $? -ne 0 ]; then echo "ERROR: Could pull remote git repository"; exit; fi
#fi

# install.sh logging
# stdbuf: Keep output unbuffered
# 2>&1: Merge STDERR into STDOUT
# tee: Print to STDOUT and a file
echo "Launching install.sh"
stdbuf -o 0 bash ./install.sh 2>&1 | tee -a ./install.log

echo "-------------------------------------------"
echo "End of bootstrap.sh script";
