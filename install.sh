#!/bin/bash

# Run the Anthem docker image
# (c) Anthem Displays, 2016

# Set aliases on the host
grep "alias enter" ~/.bashrc > /dev/null
if [ $? -ne 0 ]; then
    # The alias is not there, set it up
    echo alias enter=\"docker exec -it \`docker ps -lq\` /home/anthem/module_control/docker/shell.sh\" >> ~/.bashrc
fi


read -p "Pull the latest docker image? (y/n) " RESP
if [ "$RESP" = "y" ]; then
    echo sudo -u anthem docker login
         sudo -u anthem docker login
    if [ $? -ne 0 ]; then echo "ERROR: Could not login to docker"; exit -1; fi

    echo sudo -u anthem docker pull anthemdocker/anthem
         sudo -u anthem docker pull anthemdocker/anthem
    if [ $? -ne 0 ]; then echo "ERROR: Could not pull docker image"; exit -1; fi
else
    echo "Skipping docker pull"
fi


read -p "Run the docker image? (y/n) " RESP
if [ "$RESP" = "y" ]; then
    echo "Running docker image..."
    sudo -u anthem docker run -d --privileged=true --restart=always \
        -v /dev/bus/usb:/dev/bus/usb \
        -v /etc/udev/rules.d:/etc/udev/rules.d \
        -v /var/log/supervisor:/var/log/supervisor \
        -v /home/anthem/config:/home/anthem/config \
        -p 80:80 \
        -p 445:445 \
        -p 139:139 \
        -i -t anthemdocker/anthem \
        /home/anthem/module_control/docker/start.sh
else
    echo "Skipping docker run"
fi


# Pass the return value of above command as this script's return value
exit $?
