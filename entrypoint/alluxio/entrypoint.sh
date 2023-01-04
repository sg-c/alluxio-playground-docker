#!/bin/bash

# change the permissions of /share directory
sudo chmod 777 /share

# wait forever
if [[ $1 == "-bash" ]]; then
  /bin/bash
else
  tail -f ${HADOOP_LOG}
fi

# while true; do sleep 100; done