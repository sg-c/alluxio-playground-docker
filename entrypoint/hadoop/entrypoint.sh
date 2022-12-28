#!/bin/bash

HADOOP_HOME=/opt/hadoop

# copy local config files to hadoop config dir
cp /config/hadoop/* ${HADOOP_CONF_DIR}

# update hdfs config
for file in $(find ${HADOOP_CONF_DIR} -type f); do
    sed -i "s#NAMENODE_FQDN#${NAMENODE_FQDN}#g" ${file}
done

if [[ "$(hostname -f)" == "namenode"* ]]; then
    # format HDFS
    hdfs namenode -format

    # start namenode daemon
    HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-namenode.log
    nohup hdfs --daemon start namenode >${HADOOP_LOG} 2>&1 &
else
    # start datanode daemon
    HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-datanode.log
    nohup hdfs --daemon start datanode >${HADOOP_LOG} 2>&1 &
fi

# wait forever
if [[ $1 == "-bash" ]]; then
  /bin/bash
else
  tail -f ${HADOOP_LOG}
fi

# while true; do sleep 100; done
