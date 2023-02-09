# Preparation
Configuration docker network

    alluxio-playground-docker/network.sh create

Configuration docker volume

    alluxio-playground-docker/volume.sh create

Copy the Alluxio license file to /config/alluxio/license.json

    cp ~/Downloads/alluxio-enterprise-license.json /config/alluxio/license.json

# Scenarios
|Scenario|Description|Components|
|--------|-----------|----------|
|security|Show how to integrate with Kerberos and Ranger.|<ul><li>HDFS</li><li>Presto</li><li>Hive Metastore</li><li>Kerberos</li><li>Ranger</li></ul>|
|basic|Simple cluster with S3 and Presto for basic Alluxio integration.|<ul><li>Presto</li></ul>|
|impala|Show the integration with Impala and Iceberg.|<ul><li>S3</li><li>Apache Impala</li><li>Iceberg</li></ul>|
