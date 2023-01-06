FROM apache/hadoop:3

USER root

# Password to use for various users, including root user
ENV ROOT_PASSWORD=changeme
ENV NON_ROOT_PASSWORD=changeme

# Install required packages
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y mysql-connector-java

# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux


# Create Java Environment
RUN if [ ! -d /usr/lib/jvm/java-1.8.*-openjdk-1.8.*.x86_64 ]; then \
       echo " ERROR - Unable to create Java environment because Java directory not found at '/usr/lib/jvm/java-1.8.*-openjdk-1.8.*.x86_64'. Skipping."; \
    else \
      java_dir=$(ls /usr/lib/jvm/ | grep java-1\.8\.); \
      export JAVA_HOME=/usr/lib/jvm/${java_dir}/jre; \
      echo "#### Java Environment ####" >> /etc/profile.d/java-env.sh; \
      echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java-env.sh; \
      echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java-env.sh; \
    fi 

# Enable Java JCE Policy for OpenJDK
RUN source /etc/profile.d/java-env.sh && \
    if [ ! -d $JAVA_HOME/jre/lib/security ]; then \
       echo " ERROR - OpenJDK is not installed, can't configure JCE Policy. Skipping. "; \
    else \
       sed -i "/crypto.policy=/d" $JAVA_HOME/jre/lib/security/java.security; \
       echo "crypto.policy=unlimited" >> $JAVA_HOME/jre/lib/security/java.security; \
    fi 

# Install Hive and Hive metastore
#
ARG HIVE_VERNO="3.1.3"
ENV HIVE_HOME=/opt/hive
ENV HIVE_CONF_DIR=/etc/hive/conf
RUN useradd -d $HIVE_HOME --no-create-home --uid 1002 --gid root hive \
    && echo $NON_ROOT_PASSWORD | passwd hive --stdin \
    && \
    if [ ! -f /tmp/local_files/apache-hive-${HIVE_VERNO}-bin.tar.gz ]; then \
        mkdir -p /tmp/local_files ; \
        curl https://archive.apache.org/dist/hive/hive-${HIVE_VERNO}/apache-hive-${HIVE_VERNO}-bin.tar.gz \
             -o /tmp/local_files/apache-hive-${HIVE_VERNO}-bin.tar.gz; \ 
    fi \
    && tar xvzf /tmp/local_files/apache-hive-${HIVE_VERNO}-bin.tar.gz -C /opt/ \
    && rm -f /tmp/local_files/apache-hive-${HIVE_VERNO}-bin.tar.gz \
    && ln -s /opt/apache-hive-${HIVE_VERNO}-bin $HIVE_HOME \
    && /bin/cp /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/ \
    && chown -R hive:root $HIVE_HOME/ \
    && chmod -R g+rw $HIVE_HOME/ \
    && mkdir -p /etc/hive \
    && ln -s $HIVE_HOME/conf $HIVE_CONF_DIR \
    && echo "#### Hive Environment ####" >> /etc/profile \
    && echo "export HIVE_HOME=$HIVE_HOME" >> /etc/profile \
    && echo "export HIVE_CONF_DIR=$HIVE_CONF_DIR" >> /etc/profile \
    && echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> /etc/profile \
    && echo "export HADOOP_HOME=/opt/hadoop" >> /etc/profile