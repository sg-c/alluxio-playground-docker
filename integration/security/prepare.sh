#!/bin/bash

export SHARE_DIR=$INTEGRATION_TMP_DIR/security/${REALM}

if [[ ! -d $SHARE_DIR ]]; then
    mkdir -p $SHARE_DIR
    chmod 777 $SHARE_DIR
fi