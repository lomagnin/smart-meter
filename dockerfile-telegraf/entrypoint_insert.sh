#!/bin/bash

if [[ -n "$TELEGRAF_DEBUG" && $TELEGRAF_DEBUG = "true" ]]; then env; fi

NATS_USERNAME=`cat ${NATS_USERNAME_FILE}`
NATS_PASSWORD=`cat ${NATS_PASSWORD_FILE}`
export NATS_URI="nats://${NATS_USERNAME}:${NATS_PASSWORD}@nats:4222"

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi