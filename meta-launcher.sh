#! /bin/bash

set -e

# This just wraps whatever the Docker host wants to run in the
# Diego buildpack lifecycle launcher, which sets up some environment
# variables and makes buildpack binaries accessible to us.
#
# The Diego launcher only seems to like running a single command in a
# specific home directory, though, so we're going to store our
# execution parameters in environment variables and restore them
# after the Diego launcher does its job.

export ORIGINAL_ARGS=$@
export ORIGINAL_CWD=$(pwd)

exec /tmp/lifecycle/launcher /tmp/app /home/vcap/sub-launcher.sh staging_info.yml
