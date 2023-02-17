#!/bin/bash

# execute common setup script
source ./setup-common.sh

echo ">>> restart Alluxio worker processes"

####################################
## Start Alluxio Worker Processes ##
####################################

# Start the Alluxio master node daemons
alluxio-start.sh worker
alluxio-start.sh job_worker
alluxio-start.sh proxy