#!/bin/bash

set -xe

HADOOP_HOME=/opt/hadoop

# copy local config files to hadoop config dir
cp /config/hadoop/core-site.xml ${HADOOP_CONF_DIR}/core-site.xml
cp /config/hadoop/hdfs-site.xml ${HADOOP_CONF_DIR}/hdfs-site.xml

# Add user "alluxio" to the hdfs superusergroup group on namenode
# The user "alluxio" is used for starting Alluxio processes
# For details, see https://hadoop.apache.org/docs/r3.1.0/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html#The_Super-User
sudo groupadd supergroup
sudo useradd --gid supergroup alluxio

# start hdfs processes
if [[ "$(hostname -f)" == "namenode"* ]]; then
  # format HDFS
  hdfs namenode -format

  # start namenode daemon
  HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-namenode.log
  hdfs --daemon start namenode >${HADOOP_LOG} 2>&1

  # create /tmp and set mode to 777 in HDFS for Hive and other components to use
  hdfs dfs -mkdir /tmp
  hdfs dfs -mkdir /user
  hdfs dfs -chmod 777 /tmp
  hdfs dfs -chmod 777 /user
else
  # wait for namenode to be ready
  sleep 6

  # start datanode daemon
  HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-datanode.log
  hdfs --daemon start datanode >${HADOOP_LOG} 2>&1
fi

# wait forever
while true; do sleep 100; done
