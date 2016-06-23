#!/bin/bash
echo $@
docker exec -it $(docker ps -lq) sudo -u anthem $@
