#!/bin/bash

set -x

# set up hadoop clusters
docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-namenode-beijing-1 ./setup-namenode.sh
docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-namenode-shanghai-1 ./setup-namenode.sh

docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-datanode-beijing-1 ./setup-datanode.sh
docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-datanode-shanghai-1 ./setup-datanode.sh

docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-namenode-beijing-1 ./setup-dfsrouter.sh
docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-namenode-shanghai-1 ./setup-dfsrouter.sh

docker exec -w /integration/hdfs-rbf/hadoop hdfs-rbf-hdfs-client-1 ./setup-client.sh

docker exec -w /integration/hdfs-rbf/alluxio hdfs-rbf-alluxio-master-1 ./setup-alluxio-master.sh
docker exec -w /integration/hdfs-rbf/alluxio hdfs-rbf-alluxio-worker-1 ./setup-alluxio-worker.sh