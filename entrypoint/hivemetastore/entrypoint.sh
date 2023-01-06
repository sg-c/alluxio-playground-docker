#!/bin/bash

set -xe

# set envs
. /etc/profile

# generate configurations
cp /config/hivemetastore/hivemetastore-site.xml ${HIVE_HOME}/conf/hivemetastore-site.xml
cp /config/hivemetastore/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml

# sleep 15 sec and wait for mysql and hadoop to be ready
sleep 15
# initialize the hive metastore schema
su - hive -c "$HIVE_HOME/bin/schematool -dbType mysql -initSchema"

# start hive metatore server
su - hive -c "nohup $HIVE_HOME/bin/hive --service metastore &"

# wait forever
while true; do sleep 100; done