#!/bin/bash

set -xe

while [[ ! -f /tmp/entrypoint-done ]]; do
    echo "entrypoint.sh still working, wait a bit ..."
    sleep 3
done

# execute preparation scripts
source ../../utils/pre-integration.sh

# copy config files
cp ./hdfs-site.xml $HADOOP_CONF_DIR

chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*

# stop, format, and start NN
nohup hdfs --daemon stop namenode
nohup hdfs namenode -format -clusterId playground
nohup hdfs --daemon start namenode
