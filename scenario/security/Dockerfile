FROM alluxio/alluxio-enterprise:2.9.0-1.0

# switch to root user for yum install
USER root

# install krb5 client libs
RUN yum update -y \
    && yum install -y krb5-libs krb5-workstation \
    && yum clean all

# switch back to alluxio user specified in the original image
USER ${ALLUXIO_UID}