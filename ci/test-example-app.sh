#!/bin/bash
set -e
set -u

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
MAX_ATTEMPTS=10
INTERVAL_SECONDS=5

# shellcheck disable=SC1091
. /opt/resource/common.sh

# wget static compiled CURL
wget -O curl.tar.gz http://s3-us-gov-west-1.amazonaws.com/cg-public/curl.tar.gz
tar zxvf curl.tar.gz
mv curl /usr/local/bin
mkdir -p /usr/share/ssl/certs
rm -rf /usr/share/ssl/certs/ca-bundle.crt
cat /usr/share/ca-certificates/mozilla/* >> /usr/share/ssl/certs/ca-bundle.crt

curl -sL --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# start up docker
export PORT=2375
start_docker "" ""

docker load -i docker-compose-image/image

cd "$SCRIPTPATH/../examples/$LANGUAGE" || exit
docker-compose build
( docker-compose up & )

ATTEMPTS=1
while true; do
  echo -n "Checking if $LANGUAGE server works... "
  if curl -sL http://127.0.0.1:8080/ | grep -i 'hello world' > /dev/null 2>&1; then
    echo "[YES]"
    break
  else
    echo "[retrying]"
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ $ATTEMPTS -gt $MAX_ATTEMPTS ]; then
    echo "Failed after $MAX_ATTEMPTS attempts"
    exit 1
  fi
  sleep $INTERVAL_SECONDS
done

docker-compose down -v
