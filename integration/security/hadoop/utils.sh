#!/bin/bash

# import functions from common/utils.sh
source ../../common/utils.sh

copy_configs() {
    DIR=/integration/security/hadoop

    diff_cp $DIR/core-site.xml $HADOOP_CONF_DIR
    diff_cp $DIR/hdfs-site.xml $HADOOP_CONF_DIR
    diff_cp $DIR/hadoop-env.sh $HADOOP_CONF_DIR

    chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*
}