#!/bin/bash

copy_krb5_conf() {
    user=$1
    group=$2
    f_mod="644"
    d_mod="755"

    sudo cp /share/krb5.conf /etc/krb5.conf
    sudo chown $user:$group /etc/krb5.conf
    sudo chmod $f_mod /etc/krb5.conf

    sudo mkdir -p /etc/krb5.conf.d
    sudo chmod $d_mod /etc/krb5.conf.d

    sudo cp /share/krb5.conf.d/* /etc/krb5.conf.d/
    sudo chown $user:$group /etc/krb5.conf.d/*
    sudo chmod $f_mod /etc/krb5.conf.d/*
}