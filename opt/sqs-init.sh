#!/bin/bash 

if [ -z "$VISIBLE_QUEUES" ]; then
    echo "No queues set, using default"
    export VISIBLE_QUEUES=default
fi

arr=$(echo $VISIBLE_QUEUES | tr "," "\n")
pos=$(( ${#arr[*]} - 1 ))
last=${arr[$pos]}

echo -n "{\"port\":9325,\"rememberMessages\":100,\"endpoints\":[" > /opt/sqs-insight.conf
for x in $arr;
do
  echo -n "{\"key\":\"access_key\",\"secretKey\":\"secret_key\",\"region\":\"us-east-1\",\"url\":\"http://localhost:9324/queue/$x\",\"visibility\":0}," >> /opt/sqs-insight.conf
done
printf '%s\n' '$' 's/.$/]}/' wq | ex /opt/sqs-insight.conf

mkdir -p /opt/config

# First, copy default configs:
cp /opt/sqs-insight.conf /opt/config/
cp /opt/elasticmq.conf /opt/config/

# Secondly, copy custom configs:
#cp /opt/custom/*.conf /opt/config/

# Now copy sqs-insight config to correct location:
cp /opt/config/sqs-insight.conf /opt/sqs-insight/config/config_local.json

sleep 1
exit 0

