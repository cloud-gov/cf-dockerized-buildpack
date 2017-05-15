#!/bin/bash
set -e
set -u
set -x

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# shellcheck disable=SC1091
. /opt/resource/common.sh

mkdir -p /usr/local/bin
curl -sL "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# start up docker
export PORT=2375
# /usr/local/bin/wrapdocker &
start_docker
# give docker a chance to start up
# sleep 5

cd "$SCRIPTPATH/.." || exit
python manage_examples.py test "$LANGUAGE"

#kill -9 $(cat /var/run/docker.pid)