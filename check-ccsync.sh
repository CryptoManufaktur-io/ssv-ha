#!/bin/sh
MIN_PEERS=10
SYNC=$(curl -s -m2 -N "https://${HAPROXY_SERVER_NAME}/eth/v1/node/syncing")
echo "${SYNC}" | grep -q "data"
if [ $? -ne 0 ]; then
  exit 1
fi
SYNCING=$(echo "${SYNC}" | jq .data.is_syncing)
OPTIMISTIC=$(echo "${SYNC}" | jq .data.is_optimistic)
EL_OFFLINE=$(echo "${SYNC}" | jq .data.el_offline)
PEERS=$(curl -s -m2 -N "https://${HAPROXY_SERVER_NAME}/eth/v1/node/peer_count")
echo "${PEERS}" | grep -q "data"
if [ $? -ne 0 ]; then
  exit 1
fi
PEERS=$(echo "${PEERS}" | jq -r .data.connected)
if [ "${SYNCING}" = "false" -a "${OPTIMISTIC}" = "false" -a "${EL_OFFLINE}" = "false" -a "${PEERS}" -ge "$MIN_PEERS" ]; then
  return 0
else
  return 1
fi
