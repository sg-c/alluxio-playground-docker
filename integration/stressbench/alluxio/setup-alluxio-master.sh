#!/bin/bash

# execute common setup script
source ./setup-common.sh

echo ">>> restart Alluxio master processes"

####################################
## Start Alluxio Master Processes ##
####################################

# stop the Alluxio master daemons
alluxio-stop.sh master
alluxio-stop.sh job_master
alluxio-stop.sh proxy

# Format the master node journal
alluxio formatJournal

# Start the Alluxio master node daemons
alluxio-start.sh master
alluxio-start.sh job_master
alluxio-start.sh proxy
