#!/bin/bash

copy_krb5_conf() {
    user=$1
    group=$2
    f_mod="644"
    d_mod="755"

    local SUDO=
    [[ -x $(command -v sudo) ]] && SUDO=sudo

    $SUDO cp ${SHARE_DIR}/krb5.conf /etc/krb5.conf
    $SUDO chown $user:$group /etc/krb5.conf
    $SUDO chmod $f_mod /etc/krb5.conf

    $SUDO mkdir -p /etc/krb5.conf.d
    $SUDO chmod $d_mod /etc/krb5.conf.d

    $SUDO cp ${SHARE_DIR}/krb5.conf.d/* /etc/krb5.conf.d/
    $SUDO chown $user:$group /etc/krb5.conf.d/*
    $SUDO chmod $f_mod /etc/krb5.conf.d/*
}