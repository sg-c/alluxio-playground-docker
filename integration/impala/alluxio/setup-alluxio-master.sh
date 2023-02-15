#!/bin/bash

source ./setup-common.sh

####################################
## Start alluxio master processes ##
####################################
    ``
    # switch to user "alluxio"
    su - alluxio``

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
