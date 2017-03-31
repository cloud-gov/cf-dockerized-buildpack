#!/bin/sh

set -e

DIEGO_VERSION=$(cat diego-release-src/version)

cat <<EOF > build/args.json
{
  "DIEGO_VERSION": "${DIEGO_VERSION}",
  "LANGUAGE": "${LANGUAGE}",
  "GO_VERSION": "${GO_VERSION}"
}
EOF