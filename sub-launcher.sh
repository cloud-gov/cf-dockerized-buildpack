#! /bin/bash

set -e

# For details on what these environment variables contain, see
# launcher-launcher.sh.

cd $ORIGINAL_CWD

exec $ORIGINAL_ARGS
