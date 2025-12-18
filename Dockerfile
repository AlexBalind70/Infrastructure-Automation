FROM ubuntu:24.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        ansible \
        sshpass && \
    apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/ansible
COPY ./src .
RUN chmod 600 ./keys/ssh-private-key
