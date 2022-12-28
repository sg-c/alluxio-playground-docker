#!/bin/bash

# import functions from common/utils.sh
source ../../common/utils.sh

copy_configs() {
    diff_cp $INTEGRATION_TMP_DIR/core-site.xml $HADOOP_CONF_DIR
    diff_cp $INTEGRATION_TMP_DIR/hdfs-site.xml $HADOOP_CONF_DIR
    diff_cp $INTEGRATION_TMP_DIR/ssl-server.xml $HADOOP_CONF_DIR
    diff_cp $INTEGRATION_TMP_DIR/ssl-client.xml $HADOOP_CONF_DIR
    diff_cp $INTEGRATION_TMP_DIR/hadoop-env.sh $HADOOP_CONF_DIR

    chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*
}
