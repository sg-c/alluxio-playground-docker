#!/bin/bash

set -x

# execute preparing scripts
source ../prepare.sh

# set PWD
cd "$(dirname $0)"

###############################
## Common setup by root user ##
###############################

# check if krb5.conf files are set first
if [[ ! -d /etc/krb5.conf.d ]]; then
     echo "- Run ./setup-common-root.sh with user root first to set up krb5.conf files."
     exit 1
fi

######################
## Dependency Check ##
######################
report_dependency_failure() {
    local msg=$1
    echo "Dependency Check Failure: $msg"
    exit 1
}

# Check HDFS related config files are already there
declare -a HDFS_CONF_FILES=(core-site.xml hdfs-site.xml ssl-server.xml ssl-client.xml)
for file in "${HDFS_CONF_FILES[@]}"; do
    if [[ ! -f $INTEGRATION_TMP_DIR/$file ]]; then
        report_dependency_failure "$file doesn't exist"
    fi
done

###########################
## Alluxio Configuration ##
###########################

ALLUXIO_CONF_DIR=/opt/alluxio/conf

# import util functions such as eval_read
source ../../../entrypoint/utils.sh

# generate alluxio-site.properties based on the template and save to $INTEGRATION_TMP_DIR
eval_read ./alluxio-site.properties > ${SHARE_DIR}/alluxio-site.properties
cp ${SHARE_DIR}/alluxio-site.properties ${ALLUXIO_CONF_DIR}/alluxio-site.properties

# copy HDFS config files
# the assumption is that HDFS has been configured and shared configurations in the $SHARE_DIR
cp ${SHARE_DIR}/core-site.xml ${ALLUXIO_CONF_DIR}
cp ${SHARE_DIR}/hdfs-site.xml ${ALLUXIO_CONF_DIR}
cp ${SHARE_DIR}/ssl-server.xml ${ALLUXIO_CONF_DIR}
cp ${SHARE_DIR}/ssl-client.xml ${ALLUXIO_CONF_DIR}

# update owner and group of config files
chown -R alluxio:alluxio ${ALLUXIO_CONF_DIR}/*

# copy alluxio client jar to $SHARE_DIR for other components to use
ALLUXIO_VER=$(alluxio version)
ALLUXIO_CLI_JAR=alluxio-${ALLUXIO_VER}-client.jar
if [[ ! -f ${SHARE_DIR}/${ALLUXIO_CLI_JAR} ]]; then
  cp /opt/alluxio/client/${ALLUXIO_CLI_JAR} ${SHARE_DIR}/${ALLUXIO_CLI_JAR}
  chmod 777 ${SHARE_DIR}/${ALLUXIO_CLI_JAR}
  ln -s ${SHARE_DIR}/${ALLUXIO_CLI_JAR} ${SHARE_DIR}/alluxio-client.jar
fi