#!/bin/bash

set -x

source ./utils.sh

# copy new config files to $HADOOP_CONF_DIR
copy_configs

# create service principals for datanode
create_service_princ dn     datanode
create_service_princ host   datanode

# start datanode daemon