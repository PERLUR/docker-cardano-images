#!/bin/bash

JORM_USER_HOME=$HOME
if [ -f ${JORM_USER_HOME}etc/genesis-hash.txt ]; then
  GENESIS_HASH_FILE=${JORM_USER_HOME}etc/genesis-hash.txt
  GENESIS_HASH=$(cat ${GENESIS_HASH_FILE})
fi
if [ -f ${JORM_USER_HOME}etc/node_config.json ]; then
  JORM_CONF_FILE=${JORM_USER_HOME}etc/node_config.json
  JORM_CONF_TYPE="json"
elif [ -f ${JORM_USER_HOME}etc/node_config.yaml ]; then
  JORM_CONF_FILE=${JORM_USER_HOME}etc/node_config.yaml
  JORM_CONF_TYPE="yaml"
fi
if [ -f ${JORM_USER_HOME}etc/secrets/node_secret.yaml ]; then
  JORM_SECRET_FILE=${JORM_USER_HOME}etc/secrets/node_secret.yaml
  JORM_NODE_TYPE="pool"
  JORM_POOL_ID=$(grep 'node_id' ${JORM_SECRET_FILE} | awk '{print $2}')
else
  JORM_NODE_TYPE="relay"
fi
: ${JORM_MAX_STARTUP_MIN:=${JORM_MAX_STARTUP_MIN:-20}}
: ${JORM_REST_API_PROTOCOL:=${JORM_REST_API_PROTOCOL:-http}}
: ${JORM_REST_API_ADDRESS:=${JORM_REST_API_ADDRESS:-localhost}}
: ${JORM_REST_API_PORT:=${JORM_REST_API_PORT:-3100}}
: ${JORM_REST_API_ENDPOINT:=${JORM_REST_API_ENDPOINT:-api}}
if [ -z ${JORM_REST_API_URI+x} ]; then
  JORM_REST_API_URI=${JORM_REST_API_PROTOCOL}://${JORM_REST_API_ADDRESS}:${JORM_REST_API_PORT}/${JORM_REST_API_ENDPOINT}
fi
export JORMUNGANDR_RESTAPI_URL=${JORM_REST_API_URI}
