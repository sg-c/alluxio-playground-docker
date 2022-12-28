# Components

This directory contains common docker-compose files that can be used to create different components such as Kerberos, Rangers, ALLUXIO, Hadoop, and etc.

YAML files in this directory are referenced and used by docker-compose.yml files in the subdirectories of ../scenario.

When the container of a component is started for the first time, "entrypoint.sh" in the ../entrypoint directory and configurations in the ../config directory are used to together to do basic setups.

All the component containers have following volumes in common:
- a volume mounted to the /share directory in the container; this volume is created/removed by the "alluxio_playground_docker/volume.sh" script and can be used for sharing files between containers
- a volume mounted to the /integration directory in the container; this volume is a host path to the "alluxio_playground_docker/integration"; this volumes contains integration scripts
- a volume mounted to the /config directory in the container; this volume is a host path to the "alluxio_playground_docker/config"; this volumes contains startup configuration files
- a volume mounted to the /entrypoint directory in the container; this volume is a host path to the "alluxio_playground_docker/entrypoint"; this volumes contains startup scripts

The networks and volumes used by components defined here are external resources that are created/removed separately.

# Component: Kerberos

* To use this component, env "REALM" and "DOMAIN" must be defined.
* This component will create "/etc/krb5.conf" and "/etc/krb5.conf.d/krb5.conf" with appropriate REALM and domains.
* "/etc/krb5.conf" will be copied to "/share/krb5.conf", and "/etc/krb5.conf.d/krb5.conf" will be copied to "/share/krb5.conf.d/krb5.${DOMAIN}.conf".