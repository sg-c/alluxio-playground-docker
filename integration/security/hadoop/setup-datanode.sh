#!/bin/bash

set -x

source ./utils.sh

# copy new config files to $HADOOP_CONF_DIR
copy_configs


# Create kerberos principals and keytabs (if not already created) for datanode
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
KEYTAB_DIR=/etc/security/keytabs
if [ -d ${KEYTAB_DIR} ] && [ -f ${KEYTAB_DIR}/dn.service.keytab ]; then
  echo "- File ${KEYTAB_DIR}/dn.service.keytab exists, skipping create kerberos principals step"
else 
  echo "- Creating kerberos principals for datanode"

  mkdir -p ${KEYTAB_DIR}
  old_dir=`pwd`; cd ${KEYTAB_DIR}

  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable dn/$(hostname -f)@${REALM}"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable host/$(hostname -f)@${REALM}"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey -maxrenewlife 7d +allow_renewable HTTP/$(hostname -f)@${REALM}"

  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k dn.service.keytab dn/$(hostname -f)"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k dn.service.keytab host/$(hostname -f)"
  kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k spnego.service.keytab HTTP/$(hostname -f)"

#   chmod 400 ${KEYTAB_DIR}/dn.service.keytab
#   chmod 400 ${KEYTAB_DIR}/spnego.service.keytab

  cd $old_dir
fi

# start datanode daemon
# HADOOP_LOG=${HADOOP_LOG_DIR}/hadoop-datanode.log
hdfs --daemon stop datanode
nohup hdfs --daemon start datanode
