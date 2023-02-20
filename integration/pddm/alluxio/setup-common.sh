#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# waiting for alluxio up
while [[ $(alluxio fsadmin report >/dev/null && echo $?) != 0 ]]; do
    echo ">>> sleep 3 sec to wait for Alluxio is up and steady"
    sleep 3
done


###########################
## Alluxio Configuration ##
###########################

ALLUXIO_CONF_DIR=/opt/alluxio/conf

cp ./alluxio-site.properties $ALLUXIO_CONF_DIR