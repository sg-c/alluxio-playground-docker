# Build custom Alluxio image
The official Alluxio images don't have Kerberos client libs (krb5-libs and krb5-workstation) installed.
As a result, we need to build a custom image to include these libs.

Before executing following build commands, make sure the alluxio image tag used in the ./Dockerfile is consistent with that specified in the command line.

Build the image with cached layers.

    docker build -t alluxio-playground-docker/security-alluxio-enterprise:2.9.0-1.0 . 2>&1 | tee  ./build-log.txt

Build the image without cached layers.

    docker build --no-cache -t alluxio-playground-docker/security-alluxio-enterprise:2.9.0-1.0 . 2>&1 | tee  ./build-log.txt

# Quick start for scenarios "security"

Before bringing up the docker compose containers, follow the "prepare" section in the alluxio-playground-docker/scenario/README.md to prepare the environment.

Start containers 
    
    cd alluxio-playground-docker/scenario/security
    docker-compose up -d

Run "integrate.sh" script to integrate Kerberos, HDFS, Alluxio and etc with each other.

    ./integrate.sh

The `./integrate.sh` script is the entry-point for integrations of all components. It executes the integration scripts of each component in its own container to finish the integration steps.
You can start from the `./integrate.sh` and checkout scripts it executes to see detailed integration steps.

Run following commands to create 2 user principals for "ava" and "bob" with password "changeme". (Run the command below on host instead of in container; similarly hereafter)

    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme ava@BEIJING.COM"
    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme bob@BEIJING.COM"
    
# Try out Kerberos integration.
## Kerberized HDFS
Get into namenode container
    
    docker exec -it security-namenode-1 bash

Do `ls` without `kinit` will fail with security error.

    hdfs dfs -ls /

Do `ls` after `kinit` will succeed.

    echo changeme | kinit ava
    hdfs dfs -ls /

## Kerberized Alluxio
Get into the alluxio master container

    docker exec -it security-alluxio-master-1 bash

Do `ls` without `kinit` will fail with security error.

    alluxio fs ls /

Do `ls` after `kinit` will succeed.

    echo changeme | kinit ava
    alluxio fs ls /

## Prepare data and tables
Get into the alluxio master container

    docker exec -it security-alluxio-master-1 bash

Init kerberos principal "ava"

    echo changeme | kinit ava

As a test user, create a small test data file

     echo "1,Jane Doe,jdoe@email.com,555-1234"               > /tmp/alluxio_table.csv
     echo "2,Frank Sinclair,fsinclair@email.com,555-4321"   >> /tmp/alluxio_table.csv
     echo "3,Iris Culpepper,icullpepper@email.com,555-3354" >> /tmp/alluxio_table.csv

Create a directory in HDFS and upload the data file

    alluxio fs ls /
    alluxio fs mkdir /user/ava
    alluxio fs mkdir /user/ava/alluxio_table/

    alluxio fs copyFromLocal /tmp/alluxio_table.csv /user/ava/alluxio_table/

    alluxio fs persist /user/ava/alluxio_table/alluxio_table.csv

Make /user/user1 only accessible by ava but not bob

     alluxio fs chmod 750 /user/ava

Get into the hive metastore container

     docker exec -it security-hms-1 bash

Start a hive session using hive client

     su - hive
     echo changeme | kinit ava
     hive

Create a table in Hive that points to the HDFS location

     CREATE DATABASE alluxio_test_db;

     USE alluxio_test_db;

     CREATE EXTERNAL TABLE hdfs_table (
          customer_id BIGINT,
          name STRING,
          email STRING,
          phone STRING ) 
     ROW FORMAT DELIMITED
     FIELDS TERMINATED BY ','
     LOCATION 'hdfs://namenode.beijing.com:9000/user/ava/alluxio_table';

Create a table in Hive that points to the Alluxio virtual filesystem 

     USE alluxio_test_db;

     CREATE EXTERNAL TABLE alluxio_table (
          customer_id BIGINT,
          name STRING,
          email STRING,
          phone STRING ) 
     ROW FORMAT DELIMITED
     FIELDS TERMINATED BY ','
     LOCATION 'alluxio://alluxio-master.beijing.com:19998/user/ava/alluxio_table';

# Kerberized Presto (with Hive Connector)

Get into the presto container.

    docker exec -it security-presto-1 bash

Create user for "ava" and "bob".

    useradd ava
    useradd bob

Run presto cli as ava.

    su ava -c "presto-cli --server localhost:8080 --catalog hive --schema alluxio_test_db"

Run query.

    SELECT * from hdfs_table;
    SELECT * from alluxio_table;

Because the impersonation is enabled, and the mode of hdfs:///user/ava is set to 750, so user "bob" doesn't have the permission to access the data and cannot successfully run the query.

Run presto cli as bob.

    su bob -c "presto-cli --server localhost:8080 --catalog hive --schema alluxio_test_db"

Run query.

    SELECT * from hdfs_table;
    SELECT * from alluxio_table;

Note:
1. There is NO Kerberos protection for presto-cli accessing the presto coordinator, so in the presto container, it doesn't matter if you do "kinit" before executing presto-cli; to enable the presto "internal" kerberos protection, refer to https://prestodb.io/docs/current/security/server.html#system-access-control-plugin and https://prestodb.io/docs/current/security/cli.html.
2. The Presto is configured correctly to access Kerberized HDFS and Alluxio, because both HDFS and Alluxio in this scenario are Kerborized.
3. Impersonation is enabled in this demo.