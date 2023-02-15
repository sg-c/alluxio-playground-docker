#!/bin/bash

set -x

# execute preparing scripts
source ../../utils/prepare.sh

##################################
## Copy alluxio-site.properties ##
##################################

cp ./alluxio-site.properties /opt/alluxio/conf

########################################################
## Share with other containers the alluxio-client.jar ##
########################################################

source ../../utils/utils-alluxio.sh

share_alluxio_cli_jar