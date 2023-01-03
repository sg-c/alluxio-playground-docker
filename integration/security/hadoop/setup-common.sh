#!/bin/bash

set -x

# set PWD
cd "$(dirname $0)"

# import kerberos related functions
source ../../common/kerberos/utils.sh
# copy krb5.conf files from container "kdc" to current container
copy_krb5_conf root root

## Hadoop in Secure Mode setup
## reference: https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html#Kerberos_principals_for_Hadoop_Daemons

## End User Accounts
# see ${REPO_HOME}/scenario/security/README.md for creating user principals

## User Accounts for Hadoop Daemons
# the "apache/hadoop:3" images uses "hadoop:users" to start hadoop services by default

## Kerberos principals for Hadoop Daemons
# namenode pricinpals are created by ./setup-namenode.sh
# datanode principals are created by ./setup-datanode.sh


## Configuration
# See core-site.xml and hdfs-site.xml for setting of configs
TMP_CORE_SITE=${INTEGRATION_TMP_DIR}/core-site.xml
TMP_HDFS_SITE=${INTEGRATION_TMP_DIR}/hdfs-site.xml
TMP_SSL_SERVER=${INTEGRATION_TMP_DIR}/ssl-server.xml
TMP_SSL_CLIENT=${INTEGRATION_TMP_DIR}/ssl-client.xml

cp ./core-site.xml ${TMP_CORE_SITE}
cp ./hdfs-site.xml ${TMP_HDFS_SITE}
cp ./ssl-server.xml ${TMP_SSL_SERVER}
cp ./ssl-client.xml ${TMP_SSL_CLIENT}

sed -i "s#REALM#${REALM}#g" ${TMP_CORE_SITE}; sed -i "s#DOMAIN#${DOMAIN}#g" ${TMP_CORE_SITE}
sed -i "s#REALM#${REALM}#g" ${TMP_HDFS_SITE}; sed -i "s#DOMAIN#${DOMAIN}#g" ${TMP_HDFS_SITE}
sed -i "s#REALM#${REALM}#g" ${TMP_SSL_SERVER}; sed -i "s#DOMAIN#${DOMAIN}#g" ${TMP_SSL_SERVER}
sed -i "s#REALM#${REALM}#g" ${TMP_SSL_CLIENT}; sed -i "s#DOMAIN#${DOMAIN}#g" ${TMP_SSL_CLIENT}


# Create SSL certs for Hadoop Namenode HTTPS services
keys_dir=/etc/ssl/certs # This is a common volume shared across hadoop and alluxio containers
if [ ! -d /etc/ssl/certs ]; then
     mkdir -p $keys_dir
fi

if [ -f /etc/ssl/certs/hadoop-client-truststore.jks ]; then
     echo "- File /etc/ssl/certs/hadoop-client-truststore.jks exists, skipping create SSL cert files step"
else
     echo "- Creating SSL cert files"
     old_pwd=`pwd`; cd $keys_dir

     store_password="changeme123"

     # For the namenode, generate the keystore and certificate
     keytool -genkey -keyalg RSA \
       -keypass $store_password -storepass $store_password  \
       -validity 360 -keysize 2048 \
       -alias namenode.${DOMAIN} \
       -dname "CN=namenode.${DOMAIN}, OU=Alluxio, L=San Mateo, ST=CA, C=US" \
       -keystore namenode.${DOMAIN}-keystore.jks

     # For the datanode1, generate the keystore and certificate
     keytool -genkey -keyalg RSA \
       -keypass $store_password -storepass $store_password  \
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
       -file  namenode.${DOMAIN}.cert \
       -keystore namenode.${DOMAIN}-truststore.jks 

     # Import the datanode certificate to a truststore file
     keytool -import -noprompt -storepass $store_password \
       -alias datanode.${DOMAIN} \
       -file  datanode.${DOMAIN}.cert \
       -keystore datanode.${DOMAIN}-truststore.jks 

     # Create a single client truststore file that contains the public key from all the certificates
     keytool -import -noprompt -storepass $store_password \
       -alias namenode.${DOMAIN} \
       -file  namenode.${DOMAIN}.cert \
       -keystore hadoop-client-truststore.jks 

     keytool -import -noprompt -storepass $store_password \
       -alias datanode.${DOMAIN} \
       -file  datanode.${DOMAIN}.cert \
       -keystore hadoop-client-truststore.jks 

     # Set permissions and ownership on the keys
     #chown -R $YARN_USER:hadoop /etc/ssl/certs
     chmod 755 /etc/ssl/certs
     chmod 440 namenode.${DOMAIN}-keystore.jks  
     chmod 440 namenode.${DOMAIN}.cert  
     chmod 440 namenode.${DOMAIN}-truststore.jks 
     chmod 440 datanode.${DOMAIN}-keystore.jks 
     chmod 440 datanode.${DOMAIN}.cert 
     chmod 440 datanode.${DOMAIN}-truststore.jks 
     chmod 444 hadoop-client-truststore.jks

     # List the contents of the trustore file
     #echo "- Key contents of file: $keys_dir/hadoop-client-truststore.jks"
     #keytool -list -v -keystore hadoop-client-truststore.jks -storepass $store_password

     cd $old_pwd
fi
