#!/bin/bash

# import functions from common/utils.sh
source ../../common/utils.sh

copy_configs() {
    diff_cp ./core-site.xml $HADOOP_CONF_DIR
    diff_cp ./hdfs-site.xml $HADOOP_CONF_DIR
    diff_cp ./hadoop-env.sh $HADOOP_CONF_DIR

    chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*
}