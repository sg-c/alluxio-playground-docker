# Description

In this demo, HDFS RBF (Router-Based Federation) is set up and Alluxio talks to HDFS via HDFS router namespace.

HDFS has 2 types of Federation setups. One is [HDFS Federation](https://hadoop.apache.org/docs/r3.3.1/hadoop-project-dist/hadoop-hdfs/Federation.html) and the other is [HDFS Router-based Federation](https://hadoop.apache.org/docs/r3.3.1/hadoop-project-dist/hadoop-hdfs-rbf/HDFSRouterFederation.html#Mount_table_management), which is a sort of enhanceent of the former. This demo is for the later setup.

2 independent HDFS clusters (NN:namenode.beijing.io and NN:namenode.shanghai.io) are federated by the same DFS Router.

# About this docker compose

Following containers are created:
- namenode-beijing: HDFS NN for domian beijing.io; NN and DfsRouter processes running in this container
- namenode-shanghai: HDFS NN for domian shanghai.io; NN and DfsRouter processes running in this container
- datanode-beijing: HDFS DN for domian beijing.io; DN process running in this container
- datanode-shanghai: HDFS DN for domian shanghai.io; DN process running in this container
- hdfs-client: HDFS client for domain us.io; NO HDFS daemon processes running in this container, and it's mainly used for running HDFS client

> ⚠️ About `hdfs-site.xml`
> 
> It's important to separate hdfs-site.xml for server use and hdfs-site.client.xml for client use. (See the /integration/hdfs-rbf/hadoop for two files.)
>
> It seems that the DFSRouter will have some conflict and cannot work as expected if you merge hdfs-site.xml and hdfs-site.client.xml and use the merged one for starting HDFS NN and DFSRouter.

# Quick start for scenarios "hdfs-rbf"

Start containers 
    
    cd alluxio-playground-docker/scenario/hdfs-rbf
    docker-compose up -d

Run "integrate.sh" script to start HDFS RBF setup and integration Alluxio with RBF-HDFS.

    ./integrate.sh

# Prepare test data and mount NNs to HDFS Router

Upload file to HDFS in `beijing.io`

    docker exec -it hdfs-rbf-namenode-beijing-1 bash
    echo "I'm in beijing" > /tmp/beijing.txt
    hdfs dfs -copyFromLocal /tmp/beijing.txt /
    hdfs dfs -cat /beijing.txt
    exit


Upload file to HDFS in `shanghai.io`

    docker exec -it hdfs-rbf-namenode-shanghai-1 bash
    echo "I'm in shanghai" > /tmp/shanghai.txt
    hdfs dfs -copyFromLocal /tmp/shanghai.txt /
    hdfs dfs -cat /shanghai.txt
    exit

Mount `ns1 (hdfs://namenode.beijing.io:9000/)` and `ns2 (hdfs://namenode.shanghai.io:9000/)` to the DFSRouter (at `/beijing` and `shanghai` respectively).

    docker exec -it hdfs-rbf-namenode-beijing-1 bash
    hdfs dfsrouteradmin -add /beijing ns1 /
    hdfs dfsrouteradmin -add /shanghai ns2 /
    
    sleep 11
    hdfs dfsrouteradmin -ls
    exit

In the *hdfs-client* container, try out access files via DFSRouter.

    docker exec -it hdfs-rbf-hdfs-client-1 bash
    hdfs dfs -cat /beijing/beijing.txt
    hdfs dfs -cat /shanghai/shanghai.txt
    exit

# Mount RBF-HDFS to Alluxio

    docker exec -it hdfs-rbf-alluxio-master-1 bash

    alluxio fs mount \
    --option alluxio.underfs.hdfs.configuration=/opt/alluxio/conf/core-site.xml:/opt/alluxio/conf/hdfs-site.xml \
    /rbf-beijing hdfs://ns-fed/beijing


    alluxio fs mount \
    --option alluxio.underfs.hdfs.configuration=/opt/alluxio/conf/core-site.xml:/opt/alluxio/conf/hdfs-site.xml \
    /rbf-shanghai hdfs://ns-fed/shanghai

    alluxio fs cat /rbf-beijing/beijing.txt
    alluxio fs cat /rbf-shanghai/shanghai.txt