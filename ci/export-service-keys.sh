#!/bin/sh

set -e

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

cf service-key "${APP_NAME}-s3" "${APP_NAME}-auth" | awk 'FNR > 1 { print }' > "${SCRIPTPATH}"/auth.json

export REGISTRY_STORAGE=s3
export REGISTRY_STORAGE_S3_ACCESSKEY="$(jq -r .access_key_id < ${SCRIPTPATH}/auth.json)"
export REGISTRY_STORAGE_S3_SECRETKEY="$(jq -r .secret_access_key < ${SCRIPTPATH}/auth.json)"
export REGISTRY_STORAGE_S3_BUCKET="$(jq -r .bucket < ${SCRIPTPATH}/auth.json)"
export REGISTRY_STORAGE_S3_REGION="$(jq -r .region < ${SCRIPTPATH}/auth.json)"
