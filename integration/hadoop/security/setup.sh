#!/bin/bash

set -xe

# set PWD
cd "$(dirname $0)"

# import kerberos related functions
source ../../common/kerberos/utils.sh
# copy krb5.conf files from container "kdc" to current container
copy_krb5_conf root root