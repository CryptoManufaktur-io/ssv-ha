# ssv-ha
Highly available SSV node deployment
=======

This is currently experimental

Architecture:
- SSV "stack" in docker swarm or k8s. This repo has been tested on docker swarm; k8s would require some adjustments, though likely nothing too drastic. One copy of each service runs; on a HA deployment with multiple managers and workers, ideally across multiple AZs, the failure of one node just means those ssv services get "spun up" on another node.
- Two or more execution clients - Geth or others that the node operator trusts. TLS-encrypted is assumed by haproxy in this example, I am using eth-docker for that.
- Two or more consensus clients - tested with Lighthouse and Teku, should work with Nimbus. TLS-encrypted is assumed by haproxy in this example, I am using eth-docker for that. Prysm would require changes because it doesn't do https://.
- Shared storage is a must. NFS works; or any other shared-storage idea for k8s.

Files in this repo.

- ssv.yml - the actual "stack", this would go into portainer or be deployed some other way. Adjust the domain names
for the LB in here, and your NFS mount or other shared storage.

The following files would live as "configs" in docker swarm or k8s and get referenced by the yml file that defines the stack

- prater-haproxy.cfg - the configuration file for haproxy
  - Adjust domain names in here, both for ACLs (what the rocketpool services connect to via the haproxy service) and backend (the servers things get load-balanced to)
  - Note: The server name has to be the FQDN of the server for HTTPS not WSS, the external check script relies on it. It otherwise gets an IP address, which won't work with how eth-docker does TLS via traefik.
    So if your server is available as `goerli-ec-a.example.com` for HTTPS and `goerli-ecws-a.example.com` for WSS, then the two lines for it would respectively read
    `server goerli-ec-a.example.com goerli-ec-a.example.com:443 check` for HTTPS and `server goerli-ec-a.example.com goerli-ecws-a.example.com:443 check` for WSS. The first part is the server name,
    which is arbitrary as far as haproxy is concerned, and the check script uses that to make some RPC calls; the second part is the server address, the location that haproxy will send actual traffic to.

- check-ccsync.sh - external check script for haproxy that verifies that the consensus client is synced and has at least N peers

- check-ecsync.sh - external check script for haproxy that verifies that the execution client is synced and has at least N peers

- ssv.yml - Example of an SSV config file

Preparing the shared storage

- Have an NFS mount, create dir ssv-db

MIT Licensed
