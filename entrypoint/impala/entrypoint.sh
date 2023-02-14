#!/bin/bash

set -xe

# if [ -d /opt/impala/conf ]; then
#     # copy hive-site.xml to impala config dir
#     cp /config/impala/hive-site.xml /opt/impala/conf
# fi

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
    # for catalogd working with Hive 3.1.3, the event notification support on
    # hive 3.1.3 has not finished by the time of composing this file, so we set
    # -hms_event_polling_interval_s=0 for catalogd to workaround the a fatal error
    /opt/impala/bin/daemon_entrypoint.sh \
        /opt/impala/bin/catalogd \
        -log_dir=/opt/impala/logs \
        -abort_on_config_error=false \
        -state_store_host=statestored \
        -catalog_topic_mode=minimal \
        -hms_event_polling_interval_s=0 \
        -invalidate_tables_on_memory_pressure=true \
        -redirect_stdout_stderr=false \
        -use_resolved_hostname=true
    echo hi
    ;;
*hms*)
    # start hms; the hms-entrypoint is a built-in script in the image
    /hms-entrypoint.sh hms
    ;;
*)
    # do nothing for other containers such as impala-shell
    ;;
esac

# wait forever
while true; do sleep 100; done
