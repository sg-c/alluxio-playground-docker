#!/bin/bash

set -xe

# install awscli
if [[ $(command -v yum) != "" ]]; then
    yum -y install awscli
fi

# create alluxio-site.properties
cp /config/alluxio/alluxio-site.properties /opt/alluxio/conf/alluxio-site.properties

# copy alluxio license file
if [[ -f /config/alluxio/license.json ]]; then
    cp /config/alluxio/license.json /opt/alluxio/
else
    echo "Put alluxio license file at /config/alluxio/license.json"
fi

# format alluxio
alluxio format

if [[ $(hostname -f) == "alluxio-master"* ]]; then
    alluxio-start.sh master
    alluxio-start.sh job_master
elif [[ $(hostname -f) == "alluxio-worker"* ]]; then
    alluxio-start.sh worker NoMount
    alluxio-start.sh job_worker
else
    # if the hostname doesn't match "alluxio-master"* or "alluxio-worker"*,
    # we assume it's an advanced setup such as HA; in this case, we don't start the alluxio
    # processes at container creation time; instead, wait for integration scripts to start them
    echo "Wait for start alluxio processes manually"
fi

while true; do sleep 100; done
