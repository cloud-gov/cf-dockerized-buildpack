#! /bin/bash

set -e

export ORIGINAL_ARGS=$@
export ORIGINAL_CWD=$(pwd)

exec /tmp/lifecycle/launcher /tmp/app /home/vcap/sub-launcher.sh staging_info.yml
