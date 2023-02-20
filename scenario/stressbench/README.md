# Description

In this demo, HDFS is configured to be the root UFS of Alluxio. Users can run StressBench tests on Alluxio.

# Quick start for scenarios "stressbench"

Start containers 
    
    cd alluxio-playground-docker/scenario/stressbench
    docker-compose up -d

Run "integrate.sh" script to configure Alluxio, and 

    ./integrate.sh

# Get into the Alluxio master container

    docker exec -it stressbench-alluxio-master-1 bash

# Run comprehensive stressbench test

This test requires Alluxio 2.9+.

## Create test files

Execute following command to create test files by StressBench.

    time alluxio runClass alluxio.stress.cli.StressMasterBench \
    --operation CreateFile --warmup 5s \
    --duration 15s \
    --client-type AlluxioHDFS

Check the created files.

    alluxio fs ls /stress-master-base/files/local-task-0

## Run Master StressBench test

Use files just created to test the performance of Master doing GetBlockLocations operation.

    time alluxio runClass alluxio.stress.cli.StressMasterBench \
    --operation GetBlockLocations
