#!/bin/bash

set -x

# run scripts that are common for both alluxio master and alluxio worker
source ./setup-common.sh

#######################
## SSL Configuration ##
#######################
# Create SSL certs for Alluxio worker to worker TLS
keys_dir=${SHARE_DIR}/keys 
if [ ! -d $keys_dir ]; then
     mkdir -p $keys_dir
fi

if [ -f $keys_dir/alluxio-tls-$(hostname -f)-keystore.jks ]; then
     echo "- File $keys_dir/alluxio-tls-$(hostname -f)-keystore.jks exists, skipping create SSL certs step"
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

if [ -f $KEYTAB_DIR/alluxio.$(hostname -f).keytab ]; then
     echo "- File $KEYTAB_DIR/alluxio.$(hostname -f).keytab exists, skipping create keytab files step."
else
     echo "- Creating kerberos principals"
     old_pwd=$(pwd)
     cd $KEYTAB_DIR

     # Create kerberos principal for "northbound" kerberization
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey alluxio/$(hostname -f)@${REALM}"
     kadmin -p ${KERB_ADMIN_PRIC} -w ${KERB_ADMIN_PASS} -q "xst -k alluxio.$(hostname -f).keytab alluxio/$(hostname -f)@${REALM}"

     chown alluxio:alluxio alluxio.$(hostname -f).keytab
     chmod 400 alluxio.$(hostname -f).keytab

     # copy from shared directory the alluxio headless keytab file, which is prepared by the alluxio master container
     cp $SHARE_DIR/alluxio.headless.keytab .

     cd $old_pwd
fi

####################################
## Start Alluxio Worker Processes ##
####################################

# switch to user "alluxio"
su - alluxio

# Acquire Kerberos ticket for the alluxio user
kinit -kt ${KEYTAB_DIR}/alluxio.$(hostname -f).keytab alluxio/$(hostname -f)@${REALM}

# Start the Alluxio master node daemons
echo "- Starting Alluxio worker daemons (worker, job_worker, proxy)"
alluxio-start.sh worker
alluxio-start.sh job_worker
alluxio-start.sh proxy

# destroy the kerberos ticket
kdestroy