#!/bin/sh

set -e
set -u

DIEGO_VERSION=$(curl -s -L http://bosh.io/api/v1/releases/github.com/cloudfoundry/diego-release -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')
BP_VERSION=$(curl -s -L http://bosh.io/api/v1/releases/github.com/cloudfoundry/python-buildpack-release -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')

cat <<EOF > build/args.json
{
  "DIEGO_VERSION": "v${DIEGO_VERSION}",
  "LANGUAGE": "${LANGUAGE}",
  "GO_VERSION": "${GO_VERSION}"
}
EOF

echo "$BP_VERSION" > build/tag