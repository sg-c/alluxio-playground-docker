#!/bin/bash

component_dir=$(cd `dirname $0` && pwd -P)
integrate_dir=`dirname $comp_dir`
integrate_name=`basename $integrate_dir`

export SHARE_DIR=$INTEGRATION_TMP_DIR/$integrate_name

if [[ ! -d $SHARE_DIR ]]; then
    mkdir -p $SHARE_DIR
    chmod 777 $SHARE_DIR
fi