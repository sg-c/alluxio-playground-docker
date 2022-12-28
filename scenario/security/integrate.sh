#!/bin/bash

set -xe

# set PWD
cd "$(dirname $0)"

docker exec security-kdc-1 /integration/kerberos/security/setup.sh
docker exec security-namenode-1 /integration/hadoop/security/setup.sh