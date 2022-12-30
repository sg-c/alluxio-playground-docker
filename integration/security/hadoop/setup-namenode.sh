#!/bin/bash

source ./utils.sh

# copy new config files to $HADOOP_CONF_DIR
copy_configs

# start namenode daemon
HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-namenode.log
nohup hdfs --daemon start namenode >${HADOOP_LOG} 2>&1 &
