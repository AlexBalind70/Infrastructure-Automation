#!/bin/bash

echo "exporting variables from dotenv"

. .env

echo "writing keys..."

echo "${ANSIBLE_SSH_PRIVATE_KEY}" > ./src/keys/ssh-private-key
echo ${ANSIBLE_SSH_PUBLIC_KEY} > ./src/keys/ssh-public-key

cp src/hosts.example src/hosts

