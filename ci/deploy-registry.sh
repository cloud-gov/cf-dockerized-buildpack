#!/bin/sh

set -e
set -u

cf login -a "$CF_API" -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -s "$CF_SPACE"
cf create-service s3 basic "${APP_NAME}-s3"
cf create-service-key "${APP_NAME}-s3" "${APP_NAME}-auth"

AUTH_PAYLOAD=$(cf service-key "${APP_NAME}-s3" "${APP_NAME}-auth" | awk 'FNR > 1 { print }')

cf push "${APP_NAME}" -o library/registry:2
cf set-env "${APP_NAME}" REGISTRY_STORAGE "s3"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_ACCESSKEY "$(echo ${AUTH_PAYLOAD} | jq -r .access_key_id)"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_SECRETKEY "$(echo ${AUTH_PAYLOAD} | jq -r .secret_access_key)"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_BUCKET "$(echo ${AUTH_PAYLOAD} | jq -r .bucket)"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_REGION "$(echo ${AUTH_PAYLOAD} | jq -r .region)"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_MAINTENANCE_READONLY "enabled: true"
cf restage "${APP_NAME}"
