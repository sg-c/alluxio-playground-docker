#!/bin/bash

set -xe

# change the permissions of /share directory
# chmod 777 /share

# import eval_read function
source /entrypoint/utils.sh

# create alluxio-site.properties
eval_read /config/alluxio/alluxio-site.properties >/opt/alluxio/conf/alluxio-site.properties

# format alluxio
alluxio format

if [[ $(hostname -f) == "alluxio-master.${DOMAIN}" ]]; then
    # alluxio-start.sh master
    # alluxio-start.sh job_master
elif [[ $(hostname -f) == "alluxio-worker.${DOMAIN}" ]]; then
    alluxio-start.sh worker
    alluxio-start.sh job_worker
else
    # if the hostname doesn't match "alluxio-master.${DOMAIN}" or "alluxio-worker.${DOMAIN}",
    # we assume it's an advanced setup such as HA; in this case, we don't start the alluxio
    # processes at container creation time; instead, wait for integration scripts to start them
    echo "Wait for start alluxio processes manually"
fi

# while true; do sleep 100; done
