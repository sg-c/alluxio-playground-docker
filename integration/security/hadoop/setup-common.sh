#!/bin/bash

set -xe

# set PWD
cd "$(dirname $0)"

# import kerberos related functions
source ../../common/kerberos/utils.sh
# copy krb5.conf files from container "kdc" to current container
copy_krb5_conf root root

## Hadoop in Secure Mode setup
## reference: https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html#Kerberos_principals_for_Hadoop_Daemons

## End User Accounts
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
# create user principals for ava and bob
kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -pw ${KERB_USER_PASS} ava@${REALM}"
kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -pw ${KERB_USER_PASS} bob@${REALM}"

## User Accounts for Hadoop Daemons
# the "apache/hadoop:3" images uses "hadoop:users" to start hadoop services by default

## Kerberos principals for Hadoop Daemons
# namenode pricinpals are created by ./setup-namenode.sh
# datanode principals are created by ./setup-datanode.sh

## Mapping from Kerberos principals to OS user accounts
# update the following config
#   * core-site.xml
#       * hadoop.security.auth_to_local
sed -i "s#REALM#${REALM}#g" ./core-site.xml

## Mapping from user to group
# the default config uses groups from OS
#   * core-site.xml
#       * hadoop.security.group.mapping = org.apache.hadoop.security.JniBasedUnixGroupsMappingWithFallback

## Proxy user
# proxy users are configured by following properties
#   * core-site.xml
#       * hadoop.proxyuser.*.hosts
#       * hadoop.proxyuser.*.groups

## Secure DataNode
# secure datanode is configured by
#   * hadoop-env.sh
#       * export HDFS_DATANODE_SECURE_USER= (unset HDFS_DATANODE_SECURE_USER env)
#   * hdfs-site.xml
#       * dfs.data.transfer.protection  = authentication
#       * dfs.datanode.address          = 50010
#       * dfs.http.policy               = HTTPS_ONLY

## Data Encryption on RPC
# no encryption for RPC
#   * core-site.xml
#       * hadoop.rpc.protection = authentication (default value)

## Data Encryption on Block data transfer
# no encryption for block transfering
#   * hdfs-site.xml
#       * dfs.encrypt.data.transfer = false (default value)

