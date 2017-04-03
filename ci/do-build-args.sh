#!/bin/sh

set -e
set -u

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

# get jq
apt-get update -qq && apt-get install -qqy jq

BP_VERSION=$(curl -s -L http://bosh.io/api/v1/releases/github.com/cloudfoundry/${LANGUAGE}-buildpack-release -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')

(cd "${SCRIPTPATH}"/../ && ./build.sh "${LANGUAGE}")

docker run -d \
  --publish 5000:5000 \
  --restart always \
  --env-file registry-auth-s3/jobstorage/registry-service-auth \
  --name registry registry:2

docker tag "${LANGUAGE}-buildpack:${BP_VERSION}" localhost:5000/"${LANGUAGE}-buildpack:${BP_VERSION}"
docker tag "${LANGUAGE}-buildpack:latest" localhost:5000/"${LANGUAGE}-buildpack:latest"

docker push localhost:5000/"${LANGUAGE}-buildpack"
