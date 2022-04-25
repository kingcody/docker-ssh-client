#!/bin/sh

install -dm 0700 ~/.ssh

# Add ssh rsa private key
if [[ ! -z "$SSH_RSA_PRIVATE_KEY" ]]; then
  echo "$SSH_RSA_PRIVATE_KEY" | tr -d '\r' >> ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
fi

# Add ssh ecdsa private key
if [[ ! -z "$SSH_ECDSA_PRIVATE_KEY" ]]; then
  echo "$SSH_ECDSA_PRIVATE_KEY" | tr -d '\r' >> ~/.ssh/id_ecdsa
  chmod 600 ~/.ssh/id_ecdsa
fi

# Add known hosts from env
if [[ ! -z "$SSH_KNOWN_HOSTS" ]]; then
  echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
  chmod 644 ~/.ssh/known_hosts
fi

# Add known hosts with ssh-keyscan
if [[ ! -z "$SSH_KNOWN_HOSTS_SCAN" ]]; then
  OLDIFS=$IFS
  IFS=","
  for HOST_STR in $SSH_KNOWN_HOSTS_SCAN; do
    HOST=$(echo $HOST_STR | awk '{split($0,a,":"); print a[1]}')
    PORT=$(echo $HOST_STR | awk '{split($0,a,":"); print a[2]}')
    ssh-keyscan -p "${PORT:-22}" "$HOST" >> ~/.ssh/known_hosts 2> /dev/null
  done
  IFS=$OLDIFS
  chmod 644 ~/.ssh/known_hosts
fi

# Execute the container command
exec "$@"
