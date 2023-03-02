#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# copy config files
cp ./hdfs-site.xml $HADOOP_CONF_DIR

chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*

# restart datanode
nohup hdfs --daemon stop datanode
nohup hdfs --daemon start datanode