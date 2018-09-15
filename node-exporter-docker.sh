#!/bin/bash

echo -e "\e[31;43m***** Checking docker installation *****\e[0m"

which docker

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version"
    if [ $? -eq 0 ]
    then
        main
    else
        echo "You must install Docker before running this script."
    fi
else
    echo "You must install Docker before running this script." >&2
fi

main() {
    docker run -d -p 9100:9100 --name=node-ex --restart=always prom/node-exporter
    if [ $? -eq 0 ]
    then
        echo "Successfully deployed node-exporter package"

        # Nginx proxy
        echo "Do you wish to create a Nginx reverse proxy?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) nginx ; break;;
                No ) exit;;
            esac
        done
    else
        echo "You must install Docker before running this script."
    fi
    
}

nginx() {
    echo "Please provide a domain name (e.g. monit.example.com)"
    read $DOMAIN_NAME
    echo "Specify port number"
    read $PORT

    DIR="$(cd "$(dirname "$0")" && pwd)"
    $DIR/nginx-reverse-proxy.sh
}