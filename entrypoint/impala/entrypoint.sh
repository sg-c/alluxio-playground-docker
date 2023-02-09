#!/bin/bash

set -xe

# copy hive-site.xml to impala config dir
cp /config/impala/hive-site.xml /opt/impala/conf

# wait forever
while true; do sleep 100; done