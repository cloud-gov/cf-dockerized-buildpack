#!/bin/sh
set -e
set -u

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
MAX_ATTEMPTS=10
INTERVAL_SECONDS=6

# install jq
apk --update --no-cache add jq && rm -rf /var/cache/apk/*

# shellcheck disable=SC1091
. /docker-lib.sh

# start up docker
start_docker "" "" ""

cd "$SCRIPTPATH/../examples/$LANGUAGE" || exit
docker-compose build
( docker-compose up & )

ATTEMPTS=1
while true; do
  echo "Checking if $LANGUAGE server works... "
  if curl -sL http://127.0.0.1:8080/ | grep -i 'hello world' > /dev/null 2>&1; then
    echo "[YES]"
    break
  else
    echo "...retrying"
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ $ATTEMPTS -gt $MAX_ATTEMPTS ]; then
    echo "Failed after $MAX_ATTEMPTS attempts"
    exit 1
  fi
  sleep $INTERVAL_SECONDS
done

docker-compose down -v
