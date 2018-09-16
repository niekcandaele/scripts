#!/bin/bash

PORT=$1

main() {
    docker run -d -p $PORT:$PORT --name=node-ex --restart=always prom/node-exporter
    if [ $? -eq 0 ]
    then
        echo "Successfully deployed node-exporter package"

        # Nginx proxy
        echo "Do you wish to create a Nginx reverse proxy?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) nginx ; break;;
                No ) ok "Succes! node-exporter is running on port $PORT";;
            esac
        done
    else
        die "Error while creating container."
    fi
    
}

nginx() {
    echo "Please provide a domain name (e.g. monit.example.com)"
    read DOMAIN_NAME

    DIR="$(cd "$(dirname "$0")" && pwd)"
    $DIR/nginx-reverse-proxy.sh $DOMAIN_NAME $PORT

    if [ $? -eq 0 ]
    then
        ok "Succes! node-exporter should be available at $DOMAIN_NAME . If not, be sure to check firewall settings."
    else
        die "Error while creating reverse proxy"
    fi
     
}

ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "1" ] && die "Invalid usage: $(basename $0) port"

echo -e "\e[31;43m***** Checking docker installation *****\e[0m"

which docker

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version"
    if [ $? -eq 0 ]
    then
        main
    else
        die "You must install Docker before running this script."
    fi
else
    die "You must install Docker before running this script." >&2
fi

