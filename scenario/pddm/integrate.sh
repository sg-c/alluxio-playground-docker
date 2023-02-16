#!/bin/bash

set -x

# set up alluxio using user "alluxio"
docker exec -w /integration/pddm/alluxio pddm-alluxio-master-1 ./setup-alluxio-master.sh
docker exec -w /integration/pddm/alluxio pddm-alluxio-worker-1 ./setup-alluxio-worker.sh
