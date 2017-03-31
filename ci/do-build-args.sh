#!/bin/sh

set -e
set -u

BASE_URL="http://bosh.io/api/v1/releases/github.com/cloudfoundry"
HEADERS='-H "Content-type: application/json" -H "Accept: application/json"'
DIEGO_VERSION=$(curl -s -L "${BASE_URL}/diego-release" ${HEADERS} | jq -r '.[0] | .version')
BP_VERSION=$(curl -s -L "${BASE_URL}/${LANGUAGE}-buildpack-release" ${HEADERS} | jq -r '.[0] | .version')

cat <<EOF > build/args.json
{
  "DIEGO_VERSION": "v${DIEGO_VERSION}",
  "LANGUAGE": "${LANGUAGE}",
  "GO_VERSION": "${GO_VERSION:-1.7}"
}
EOF

echo "$BP_VERSION" > build/tag