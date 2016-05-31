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


read -p "Continue host configuration? (Y/n) Default: <Enter> " RESP
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
        echo "function enter { docker exec -it \$(docker ps -lq) /home/anthem/module_control/docker/shell.sh; }" >> ~/.bashrc
    fi
else
    echo "Skipping host config"
fi


read -p "Continue docker image pull? (Y/n) Default: <Enter> " RESP
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


read -p "Continue running the docker image? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    sudo -u anthem docker ps | grep anthem > /dev/null
    if [ $? -eq 0 ]; then
        echo "Stopping running container..."
        echo sudo -u anthem docker stop `docker ps -lq`
             sudo -u anthem docker stop `docker ps -lq`

        read -p "Continue cleaning up (removing) last container? (Y/n) Default: <Enter> " RESP
        if isyes $RESP; then
            echo sudo -u anthem docker rm   `docker ps -lq`
                 sudo -u anthem docker rm   `docker ps -lq`
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
   echo "Log out and back in to get the 'enter' alias working."
else
    echo "Skipping docker run"
fi


read -p "Continue setting up django? (Y/n) Default: <Enter> " RESP
if isyes $RESP; then
    for i in $(seq 1 8);
    do
        echo "($i of 8) Waiting for MySQL to start..."
        sleep 1
    done

    echo "Stopping all supervisor services"
    sudo -u anthem docker exec -it `docker ps -lq` supervisorctl stop all
    echo "Setting up Django..."
    sudo -u anthem docker exec -it `docker ps -lq` sudo -u anthem /home/anthem/module_control/display_control/util/system_controller_setup/non_priv_setup.sh
    echo "Restarting all supervisor services"
    sudo -u anthem docker exec -it `docker ps -lq` supervisorctl start all
else
    echo "Skipping Django setup"
fi

# Pass the return value of above command as this script's return value
exit $?
