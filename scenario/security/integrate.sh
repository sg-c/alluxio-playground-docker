#!/bin/bash

set -x

echo "sleep 15 sec and wait for containers are up and ready"
sleep 15

# set up Kerberos
docker exec -w /integration/security/kerberos security-kdc-1 ./setup-kdc.sh

# set up hadoop
docker exec -w /integration/security/hadoop security-namenode-1 ./setup-namenode.sh
docker exec -w /integration/security/hadoop security-datanode-1 ./setup-datanode.sh

# set up alluxio using user "root"; see alluxio-playground-docker/component/README.md for the reason
# why we need to execute some scripts using "root" user.
docker exec -w /integration/security/alluxio -u root security-alluxio-master-1 ./setup-common-root.sh
docker exec -w /integration/security/alluxio -u root security-alluxio-worker-1 ./setup-common-root.sh

# set up alluxio using user "alluxio"
docker exec -w /integration/security/alluxio security-alluxio-master-1 ./setup-alluxio-master.sh
docker exec -w /integration/security/alluxio security-alluxio-worker-1 ./setup-alluxio-worker.sh

# set up hive metastore
docker exec -w /integration/security/hivemetastore security-hms-1 ./setup-hms.sh

# set up Presto server
docker exec -w /integration/security/presto security-presto-1 ./setup-presto.sh