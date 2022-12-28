#!/bin/bash

VOLUMES=( alluxio-share )

create() {
    for volume in "${VOLUMES[@]}"; do 
        docker volume create $volume
    done
}

remove() {
    for volume in "${VOLUMES[@]}"; do
        docker volume rm $volume
    done
}

inspect() {
    docker volume inspect $1
}

case $1 in
create)
    create
    ;;
remove)
    remove
    ;;
inspect)
    inspect VOLUME_NAME
    ;;
*)
    echo "volume.sh create|remove|inspect"
    ;;
esac
