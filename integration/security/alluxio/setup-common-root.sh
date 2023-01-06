#!/bin/bash

# Note
#
# Alluxio official docker image doesn't have sudo program available.
# Hence, operations such as updating /etc/krb5.conf which require root
# permissions will be executed separately by this script.
# 
# In order to execute this script, provide "-u root" option to the 
# "docker exec" command. 
# For example, "docker exec -u root -it security-alluxio-master-1 bash"

set -x

# execute preparing scripts
source ../prepare.sh

##############################
## Kerberos related setups ###
##############################
# import kerberos related functions
source ../kerberos/utils.sh
# copy krb5.conf files from container "kdc" to current container
copy_krb5_conf $(id -un) $(id -gn)