#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# copy config files
cp ./hdfs-rbf-site.xml $HADOOP_CONF_DIR

chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*

# update the owner of dir for state store storage
# the /tmp/dfs-state-store-dir is a shared volume that is created by docker-compose.yml
sudo chown $(id -un):$(id -gn) /tmp/dfs-state-store-dir

# start dfs Router daemon
nohup hdfs --daemon start dfsrouter
