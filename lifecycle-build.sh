#!/bin/bash

mkdir -p /home/vcap/tmp

export CF_STACK=cflinuxfs2

cd /home/vcap || exit
/tmp/lifecycle/builder -skipDetect -buildpackOrder "${BUILDPACK}"
tar -C /home/vcap -zxf /tmp/droplet
chown -R vcap:vcap /home/vcap
