#!/bin/bash

# Run the Anthem docker image
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


read -t 2 -p "Continue host configuration? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    # Set aliases on the host

    # Remove the old enter alias (if it exists)
    grep "alias enter" ~/.bashrc > /dev/null
    if [ $? -eq 0 ]; then
        sed -i 's/^alias enter.*$//' ~/.bashrc
    fi

    # Add the new enter function (if necessary)
    grep "function enter" ~/.bashrc > /dev/null
    if [ $? -ne 0 ]; then
        echo "function enter { docker exec -it \$(docker ps -q) /home/anthem/module_control/docker/shell.sh; }" >> ~/.bashrc
        echo "Log out and back in to get the 'enter' function working."
    fi
else
    echo "Skipping host config"
fi


read -t 2 -p "Continue docker image pull? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    echo sudo -u anthem docker login
         sudo -u anthem docker login
    if [ $? -ne 0 ]; then echo "ERROR: Could not login to docker"; exit -1; fi

    echo sudo -u anthem docker pull anthemdocker/anthem
         sudo -u anthem docker pull anthemdocker/anthem
    if [ $? -ne 0 ]; then echo "ERROR: Could not pull docker image"; exit -1; fi
else
    echo "Skipping docker pull"
fi

read -t 2 -p "Continue running the docker image? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    sudo -u anthem docker ps | grep anthem > /dev/null
    if [ $? -eq 0 ]; then
        CONTAINER=$(docker ps -lq)
        echo "Stopping running container..."
        echo sudo -u anthem docker stop $CONTAINER
             sudo -u anthem docker stop $CONTAINER

        read -t 2 -p "Continue cleaning up (removing) last container? (Y/n) Default: <Enter> " RESP
        if isyes $RESP; then
            echo sudo -u anthem docker rm $CONTAINER
                 sudo -u anthem docker rm $CONTAINER
        else
            echo "Skipping remove last container..."
        fi
    fi

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

# Set the display's serial number.
echo "If the SN is set, don't enter anything and just hit <Return>"
read -p "Please enter this display's serial number: " RESP
echo "print Display.objects.all().update(uuid=$RESP)" | docker exec -i $(docker ps -lq) sudo -u anthem /home/anthem/module_control/display_control/djangoShell.py

# Create static files: display_config.ini and docker_version.txt.
# Create the display_config.ini file if it doesn't exist.
if [ ! -f /home/anthem/config/display_config.ini ]; then
    echo "[CORE]"         > /home/anthem/config/display_config.ini
    echo "serial = $RESP" >>/home/anthem/config/display_config.ini
    echo "rows = 8"       >>/home/anthem/config/display_config.ini
    echo "columns = 16"   >>/home/anthem/config/display_config.ini
    echo "three_bay = 0"  >>/home/anthem/config/display_config.ini
fi

# Inject the image SHA information into the container.
docker inspect --format='{{.Image}}' `docker ps -lq` \
    > /home/anthem/config/docker_version.txt

# Pass the return value of above command as this script's return value
exit $?
