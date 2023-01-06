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

#################################
## Hadoop in Secure Mode setup ##
#################################
## reference: https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html#Kerberos_principals_for_Hadoop_Daemons

## End User Accounts
# see alluxio_playground_docker/scenario/security/README.md for creating user principals

## User Accounts for Hadoop Daemons
# the "apache/hadoop:3" images uses "hadoop:users" to start hadoop services by default

## Kerberos principals for Hadoop Daemons
# namenode pricinpals are created by ./setup-namenode.sh
# datanode principals are created by ./setup-datanode.sh

# import util functions such as eval_read
source ../../../entrypoint/utils.sh

## Configuration
## See core-site.xml, hdfs-site.xml, ssl-server.xml, ssl-client.xml, hadoop-env.sh for security related settins
TMP_CORE_SITE=${SHARE_DIR}/core-site.xml
TMP_HDFS_SITE=${SHARE_DIR}/hdfs-site.xml
TMP_SSL_SERVER=${SHARE_DIR}/ssl-server.xml
TMP_SSL_CLIENT=${SHARE_DIR}/ssl-client.xml

# generate the config files from the template
eval_read ./core-site.xml > ${TMP_CORE_SITE}
eval_read ./hdfs-site.xml > ${TMP_HDFS_SITE}
eval_read ./ssl-server.xml > ${TMP_SSL_SERVER}
eval_read ./ssl-client.xml > ${TMP_SSL_CLIENT}

# import diff_cp from common/utils.sh
source ../../common/utils.sh
# copy updated config files to $HADOOP_CONF_DIR, and generate diff in the meanwhile
diff_cp ${TMP_CORE_SITE} $HADOOP_CONF_DIR
diff_cp ${TMP_HDFS_SITE} $HADOOP_CONF_DIR
diff_cp ${TMP_SSL_SERVER} $HADOOP_CONF_DIR
diff_cp ${TMP_SSL_CLIENT} $HADOOP_CONF_DIR
diff_cp ./hadoop-env.sh $HADOOP_CONF_DIR

chown $(id -un):$(id -gn) $HADOOP_CONF_DIR/*

###################################################################
## public/private keys, keystore, and certificate configurations ##
###################################################################
# Create SSL certs for Hadoop Namenode HTTPS services
keys_dir=${SHARE_DIR}/keys # This is a common volume shared across hadoop and alluxio containers
if [ ! -d $keys_dir ]; then
  mkdir -p $keys_dir
fi

if [ -f $keys_dir/hadoop-client-truststore.jks ]; then
  echo "- File $keys_dir/hadoop-client-truststore.jks exists, skipping create SSL cert files step"
else
  echo "- Creating SSL cert files"
  old_pwd=$(pwd)
  cd $keys_dir

  store_password="changeme123"

  # For the namenode, generate the keystore and certificate
  keytool -genkey -keyalg RSA \
    -keypass $store_password -storepass $store_password \
    -validity 360 -keysize 2048 \
    -alias namenode.${DOMAIN} \
    -dname "CN=namenode.${DOMAIN}, OU=Alluxio, L=San Mateo, ST=CA, C=US" \
    -keystore namenode.${DOMAIN}-keystore.jks

  # For the datanode1, generate the keystore and certificate
  keytool -genkey -keyalg RSA \
    -keypass $store_password -storepass $store_password \
    -validity 360 -keysize 2048 \
    -alias datanode.${DOMAIN} \
    -dname "CN=datanode.${DOMAIN}, OU=Alluxio, L=San Mateo, ST=CA, C=US" \
    -keystore datanode.${DOMAIN}-keystore.jks

  # Export the namenode certificate's public key to a certificate file
  keytool -export -rfc -storepass $store_password \
    -alias namenode.${DOMAIN} \
    -keystore namenode.${DOMAIN}-keystore.jks \
    -file namenode.${DOMAIN}.cert

  # Export the datanode1 certificate's public key to a certificate file
  keytool -export -rfc -storepass $store_password \
    -alias datanode.${DOMAIN} \
    -keystore datanode.${DOMAIN}-keystore.jks \
    -file datanode.${DOMAIN}.cert

  # Import the namenode certificate to a truststore file
  keytool -import -noprompt -storepass $store_password \
    -alias namenode.${DOMAIN} \
    -file namenode.${DOMAIN}.cert \
    -keystore namenode.${DOMAIN}-truststore.jks

  # Import the datanode certificate to a truststore file
  keytool -import -noprompt -storepass $store_password \
    -alias datanode.${DOMAIN} \
    -file datanode.${DOMAIN}.cert \
    -keystore datanode.${DOMAIN}-truststore.jks

  # Create a single client truststore file that contains the public key from all the certificates
  keytool -import -noprompt -storepass $store_password \
    -alias namenode.${DOMAIN} \
    -file namenode.${DOMAIN}.cert \
    -keystore hadoop-client-truststore.jks

  keytool -import -noprompt -storepass $store_password \
    -alias datanode.${DOMAIN} \
    -file datanode.${DOMAIN}.cert \
    -keystore hadoop-client-truststore.jks

  # Set permissions and ownership on the keys
  #chown -R $YARN_USER:hadoop /etc/ssl/certs
  #  chmod 755 /etc/ssl/certs
  chmod 444 namenode.${DOMAIN}-keystore.jks
  chmod 444 namenode.${DOMAIN}.cert
  chmod 444 namenode.${DOMAIN}-truststore.jks
  chmod 444 datanode.${DOMAIN}-keystore.jks
  chmod 444 datanode.${DOMAIN}.cert
  chmod 444 datanode.${DOMAIN}-truststore.jks
  chmod 444 hadoop-client-truststore.jks

  # List the contents of the trustore file
  #echo "- Key contents of file: $keys_dir/hadoop-client-truststore.jks"
  #keytool -list -v -keystore hadoop-client-truststore.jks -storepass $store_password

  cd $old_pwd
fi

# Add user "alluxio" to the hdfs superusergroup group on namenode
# The user "alluxio" is used for starting Alluxio processes
# For details, see https://hadoop.apache.org/docs/r3.1.0/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html#The_Super-User
sudo groupadd supergroup
sudo useradd --gid supergroup alluxio