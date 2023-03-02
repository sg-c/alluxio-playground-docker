#!/bin/bash

set -xe

# execute preparation scripts
source ../../utils/pre-integration.sh

# stop HDFS daemon processes
nohup hdfs --daemon stop namenode
nohup hdfs --daemon stop datanode

# copy config files
cp ./core-site.xml $HADOOP_CONF_DIR/core-site.xml
cp ./hdfs-site.client.xml $HADOOP_CONF_DIR/hdfs-site.xml

chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*
