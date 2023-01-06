#!/bin/bash

set -x

# execute common setup scripts
source ./setup-common.sh

# Create kerberos principals and keytabs (if not already created) for namenode
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
KEYTAB_DIR=/etc/security/keytabs
if [ -d ${KEYTAB_DIR} ] && [ -f ${KEYTAB_DIR}/nn.service.keytab ]; then
  echo "- File ${KEYTAB_DIR}/nn.service.keytab exists, skipping create kerberos principals step"
else 
  echo "- Creating kerberos principals for namenode"

  mkdir -p ${KEYTAB_DIR}
  old_dir=`pwd`; cd ${KEYTAB_DIR}

  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable nn/$(hostname -f)@${REALM}"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable host/$(hostname -f)@${REALM}"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable HTTP/$(hostname -f)@${REALM}"

  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k nn.service.keytab nn/$(hostname -f)"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k nn.service.keytab host/$(hostname -f)"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k spnego.service.keytab HTTP/$(hostname -f)"

#   chmod 400 ${KEYTAB_DIR}/nn.service.keytab
#   chmod 400 ${KEYTAB_DIR}/spnego.service.keytab

  cd $old_dir
fi

# start namenode daemon
# HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-namenode.log
nohup hdfs --daemon stop namenode
nohup hdfs --daemon start namenode

# create /tmp dir and open it for all users
hdfs dfs -mkdir /tmp
hdfs dfs -chmod 777 /tmp