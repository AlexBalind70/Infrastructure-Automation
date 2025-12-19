#!/bin/bash

echo "exporting variables from dotenv"

. .env

echo "writing keys..."

echo "${ANSIBLE_SSH_PRIVATE_KEY}" > ./src/keys/ssh-private-key
echo ${ANSIBLE_SSH_PUBLIC_KEY} > ./src/keys/ssh-public-key

cp src/hosts.example src/hosts

# For Nginx
cp src/ansible-master-proxy/nginx/conf.d/master-proxy.conf.example src/ansible-master-proxy/nginx/conf.d/master-proxy.conf
cp src/ansible-master-proxy/nginx/stream.d/base-stream.conf.example src/ansible-master-proxy/nginx/stream.d/base-stream.conf
cp src/ansible-master-proxy/nginx/nginx.conf.example src/ansible-master-proxy/nginx/nginx.conf

# For SSH Configuration
cp src\ansible-ssh-configuration\ssh\fail2ban\jail.d\ssh.conf.example src\ansible-ssh-configuration\ssh\fail2ban\jail.d\ssh.conf
cp src\ansible-ssh-configuration\ssh\fail2ban\telegram-ban.conf.example src\ansible-ssh-configuration\ssh\fail2ban\telegram-ban.conf
cp src\ansible-ssh-configuration\ssh\ssh-notify.sh.example src\ansible-ssh-configuration\ssh\ssh-notify.sh
cp src\ansible-ssh-configuration\ssh\sshd_config.example src\ansible-ssh-configuration\ssh\sshd_config
