#!/usr/bin/env bash

set -e
exec /tmp/lifecycle/launcher "$HOME" "$(jq -r .start_command /home/vcap/staging_info.yml)" ''
