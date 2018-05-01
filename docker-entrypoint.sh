#!/bin/sh

eval $(ssh-agent -s) > /dev/null

# Add ssh private key
if [[ ! -z "$SSH_PRIVATE_KEY" ]]; then
  echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - 2> /dev/null
fi

# Add known host
if [[ ! -z "$SSH_KNOWN_HOSTS" ]]; then
  install -dm 0700 ~/.ssh
  OLDIFS=$IFS
  IFS=","
  for HOST in $SSH_KNOWN_HOSTS; do
    ssh-keyscan "$HOST" >> ~/.ssh/known_hosts 2> /dev/null
  done
  IFS=$OLDIFS
  chmod 644 ~/.ssh/known_hosts
fi

# Execute the container command
exec "$@"
