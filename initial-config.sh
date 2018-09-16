#!/bin/bash

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

hostname() {
    echo 
    read -p "Please provide a host name (e.g. example1)" HOST_NAME
    hostnamectl set-hostname $HOST_NAME
    echo "Set the hostname to $HOST_NAME"
}

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."

 DIR="$(cd "$(dirname "$0")" && pwd)"

read -p "Do you wish to run server maintenance y/n? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
   $DIR/server-maintenance.sh
else 
    echo 
    echo "Skipping updates"
    echo 
fi

read -p "Do you wish to set a new hostname y/n? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
   hostname
else 
    echo 
    echo "Skipping hostname"
    echo 
fi

read -p "Do you wish to install docker y/n? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    $DIR/install-docker.sh
else 
    echo 
    echo "Skipping Docker installation"
    echo 
fi


read -p "Do you wish to deploy a node exporter? (requires docker) y/n? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then

    echo "Please provide a port number (e.g. 9100)"
    read PORT

    $DIR/node-exporter-docker.sh $PORT
else 
    echo 
    echo "Skipping node-exporter"
    echo 
fi


read -p "Do you wish to run certbot y/n? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    apt-get install python-certbot-nginx
    certbot --nginx
    read -p "Do you wish to add a renew cronjob for certbot y/n? " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
    #write out current crontab
    crontab -l > mycron
    #echo new cron into cron file
    echo "@daily /usr/bin/certbot renew --preferred-challenges http" >> mycron
    #install new cron file
    crontab mycron
    rm mycron
    else 
        echo 
        echo "Skipping renew job"
        echo 
    fi
else 
    echo 
    echo "Skipping certbot"
    echo 
fi