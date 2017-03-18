#!/bin/bash

rm -f /home/vcap/app/.cloudfoundry/.placeholder
rm -f /home/vcap/app/.profile.d/.placeholder
cd /home/vcap || exit
/tmp/lifecycle/builder -skipDetect -buildpackOrder "${BUILDPACK}"
tar -C /home/vcap -zxf /tmp/droplet
