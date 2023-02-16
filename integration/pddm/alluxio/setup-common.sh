#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# waiting for alluxio up
while [[ $(alluxio fsadmin report >/dev/null && echo $?) != 0 ]]; do
    echo ">>> sleep 3 sec to wait for Alluxio is up and steady"
    sleep 3
done

##########################
## AWS Credentials file ##
##########################

aws_cred_file=/integration/pddm/alluxio/credentials

if [[ ! -f $aws_cred_file ]]; then
    echo ">>> $aws_cred_file is NOT found. See the README.md for creating this file."
    exit 1 
fi


if [[ ! -d /home/alluxio/.aws ]]; then
    mkdir /home/alluxio/.aws
    cp $aws_cred_file /home/alluxio/.aws
    chown -R alluxio:alluxio /home/alluxio/.aws
fi

###########################
## Alluxio Configuration ##
###########################

ALLUXIO_CONF_DIR=/opt/alluxio/conf

cp ./alluxio-site.properties $ALLUXIO_CONF_DIR