#!/bin/sh

set -e
set -u

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# shellcheck disable=SC1091
. /opt/resource/common.sh

# install cf cli
mkdir -p tmp
PATH=$PWD/tmp:$PATH
curl -# -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx -C tmp
# get jq
apt-get update -qq && apt-get install -qqy jq

# start up docker
export PORT=2375
# /usr/local/bin/wrapdocker &
start_docker
# give docker a chance to start up
# sleep 5

BP_VERSION=$(curl -s -L "http://bosh.io/api/v1/releases/github.com/cloudfoundry/${LANGUAGE}-buildpack-release" -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')
(cd "${SCRIPTPATH}"/../ && ./build.sh "${LANGUAGE}")

cf login -a "$CF_API" -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -s "$CF_SPACE"
# shellcheck disable=SC1090
. "${SCRIPTPATH}"/export-service-keys.sh

docker run -d \
  --publish 5000:5000 \
  --restart always \
  --env REGISTRY_STORAGE="${REGISTRY_STORAGE}" \
  --env REGISTRY_STORAGE_S3_ACCESSKEY="${REGISTRY_STORAGE_S3_ACCESSKEY}" \
  --env REGISTRY_STORAGE_S3_SECRETKEY="${REGISTRY_STORAGE_S3_SECRETKEY}" \
  --env REGISTRY_STORAGE_S3_BUCKET="${REGISTRY_STORAGE_S3_BUCKET}" \
  --env REGISTRY_STORAGE_S3_REGION="${REGISTRY_STORAGE_S3_REGION}" \
  --name registry registry:2

docker tag "${LANGUAGE}-buildpack:${BP_VERSION}" localhost:5000/"${LANGUAGE}-buildpack:${BP_VERSION}"
docker tag "${LANGUAGE}-buildpack:latest" localhost:5000/"${LANGUAGE}-buildpack:latest"

docker push localhost:5000/"${LANGUAGE}-buildpack"

docker stop "$(docker ps -q)"

#kill -9 $(cat /var/run/docker.pid)