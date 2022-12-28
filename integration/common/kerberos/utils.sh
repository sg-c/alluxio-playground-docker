#!/bin/bash

copy_krb5_conf() {
    user=$1
    group=$2
    f_mod="644"
    d_mod="755"

    cp /share/krb5/krb5.conf /etc/krb5.conf
    chown $user:$group /etc/krb5.conf
    chmod $f_mod /etc/krb5.conf

    mkdir -p /etc/krb5.conf.d
    chmod $d_mod /etc/krb5.conf.d

    cp /share/krb5/krb5.conf.d/* /etc/krb5.conf.d/
    chown $user:$group /etc/krb5.conf.d/*
    chmod $f_mod /etc/krb5.conf.d/*

}