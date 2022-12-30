#!/bin/bash

set -x

source ./utils.sh

# copy new config files to $HADOOP_CONF_DIR
copy_configs

# create service principals for datanode
create_service_princ dn datanode
create_service_princ host datanode

# start datanode daemon
HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-datanode.log
nohup hdfs --daemon start datanode >${HADOOP_LOG} 2>&1 &
