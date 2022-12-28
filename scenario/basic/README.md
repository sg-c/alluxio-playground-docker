# Scenario Description
In this scenario, Presto (driver and worker in one container) and Alluxio (one master and one worker in separate containers) are created. User can do following this with them:
* mount Alluxio with S3 and try out Alluxio
* practice integrating Alluxio with Presto

# Mount S3 to Alluxio

    # get into the alluxio-master container
    docker exec -it basic-alluxio-master-1 bash
    # mount S3 to Alluxio's /s3 directory
    alluxio fs mount  --option s3a.accessKeyId=<S3_ACCESS_KEY_ID>  --option s3a.secretKey=<S3_SECRET_KEY>  /s3 s3://alluxio.saiguang.public
    # run Alluxio's runTests command
    alluxio runTests
    # show contents in s3
    alluxio fs ls /s3

# Presto Intergration
