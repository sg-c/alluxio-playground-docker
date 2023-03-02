#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# copy config files
cp ../hadoop/core-site.xml /opt/alluxio/conf/core-site.xml
cp ../hadoop/hdfs-site.client.xml /opt/alluxio/conf/hdfs-site.xml

chown $(id -un):$(id -gn) /opt/alluxio/conf/*

# restart worker
# alluxio-stop.sh shows "ps: unrecognized option: w"  and doesn't work for this image
# without restart the worker process, new configs in core-site.xml and hdfs-site.xml won't be picked up
pid=$(ps aux | grep AlluxioWorker | grep -v grep | awk '{print $1}')
kill -9 $pid

alluxio-start.sh worker