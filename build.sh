#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "Useage: ./build.sh LANGUAGE"
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
    exit;
fi

if ! [ -x "$(command -v yaml2json)" ]; then
    go get github.com/bronze1man/yaml2json
fi

LANGUAGE=$1
GO_VERSION="1.7"
DIEGO_VERSION=$(curl -s -L https://api.github.com/repos/cloudfoundry/diego-release/releases/latest | jq -r .tag_name)
BP_VERSION=$(curl -s -L https://api.github.com/repos/cloudfoundry/${LANGUAGE}-buildpack/releases/latest | jq -r .tag_name)

docker build . \
    --tag cloud-gov/${LANGUAGE}:${BP_VERSION} \
    --tag cloud-gov/${LANGUAGE}:latest \
    --build-arg GO_VERSION=${GO_VERSION} \
    --build-arg DIEGO_VERSION=${DIEGO_VERSION} \
    --build-arg LANGUAGE=${LANGUAGE}
