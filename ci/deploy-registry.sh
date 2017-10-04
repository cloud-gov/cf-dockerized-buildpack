#!/bin/sh

set -e
set -u

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

cf login -a "$CF_API" -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -s "$CF_SPACE"
cf create-service s3 basic "${APP_NAME}-s3"
cf create-service-key "${APP_NAME}-s3" "${APP_NAME}-auth"

. "${SCRIPTPATH}"/export-service-keys.sh

cf push "${APP_NAME}" -o library/registry:2 --no-start
cf set-env "${APP_NAME}" REGISTRY_STORAGE "${REGISTRY_STORAGE}"
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_ACCESSKEY "${REGISTRY_STORAGE_S3_ACCESSKEY}" > /dev/null 2>&1
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_SECRETKEY "${REGISTRY_STORAGE_S3_SECRETKEY}" > /dev/null 2>&1
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_BUCKET "${REGISTRY_STORAGE_S3_BUCKET}" > /dev/null 2>&1
cf set-env "${APP_NAME}" REGISTRY_STORAGE_S3_REGION "${REGISTRY_STORAGE_S3_REGION}" > /dev/null 2>&1
cf set-env "${APP_NAME}" REGISTRY_STORAGE_MAINTENANCE_READONLY "enabled: true"
cf start "${APP_NAME}"
