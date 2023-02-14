Get into the impala-shell container and run impala-shell.

    docker exec -it impala-impala-shell-1 bash
    impala-shell -i impala-impalad.alluxio.io

# TO DELETE

    docker exec -it impala-namenode-1 bash

    echo "1,Jane Doe,jdoe@email.com,555-1234"               > /tmp/alluxio_table.csv
    echo "2,Frank Sinclair,fsinclair@email.com,555-4321"   >> /tmp/alluxio_table.csv
    echo "3,Iris Culpepper,icullpepper@email.com,555-3354" >> /tmp/alluxio_table.csv

    hdfs dfs -mkdir -p /user/ava/alluxio_table
    hdfs dfs -copyFromLocal /tmp/alluxio_table.csv /user/ava/alluxio_table
    hdfs dfs -cat /user/ava/alluxio_table/alluxio_table.csv

    exit


    docker exec -it impala-impala-shell-1 bash

    impala-shell -i impala-impalad.alluxio.io

    use default;

     CREATE EXTERNAL TABLE hdfs_table (
          customer_id BIGINT,
          name STRING,
          email STRING,
          phone STRING ) 
     ROW FORMAT DELIMITED
     FIELDS TERMINATED BY ','
     LOCATION 'hdfs://namenode.alluxio.io:9000/user/ava/alluxio_table';