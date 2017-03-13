#! /bin/bash

shopt -s nullglob
set -e

export CF_INSTANCE_INDEX=0
export CF_INSTANCE_ADDR=0.0.0.0:8080
export CF_INSTANCE_PORT=8080
export CF_INSTANCE_PORTS='[{"external":8080,"internal":8080}]'
export CF_INSTANCE_GUID=999db41a-508b-46eb-74d8-6f9c06c006da
export INSTANCE_GUID=999db41a-508b-46eb-74d8-6f9c06c006da
export INSTANCE_INDEX=0
export PORT=8080
export HOME=/home/vcap/app
export TMPDIR=/home/vcap/tmp
export VCAP_APPLICATION='{ \
"limits": {"fds": 16384, "mem": 512, "disk": 1024}, \
"application_name": "local", "name": "local", "space_name": "local-space", \
"application_uris": ["localhost"], "uris": ["localhost"], \
"application_id": "01d31c12-d066-495e-aca2-8d3403165360", \
"application_version": "2b860df9-a0a1-474c-b02f-5985f53ea0bb", \
"version": "2b860df9-a0a1-474c-b02f-5985f53ea0bb", \
"space_id": "18300c1c-1aa4-4ae7-81e6-ae59c6cdbaf1", \
"instance_id": "999db41a-508b-46eb-74d8-6f9c06c006da", \
"host": "0.0.0.0", "instance_index": 0, "port": 8080 \
}'

for script in $HOME/.profile.d/*
do
    # shellcheck source=/dev/null
    . $script
done
exec /tmp/lifecycle/launcher $HOME "$(jq -r .start_command /home/vcap/staging_info.yml)" ''
