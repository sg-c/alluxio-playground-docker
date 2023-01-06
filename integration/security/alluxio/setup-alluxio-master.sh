#!/bin/bash

set -x

# run scripts that are common for both alluxio master and alluxio worker
source ./setup-common.sh

#######################
## SSL Configuration ##
#######################
# Create SSL certs for Alluxio master to worker TLS
keys_dir=${SHARE_DIR}/keys 
if [ ! -d $keys_dir ]; then
     mkdir -p $keys_dir
fi

if [ -f $keys_dir/alluxio-tls-client-truststore.jks ]; then
     echo "- File $keys_dir/alluxio-tls-client-truststore.jks exists, skipping create SSL certs step"
else
     echo "- Creating SSL cert files"
     old_pwd=$(pwd)
     cd $keys_dir

     store_password="changeme123"

     # Generate self-signed keystore
     keytool -genkey -keyalg RSA \
          -keypass $store_password -storepass $store_password \
          -validity 360 -keysize 2048 \
          -alias $(hostname -f) \
          -dname "CN=$(hostname -f), OU=Alluxio, L=San Mateo, ST=CA, C=US" \
          -keystore alluxio-tls-$(hostname -f)-keystore.jks

     # Export the certificate's public key to a certificate file
     keytool -export -rfc -storepass $store_password \
          -alias $(hostname -f) \
          -keystore alluxio-tls-$(hostname -f)-keystore.jks \
          -file alluxio-tls-$(hostname -f).cert

     # Import the certificate to a truststore file
     keytool -import -noprompt -storepass $store_password \
          -alias $(hostname -f) \
          -file alluxio-tls-$(hostname -f).cert \
          -keystore alluxio-tls-$(hostname -f)-truststore.jks

     # Add the certificate's public key to the all inclusive truststore file
     keytool -import -noprompt -storepass $store_password \
          -alias $(hostname -f) \
          -file alluxio-tls-$(hostname -f).cert \
          -keystore alluxio-tls-client-truststore.jks

     # Set permissions and ownership on the keys
     chmod 755 $keys_dir
     chmod 400 alluxio-tls-$(hostname -f)-keystore.jks
     chmod 400 alluxio-tls-$(hostname -f)-truststore.jks
     chmod 400 alluxio-tls-$(hostname -f).cert
     chmod 400 alluxio-tls-client-truststore.jks
     chown alluxio alluxio-tls-*

     # List the contents of the trustore file
     #echo "- Contents of truststore file: $keys_dir/alluxio-tls-client-truststore.jks"
     #keytool -list -v -keystore alluxio-tls-client-truststore.jks -storepass $store_password

     # update the owner of following file, which is created by ranger's
     # "...credentialapi.buildks create sslTrustStore..." tool
     # chown alluxio /etc/ssl/certs/ranger/alluxio-plugin.jceks

     cd $old_pwd
fi

#########################
## Kerberos Principals ##
#########################
KERB_ADMIN_PRIC=${KERB_ADMIN_USER}/admin
KEYTAB_DIR=/opt/alluxio/keytabs
if [ ! -d $KEYTAB_DIR ]; then
     mkdir -p $KEYTAB_DIR
fi

if [ -f $KEYTAB_DIR/alluxio.headless.keytab ]; then
     echo "- File $KEYTAB_DIR/alluxio.headless.keytab exists, skipping create keytab files step."
else
     echo "- Creating kerberos principals"
     old_pwd=$(pwd)
     cd $KEYTAB_DIR

     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -pw ${KERB_USER_PASS} alluxio@${REALM}"
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k alluxio.headless.keytab alluxio@${REALM}"

     # Create kerberos principal for "northbound" kerberization
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey alluxio/$(hostname -f)@${REALM}"
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k alluxio.$(hostname -f).keytab alluxio/$(hostname -f)@${REALM}"

     chown alluxio:alluxio alluxio.headless.keytab
     chown alluxio:alluxio alluxio.$(hostname -f).keytab
     chmod 400 alluxio.headless.keytab
     chmod 400 alluxio.$(hostname -f).keytab

     # copy the alluxio headless keytab file to shared directory, and it will be used by alluxio worker
     cp alluxio.headless.keytab $SHARE_DIR/

     cd $old_pwd
fi

####################################
## Start Alluxio Master Processes ##
####################################

# switch to user "alluxio"
su - alluxio

# Acquire Kerberos ticket for the alluxio user
kinit -kt ${KEYTAB_DIR}/alluxio.$(hostname -f).keytab alluxio/$(hostname -f)@${REALM}

# Format the master node journal
echo "- Formatting Alluxio journal"
alluxio formatJournal

# Start the Alluxio master node daemons
echo "- Starting Alluxio master daemons (master, job_master, proxy)"
alluxio-start.sh master
alluxio-start.sh job_master
alluxio-start.sh proxy

# destroy the kerberos ticket
kdestroy
