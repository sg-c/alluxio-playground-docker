# alluxio-playground-docker

## What does this repo do?
* Run all components (alluxio, hadoop, presto, spark, kerberos, ranger, prometheus, grafana, ...) on one machine.
* All components are set up and ready to be used.
* Integrations are organized based on use cases (scenarios). For each use case, integration steps are codified and can be repeated.
* For users to quickly try different functionalities and integrations of Alluxio.

## What is this repo not for?
* Performance testing.
* Stress testing.

# How to use this repo
1. Create an EC2 instance on AWS
    * Instance type: c5.4xlarge
    * AMI: CentOS-7-2111-20220825_1.x86_64-d9a3032a-921c-4c6d-b150-bde168105e42 (CentOS 7)
    * Storage: 300GB
    * Network: default VPC
2. Install docker engine on EC2 (See below)
3. Checkout this repo on EC2
    * `git clone https://github.com/sg-c/alluxio-playground-docker.git`
4. Go to a sub-directory of ./scenario, and follow the README.md to start the docker compose application.

# Install docker enginer on EC2

Disable SELinux, update /etc/selinux/config file and run following command

     sudo setenforce 0

Add new group "docker"

     sudo groupadd docker

Add your user to the docker group

     sudo usermod -a -G docker centos

Install needed tools

     sudo yum -y install git yum-utils

Add package repo for docker-ce.

     sudo yum-config-manager \
          --add-repo \
          https://download.docker.com/linux/centos/docker-ce.repo

Install docker-ce (Docker Engine)

     sudo yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

Start/Stop Docker Engine

     sudo systemctl start docker
     sudo systemctl stop docker

Increase the ulimit in /etc/sysconfig/docker

     echo "nofile=1024000:1024000" | sudo tee -a /etc/sysconfig/docker
     sudo service docker start

Logout and back in to get new group membershiop

     exit

     ssh ...

# Quick start security container

Configuration network

    alluxio-playground-docker/network.sh create

Configuration volume

    alluxio-playground-docker/volume.sh create

Start containers 
    
    cd alluxio-playground-docker/scenario/security
    docker-compose up -d

Access namenode container
    
    docker exec -it security-namenode-1 bash

Init setup-common.sh and setup-namenode.sh 
    
    /integration/security/hadoop/setup-common.sh
    /integration/security/hadoop/setup-namenode.sh

Quit namenode container and Access datanode container

    docker exec -it security-datanode-1 bash
    
Init setup-common.sh setup-datanode.sh 

    /integration/security/hadoop/setup-common.sh
    /integration/security/hadoop/setup-datanode.sh

Run the following command to create 2 user principals for "ava" and "bob".

    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme ava@BEIJING.COM"
    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme bob@BEIJING.COM"
    
    kinit ava
    password：changeme
    

# TODO
- [ ] Allow users to use different versions of components.
- [X] Add instruction for using this repo on EC2 instance.
