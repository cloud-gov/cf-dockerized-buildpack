#!/bin/sh

set -e
set -u

SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

# install jq
apk --update --no-cache add jq && rm -rf /var/cache/apk/*

# shellcheck disable=SC1091
. /docker-lib.sh

# install cf cli
mkdir -p tmp
PATH=$PWD/tmp:$PATH
curl -k -# -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx -C tmp

# start up docker
start_docker "" "" ""

docker load -i cflinuxfs2-image/image
docker tag "$(cat cflinuxfs2-image/image-id)" "$(cat cflinuxfs2-image/repository):$(cat cflinuxfs2-image/tag)"
docker load -i registry-image/image
docker tag "$(cat registry-image/image-id)" "$(cat registry-image/repository):$(cat registry-image/tag)"

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