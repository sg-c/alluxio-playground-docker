#!/bin/bash

set -x

# execute preparing scripts
source ../../utils/prepare.sh

###################################
## Copy conf and alluxio cli jar ##
###################################

if [ -d /opt/impala/conf ]; then
    cp ./core-site.xml /opt/impala/conf
    cp $SHARE_DIR/alluxio-client.jar /opt/impala/lib
fi

if [ -d /opt/hive/conf ]; then
    cp ./core-site.xml /opt/hive/conf
    cp $SHARE_DIR/alluxio-client.jar /opt/lib/lib
fi
