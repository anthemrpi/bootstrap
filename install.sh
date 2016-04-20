#!/bin/bash

# Run the Anthem docker image
# (c) Anthem Displays, 2016

# Old run commands:
# docker run --privileged=true -v /dev/bus/usb:/dev/bus/usb -p 80-445:80-445 -i -t bgrissom/anthem:v0.0.4 /bin/bash
# docker run --privileged=true -v /dev/bus/usb:/dev/bus/usb -i -t bgrissom/anthem:v0.0.4 /bin/bash



sudo -u anthem docker login
if [ $? -ne 0 ]; then echo "ERROR: Could not login to docker"; exit; fi

sudo -u anthem docker pull bgrissom/anthem
if [ $? -ne 0 ]; then echo "ERROR: Could not pull docker image"; exit; fi

sudo -u anthem docker run -d --privileged=true --restart=always -v /dev/bus/usb:/dev/bus/usb \
    -v /var/log/supervisor:/var/log/supervisor \
    -v /home/anthem/config:/home/anthem/config \
    -p 80:80 \
    -p 445:445 \
    -p 139:139 \
    -i -t bgrissom/anthem \
    /home/anthem/module_control/docker/start.sh

# Pass the return value of above command as this script's return value
exit $?
