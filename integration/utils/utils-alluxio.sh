#!/bin/bash

share_alluxio_cli_jar() {
    if [[ ! -d ${SHARE_DIR} ]]; then
        echo "SHARE_DIR is NOT prepared"
        exit 1
    fi

    ALLUXIO_VER=$(alluxio version)
    ALLUXIO_CLI_JAR=alluxio-${ALLUXIO_VER}-client.jar

    if [[ ! -f ${SHARE_DIR}/${ALLUXIO_CLI_JAR} ]]; then
        cp /opt/alluxio/client/${ALLUXIO_CLI_JAR} ${SHARE_DIR}/${ALLUXIO_CLI_JAR}
        chmod 777 ${SHARE_DIR}/${ALLUXIO_CLI_JAR}
        cp ${SHARE_DIR}/${ALLUXIO_CLI_JAR} ${SHARE_DIR}/alluxio-client.jar
    fi
}