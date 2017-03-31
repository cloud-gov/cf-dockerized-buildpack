#!/bin/sh

set -e
set -u

DIEGO_VERSION=$(curl -s -L https://api.github.com/repos/cloudfoundry/diego-release/releases/latest | jq -r .tag_name)
BP_VERSION=$(curl -s -L "https://api.github.com/repos/cloudfoundry/${LANGUAGE}-buildpack/releases/latest" | jq -r .tag_name)

cat <<EOF > build/args.json
{
  "DIEGO_VERSION": "${DIEGO_VERSION}",
  "LANGUAGE": "${LANGUAGE}",
  "GO_VERSION": "${GO_VERSION}"
}
EOF

echo "$BP_VERSION" > build/tag