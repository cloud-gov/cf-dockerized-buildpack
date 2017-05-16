#!/bin/bash
set -e
set -u
set -x

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# shellcheck disable=SC1091
. /opt/resource/common.sh

# wget static compiled CURL
wget -O curl.tar.gz http://s3-us-gov-west-1.amazonaws.com/cg-public/curl.tar.gz
tar zxvf curl.tar.gz
mv curl /usr/local/bin
mkdir -p /usr/share/ssl/certs
rm -rf /usr/share/ssl/certs/ca-bundle.crt
cat /usr/share/ca-certificates/mozilla/* >> /usr/share/ssl/certs/ca-bundle.crt

mkdir -p /usr/local/bin
curl -sL "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# start up docker
export PORT=2375
start_docker "" ""

cd "$SCRIPTPATH/.." || exit
python manage_examples.py test "$LANGUAGE"