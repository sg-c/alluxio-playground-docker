#!/bin/bash

set -x

source ./utils.sh

# copy new config files to $HADOOP_CONF_DIR
copy_configs

# create service principals for namenode
create_service_princ nn     namenode
create_service_princ host   namenode

# start namenode daemon
HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-namenode.log
nohup hdfs --daemon start namenode >${HADOOP_LOG} 2>&1 &
