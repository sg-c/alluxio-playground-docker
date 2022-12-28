#!/bin/bash

set -x

docker exec security-namenode-1 /integration/security/hadoop/setup-common.sh
docker exec security-namenode-1 /integration/security/hadoop/setup-namenode.sh
docker exec security-datanode-1 /integration/security/hadoop/setup-datanode.sh