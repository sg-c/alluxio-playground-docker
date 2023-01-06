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


################################
## Create Kerberos principals ##
################################

# create hive service principal
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
KEYTAB_DIR=/opt/hive/keytabs
if [ ! -d $KEYTAB_DIR ]; then
     mkdir -p $KEYTAB_DIR
fi

if [ -f $KEYTAB_DIR/hive.service.keytab ]; then
     echo "- File $KEYTAB_DIR/hive.service.keytab exists, skipping create keytab files step."
else
     echo "- Creating kerberos principals"
     old_pwd=$(pwd)
     cd $KEYTAB_DIR

     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey hive/${HOSTNAME}@${REALM}"
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k hive.service.keytab hive/${HOSTNAME}@${REALM}"

     chmod 400 hive.service.keytab

     cd $old_pwd
fi

##################
## Copy configs ##
##################

export HIVE_HOME=/opt/hive
cp $SHARE_DIR/core-site.xml $HIVE_HOME/conf
cp $SHARE_DIR/ssl-client.xml $HIVE_HOME/conf

# import util functions such as eval_read
source ../../../entrypoint/utils.sh

eval_read ./hivemetastore-site.xml >$HIVE_HOME/conf/hivemetastore-site.xml

chown -R hive:root $HIVE_HOME/*

#############################
## Copy alluxio client jar ##
#############################

lib_dir=$HIVE_HOME/lib
# copy the jar shared by alluxio container (use -L to follow the symlink)
cp -L $SHARE_DIR/alluxio-client.jar $lib_dir


#################
## Restart HMS ##
#################

# kill the hive metastore; it seems that there is no command line available for stopping the process
ps aux | grep HiveMetaStore | awk '{print $2}' | head -n 1 | xargs -I {} kill -9 {}
# start the hms
su - hive -c "nohup $HIVE_HOME/bin/hive --service metastore &"