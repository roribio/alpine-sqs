#!/bin/sh 

mkdir -p /opt/config

# First, copy default configs:
cp /opt/*.conf /opt/config/

# Secondly, copy custom configs:
cp /opt/custom/*.conf /opt/config/

sleep 1
exit 0

