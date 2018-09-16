#!/bin/bash

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

[ $(id -g) != "0" ] && die "Script must be run as root."


apt-get remove docker docker-engine docker.io
apt-get update
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install docker-ce

docker run hello-world
ok "Installed Docker"