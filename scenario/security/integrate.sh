#!/bin/bash

docker exec security-kdc-1 /integration/hadoop/security/setup.sh
docker exec security-namenode-1 /integration/hadoop/security/setup.sh