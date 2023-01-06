#!/bin/bash

set -x

# execute preparing scripts
source ../prepare.sh

# copy krb5.conf files to $SHARE_DIR to be used by other components
cp /etc/krb5.conf ${SHARE_DIR}/krb5.conf
chmod 777 ${SHARE_DIR}/krb5.conf

mkdir -p ${SHARE_DIR}/krb5.conf.d
cp /etc/krb5.conf.d/krb5.conf ${SHARE_DIR}/krb5.conf.d/krb5.conf
chmod 777 ${SHARE_DIR}/krb5.conf.d/krb5.conf
