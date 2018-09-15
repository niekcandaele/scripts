#!/usr/bin/env bash
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
USER='root'
NGINX_SCHEME='$scheme'
NGINX_REQUEST_URI='$request_uri'

DOMAIN_NAME=$1
PORT=$2

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "2" ] && die "Usage: $(basename $0) domainName port"

echo "Creating a reverse proxy for domain $DOMAIN_NAME and port $PORT"

cat > $NGINX_AVAILABLE_VHOSTS/$DOMAIN_NAME <<EOF
# www to non-www
server {
    # If user goes to www direct them to non www
    server_name *.$DOMAIN_NAME;
    return 301 $NGINX_SCHEME://$DOMAIN_NAME$NGINX_REQUEST_URI;
}
server {
    # Just the server name
    server_name $DOMAIN_NAME;
    #root        /var/www/$DOMAIN_NAME/public_html;

    # Logs
    access_log $WEB_DIR/$DOMAIN_NAME/logs/access.log;
    error_log  $WEB_DIR/$DOMAIN_NAME/logs/error.log;

    listen 80;
    listen [::]:80;

    location / {
    proxy_pass http://localhost:$PORT/;
  }

}
EOF

# Creating log directory
mkdir -p $WEB_DIR/$1/logs

# Enable site by creating symbolic link
ln -s $NGINX_AVAILABLE_VHOSTS/$DOMAIN_NAME $NGINX_ENABLED_VHOSTS/$DOMAIN_NAME

# Restart
echo "Do you wish to restart nginx?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) /etc/init.d/nginx restart ; break;;
        No ) exit;;
    esac
done

ok "Site Created for $DOMAIN_NAME"