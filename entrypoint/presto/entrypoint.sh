#!/bin/bash

# run presto image's default entrypoint script
/opt/entrypoint.sh

# wait forever
while true; do sleep 100; done
