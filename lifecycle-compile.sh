#!/usr/bin/env bash

set -e

mkdir -p /tmp/compile
mkdir -p /home/vcap/tmp
mkdir -p /home/vcap/app/.cloudfoundry
mkdir -p /home/vcap/app/.profile.d
touch /home/vcap/app/.cloudfoundry/.placeholder
touch /home/vcap/app/.profile.d/.placeholder
chown -R vcap:vcap /home/vcap

curl -# -L "https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /tmp/compile -xz
git -C /tmp/compile clone --single-branch https://github.com/cloudfoundry/diego-release
cd /tmp/compile/diego-release || exit
git checkout "${DIEGO_VERSION}"

export GOPATH=/tmp/compile/diego-release
export GOBIN=/tmp/lifecycle
export GOROOT=/tmp/compile/go
export PATH=/tmp/compile/go/bin:$PATH

git submodule update --init --recursive \
  src/code.cloudfoundry.org/archiver \
  src/code.cloudfoundry.org/buildpackapplifecycle \
  src/code.cloudfoundry.org/bytefmt \
  src/code.cloudfoundry.org/cacheddownloader \
  src/code.cloudfoundry.org/lager \
  src/github.com/cloudfoundry-incubator/candiedyaml \
  src/github.com/cloudfoundry/systemcerts

go build -o /tmp/lifecycle/builder code.cloudfoundry.org/buildpackapplifecycle/builder
go build -o /tmp/lifecycle/launcher code.cloudfoundry.org/buildpackapplifecycle/launcher

rm -rf /tmp/compile
