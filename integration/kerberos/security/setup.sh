#!/bin/bash

# wait for kdc to start and ready
while [ ! -f /kerberos_initialized ]; do
    sleep 2
done

# copy krb5.conf files to /share
cp /etc/krb5.conf /share/krb5.conf
chmod 777 /share/krb5.conf

mkdir -p /share/krb5.conf.d
cp /etc/krb5.conf.d/* /share/krb5.conf.d/*
chmod 777 /share/krb5.conf.d/*