#!/bin/bash

set -xe

# copy hive-site.xml to impala config dir
cp /config/impala/hive-site.xml /opt/impala/conf

case $(hostname -f) in
*impalad*)
    /opt/impala/bin/daemon_entrypoint.sh \
        /opt/impala/bin/impalad \
        -log_dir=/opt/impala/logs \
        -abort_on_config_error=false \
        -state_store_host=impala-statestored.alluxio.io \
        -catalog_service_host=impala-catalogd.alluxio.io \
        -mem_limit_includes_jvm=true \
        -use_local_catalog=true \
        -rpc_use_loopback=true \
        -redirect_stdout_stderr=false \
        -use_resolved_hostname=true
    ;;
*statestored*)
    /opt/impala/bin/daemon_entrypoint.sh \
        /opt/impala/bin/statestored \
        -log_dir=/opt/impala/logs \
        -redirect_stdout_stderr=false \
        -use_resolved_hostname=true
    ;;
*catalogd*)
    /opt/impala/bin/daemon_entrypoint.sh \
        /opt/impala/bin/catalogd \
        -log_dir=/opt/impala/logs \
        -abort_on_config_error=false \
        -state_store_host=statestored \
        -catalog_topic_mode=minimal \
        -hms_event_polling_interval_s=1 \
        -invalidate_tables_on_memory_pressure=true \
        -redirect_stdout_stderr=false \
        -use_resolved_hostname=true
    ;;
esac

# wait forever
while true; do sleep 100; done
