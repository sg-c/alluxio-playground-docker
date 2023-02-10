# alluxio-playground-docker

## What does this repo do?
* Run all components (alluxio, hadoop, presto, spark, kerberos, ranger, prometheus, grafana, ...) on one machine.
* All components are set up and ready to be used.
* Integrations are organized based on use cases (scenarios). For each use case, integration steps are codified and can be repeated.
* For users to quickly try different functionalities and integrations of Alluxio.

## What is this repo not for?
* Performance testing.
* Stress testing.


# Project structure (directory layout) explanation

When we deploy a cluster on a set of physical machines or EC2 instances from scratch, we need to deal with a few things:
- profile the machines and get them ready (choose the CPU, Memroy, Disks, and connect them to the network)
- install OS and necessary softwares that required by the framework (install centos, libfuse.so, ssh agent..., download alluxio tarball, created and set up directories and etc.)
- start the framework and make sure it works with the most basic configurations (alluxio-start.sh all with default alluxio-site.properites)
- change the configuration files and restart the framework for more advanced setup and integrations (HA, Kerberos integration and etc.)
- execute commands or run jobs to verify the final configuration works

With Docker virtualization, each above step is codified and reflected by files in the different directories.
- `/component`: YAML files in this directory specify the container setup (network, volumes) for each component, and they are roughtly equivalent to machine profiling
- `/dockerfile`: Dockerfiles in this directory specify the Docker images (i.e. what OS to use and software to install), and they can be treated as software installation
- `/config`: files in this directory contain the "barebone" configurations for each framework
- `/entrypoint`: together with files in `/config`, entrypoint.sh scripts in this directory start frameworks in the most basic mode
- `/integration`: files in this directory are configuration files and scripts; they together simulate advanced setup and integration steps
- `/scenarios`: files in this directory are organized by "use cases"; docker-compose.yml files in this directory put all together the frameworks used in a particular scenario to simulate sophiscated setup; 
`integrate.sh` files in this directory execute scripts from the `/integration` directory within containers to do integrations and bring frameworks to run in a more advanced mode


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


# Install docker daemon on EC2

> 🚧 Note
>
> If you see `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`
> when you execute `docker compose up -d`, it's because the docker daemon is not running. You need to follow
> the steps below to install and start docker daemon.

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

# How-to
## What if I cannot see the web UI of a running service?
Make sure following operations are done.
* The port of the web UI process is exposed by the container to the host machine. This can be configured in the docker YAML files in the /component directory or the docker-compose.yml files in the /scenario directory. (Tips: you can use `docker inspect <container-name>` check the ports exposed on host machine.)
* Update the AWS `Security Group`->`Inbound Rules`. Make sure the port of the web UI process is added in the `Inbound Rules`. (Tips: Don't make the Inbound Rules too open, otherwise, you EC2 instance is at risk of being port scanned and exploited by hackers.)

# TODO
- [ ] Allow users to use different versions of components.
- [X] Add instruction for using this repo on EC2 instance.
- [X] Provide script for starting/restarting each individual component.
- [ ] Add a section for frequently used `docker` and `docker compose` commands.
- [ ] Refactoring (scenario/security): move the Dockerfile for alluxio to /dockerfile/alluxio dir.
- [ ] Refactoring (scenario/security): move all scripts for creating principals and associated keytab files to the kdc container to run; put all the keytab files in the the $SHARE_DIR/keytabs/ dir.