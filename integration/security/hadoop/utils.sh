#!/bin/bash

# import functions from common/utils.sh
source ../../common/utils.sh

copy_configs() {
    diff_cp $(dirname $0)/core-site.xml $HADOOP_CONF_DIR
    diff_cp $(dirname $0)/hdfs-site.xml $HADOOP_CONF_DIR
    diff_cp $(dirname $0)/hadoop-env.sh $HADOOP_CONF_DIR

    chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*
}

create_service_princ() {
    user=$1
    host=$2

    KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
    KEYTAB_DIR=/etc/security/keytabs

    kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable ${user}/${host}.${DOMAIN}@${REALM}"
    kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k ${KEYTAB_DIR}/${user}.service.keytab ${user}/${host}.${DOMAIN}"
}
