# Copyright 2017 Ronald E. Oribio R.
#
# This file is part of alpine-sqs which is released under the GPLv3.
# See https://github.com/roribio/alpine-sqs for details.
ARG ARCH

FROM alpine:3.13 as builder

WORKDIR /tmp/sqs-alpine

RUN \
  apk add --no-cache \
    curl \
    git \
    jq \
  && git clone --verbose --depth=1 https://github.com/kobim/sqs-insight.git \
  && export elasticmq_version=$(curl -sL https://api.github.com/repos/adamw/elasticmq/releases/latest | jq -r .tag_name) \
  && elasticmq_version=${elasticmq_version//v} \
  && curl -sLO https://s3-eu-west-1.amazonaws.com/softwaremill-public/elasticmq-server-${elasticmq_version}.jar \
  && mv elasticmq-server-${elasticmq_version}.jar elasticmq-server.jar

FROM ${ARCH}/openjdk:8-alpine

LABEL maintainer="Ronald E. Oribio R. https://github.com/roribio"

COPY --from=builder /tmp/sqs-alpine/ /opt/
COPY etc/ /etc/
COPY opt/ /opt/

RUN \
  apk add --no-cache \
    nodejs \
    nodejs-npm \
    supervisor \
    libtasn1=4.14-r0 \
  && rm -rf /etc/supervisord.conf \
  && ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf \
  && cd /opt/sqs-insight \
  && npm install

EXPOSE 9324 9325 9326

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
