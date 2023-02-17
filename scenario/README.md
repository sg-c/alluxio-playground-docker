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
|pddm|Show Union Mount and PDDM features with HDFS and S3 UFS.|<ul><li>HDFS</li><li>S3</li></ul>|
