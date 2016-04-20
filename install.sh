#!/bin/bash

# Run the Anthem docker image
# (c) Anthem Displays, 2016

# Old run commands:
# docker run --privileged=true -v /dev/bus/usb:/dev/bus/usb -p 80-445:80-445 -i -t bgrissom/anthem:v0.0.4 /bin/bash
# docker run --privileged=true -v /dev/bus/usb:/dev/bus/usb -i -t bgrissom/anthem:v0.0.4 /bin/bash



#docker login

#docker pull bgrissom/anthem:latest

docker run --privileged=true --restart=always -v /dev/bus/usb:/dev/bus/usb \
                             -v /var/log/supervisor:/var/log/supervisor \
                             -v /home/anthem/config:/home/anthem/config \
                             -p 8080:80 \
                             -p 8445:445 \
                             -p 8139:139 \
                             -i -t bgrissom/anthem:latest /bin/bash

