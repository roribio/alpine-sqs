#!/bin/bash

if [ -z "$VISIBLE_QUEUES" ]; then
    echo "No queues set, using default"
    export VISIBLE_QUEUES=default
fi

if [ -z "$QUEUE_ACCESS_KEY" ]; then
    echo "Access key not set, using default"
    export QUEUE_ACCESS_KEY=notValidKey
fi

if [ -z "$QUEUE_SECRET_KEY" ]; then
    echo "Secret key not set, using default"
    export QUEUE_SECRET_KEY=notValidSecret
fi

arr=$(echo $VISIBLE_QUEUES | tr "," "\n")

INSIGHT=$(echo -n "{\"port\":9325,\"rememberMessages\":100,\"endpoints\":[")
ELASTICMQ=$(echo -e "include classpath(\"application.conf\")\n\nnode-address {\n\tprotocol = http\n\thost = \"*\"\n\tport = 9324\n\tcontext-path = \"\"\n}\n\nrest-sqs {\n\tenabled = true\n\tbind-port = 9324\n\tbind-hostname = \"0.0.0.0\"\n\tsqs-limits = strict\n}\n\nqueues {")
for x in $arr;
do
    INSIGHT+=$(echo -n "{\"key\":\"$QUEUE_ACCESS_KEY\",\"secretKey\":\"$QUEUE_SECRET_KEY\",\"region\":\"us-east-1\",\"url\":\"http://localhost:9324/queue/$x\",\"visibility\":0},")
    ELASTICMQ+=$(echo -e "\n\t$x {\n\t\tdefaultVisibilityTimeout = 10 seconds\n\t\tdelay = 5 seconds\n\t\treceiveMessageWait = 0 seconds\n\t},\n")
done

echo "${INSIGHT}" > /opt/sqs-insight.conf
printf '%s\n' '$' 's/.$/]}/' wq | ex /opt/sqs-insight.conf

echo "${ELASTICMQ}" > /opt/elasticmq.conf
printf '%s\n' '$' 's/.$//' wq | ex /opt/elasticmq.conf
echo -e "}\n" >> /opt/elasticmq.conf

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

