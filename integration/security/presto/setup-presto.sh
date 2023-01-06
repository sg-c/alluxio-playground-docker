#!/bin/bash

set -x

# execute preparing scripts
source ../prepare.sh

# set PWD
cd "$(dirname $0)"

##############################
## Kerberos related setups ###
##############################
# import kerberos related functions
source ../kerberos/utils.sh
# copy krb5.conf files from container "kdc" to current container
copy_krb5_conf $(id -un) $(id -gn)

# install kerberos client side libs
yum install -y krb5-libs krb5-workstation

################################
## Create Kerberos principals ##
################################

# create presto service principal
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
KEYTAB_DIR=/opt/presto-server/keytabs
if [ ! -d $KEYTAB_DIR ]; then
     mkdir -p $KEYTAB_DIR
fi

if [ -f $KEYTAB_DIR/presto.service.keytab ]; then
     echo "- File $KEYTAB_DIR/presto.service.keytab exists, skipping create keytab files step."
else
     echo "- Creating kerberos principals"
     old_pwd=$(pwd)
     cd $KEYTAB_DIR

     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey presto/${HOSTNAME}@${REALM}"
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k presto.service.keytab presto/${HOSTNAME}@${REALM}"

     chmod 400 presto.service.keytab

     cd $old_pwd
fi

#############################
## Copy alluxio client jar ##
#############################

plugin_dir=$PRESTO_HOME/plugin/hive-hadoop2
# remove the existing jar
rm $plugin_dir/alluxio-*-client-*.jar
# copy the jar shared by alluxio container (use -L to follow the symlink)
cp -L $SHARE_DIR/alluxio-client.jar $plugin_dir

##########################
## Presto Server setups ##
##########################

# import util functions such as eval_read
source ../../../entrypoint/utils.sh

# copy hive catalog properties file
eval_read ./hive.properties >$PRESTO_HOME/etc/catalog/hive.properties
eval_read ./alluxio-site.properties.client >$PRESTO_HOME/etc/alluxio-site.properties
cp ./jvm.config $PRESTO_HOME/etc/jvm.config

# copy hadoop configs for access hdfs
cp $SHARE_DIR/core-site.xml $PRESTO_HOME/etc/
cp $SHARE_DIR/hdfs-site.xml $PRESTO_HOME/etc/
cp $SHARE_DIR/ssl-client.xml $PRESTO_HOME/etc/

# restart presto server
${PRESTO_HOME}/bin/launcher stop
nohup ${PRESTO_HOME}/bin/launcher start