# Description

In this demo, Alluxio is configured for PDDM use case. Both HDFS (root UFS) and S3 (nested UFS) will be mounted to the Alluxio namespace. 
A few files will be created in HDFS, and eventually, they will be moved to S3 by PDDM after corresponding policy is set up.

# Quick start for scenarios "pddm"

Start containers 
    
    cd alluxio-playground-docker/scenario/pddm
    docker-compose up -d

Make sure the you have following things ready:
* aws access key id & aws secret key
* S3 bucket to which you have access with above credentials

Run "integrate.sh" script to configure Alluxio, and 

    ./integrate.sh

# Mount S3

Mount s3 in the container.

    docker exec -it pddm-alluxio-master-1 bash

Use `alluxio fs ls /` command to update metaedata first before mounting S3.

    alluxio fs ls /

    alluxio fs mount \
    --option s3a.accessKeyId=<AWS_ACCESS_KEY_ID> \
    --option s3a.secretKey=<AWS_SECRET_KEY_ID> \
    /tmp/s3 s3://<S3_BUCKET>/<S3_DIRECTORY>

# Create test files in HDFS

    alluxio fs mkdir /tmp/pddm

    t=$(date -I)-$(date +%s) && echo $t > /tmp/pddm-test-$t && alluxio fs copyFromLocal /tmp/pddm-test-$t /tmp/pddm
    sleep 2
    t=$(date -I)-$(date +%s) && echo $t > /tmp/pddm-test-$t && alluxio fs copyFromLocal /tmp/pddm-test-$t /tmp/pddm

    alluxio fs persist /tmp/pddm

    alluxio fs ls /tmp/pddm

# Export AWS credentials for executing AWS S3 commands

    export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
    export AWS_SECRET_KEY_ID=<AWS_SECRET_KEY_ID>

# Delete test files created previously

    aws s3 rm s3://<S3_BUCKET> --recursive --exclude "*" --include "pddm-test"

# Union mount HDFS and S3

    alluxio fs mount \
    --option alluxio-union.hdfs.uri=hdfs://namenode.alluxio.io:9000/tmp/pddm \
    --option alluxio-union.s3.uri=s3://<S3_BUCKET>/<S3_DIRECTORY> \
    --option alluxio-union.s3.option.s3a.accessKeyId=<AWS_ACCESS_KEY_ID> \
    --option alluxio-union.s3.option.s3a.secretKey=<AWS_SECRET_KEY_ID> \
    --option alluxio-union.priority.read=hdfs,s3 \
    --option alluxio-union.collection.create=hdfs  \
    /tmp/union union://pddm-test/

After the success execution of above command, /tmp/union will be created in the alluxio namespace.
Check the contents in /tmp/union.

    alluxio fs ls /tmp/union

Check the contents in the S3 bucket.

    aws s3 ls s3://<S3_BUCKET>/<S3_DIRECTORY>/

In case it's needed, use following command to remove test files created previously.


    export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
    export AWS_SECRET_KEY_ID=<AWS_SECRET_KEY_ID>

# Add data management policy

Set up the PDDM policy with following command

    alluxio fs policy add /tmp/union "ufsMigrate(olderThan(1s), UFS[hdfs]:REMOVE, UFS[s3]:STORE)"

Then, watch the content in the S3 bucket.

    watch aws s3 ls s3://<S3_BUCKET>/<S3_DIRECTORY>/

Also, check that the files are removed from HDFS.

    alluxio fs -Dalluxio.user.file.metadata.sync.interval=0 ls /tmp/pddm