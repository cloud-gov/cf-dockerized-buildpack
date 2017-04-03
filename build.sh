#!/usr/bin/env bash

set -e

case "$1" in
    binary|go|java|nodejs|dotnet-core|php|python|ruby|staticfile)
        LANGUAGE=$1
        GO_VERSION="${GO_VERSION:-1.7}"
        DIEGO_VERSION=$(curl -s -L http://bosh.io/api/v1/releases/github.com/cloudfoundry/diego-release -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')
        BP_VERSION=$(curl -s -L http://bosh.io/api/v1/releases/github.com/cloudfoundry/${LANGUAGE}-buildpack-release -H "Content-type: application/json" -H "Accept: application/json" | jq -r '.[0] | .version')

        docker build . \
            --no-cache \
            --tag "${LANGUAGE}-buildpack:${BP_VERSION}" \
            --tag "${LANGUAGE}-buildpack:latest" \
            --build-arg GO_VERSION=${GO_VERSION} \
            --build-arg DIEGO_VERSION="v${DIEGO_VERSION}" \
            --build-arg LANGUAGE="${LANGUAGE}"
        echo "Built image using buildpack ${LANGUAGE}:${BP_VERSION}"
        ;;
    *)
        echo "Usage: ./build.sh LANGUAGE"
        echo
        echo "Must specify language. Please choose one of:"
        echo "  binary"
        echo "  go"
        echo "  java"
        echo "  nodejs"
        echo "  dotnet-core"
        echo "  php"
        echo "  python"
        echo "  ruby"
        echo "  staticfile"
        exit 1
esac
