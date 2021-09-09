#!/bin/sh
MIN_PEERS=10
SYNC=$(curl -s -m2 -N "https://${HAPROXY_SERVER_NAME}/eth/v1/node/syncing")
echo "${SYNC}" | grep -q "data"
if [ $? -ne 0 ]; then
  exit 1
fi
SYNC=$(echo "${SYNC}" | jq .data.is_syncing)
PEERS=$(curl -s -m2 -N "https://${HAPROXY_SERVER_NAME}/eth/v1/node/peer_count")
echo "${PEERS}" | grep -q "data"
if [ $? -ne 0 ]; then
  exit 1
fi
PEERS=$(echo "${PEERS}" | jq -r .data.connected)
if [ "${SYNC}" = "false" -a "${PEERS}" -ge "$MIN_PEERS" ]; then
  return 0
else
  return 1
fi

