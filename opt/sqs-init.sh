#!/bin/sh 

mkdir -p /opt/config

# First, copy default configs:
cp /opt/*.conf /opt/config/

# Secondly, copy custom configs:
cp /opt/custom/*.conf /opt/config/

# Now copy sqs-insight config to correct location:
cp /opt/config/sqs-insight.conf /opt/sqs-insight/config/config_local.json

sleep 1
exit 0

