#!/bin/bash

set -x

# set up alluxio using user "alluxio"
docker exec -w /integration/stressbench/alluxio stressbench-alluxio-master-1 ./setup-alluxio-master.sh
docker exec -w /integration/stressbench/alluxio stressbench-alluxio-worker-1 ./setup-alluxio-worker.sh
