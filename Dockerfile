FROM cloudfoundry/cflinuxfs2

ARG GO_VERSION
ARG DIEGO_VERSION
ARG LANGUAGE
ENV \
  GO_VERSION=${GO_VERSION:-1.7} \
  DIEGO_VERSION=${DIEGO_VERSION:-v1.10.0} \
  LANGUAGE=${LANGUAGE:-python} \
  BUILDPACK=http://github.com/cloudfoundry/${LANGUAGE}-buildpack

COPY \
  lifecycle-compile.sh \
  lifecycle-build.sh \
  meta-launcher.sh \
  /tmp/lifecycle/

RUN /tmp/lifecycle/lifecycle-compile.sh

ENV \
  CF_STACK=cflinuxfs2 \
  CF_INSTANCE_INDEX=0 \
  CF_INSTANCE_ADDR=0.0.0.0:8080 \
  CF_INSTANCE_PORT=8080 \
  CF_INSTANCE_PORTS='[{"external":8080,"internal":8080}]' \
  CF_INSTANCE_GUID=999db41a-508b-46eb-74d8-6f9c06c006da \
  INSTANCE_GUID=999db41a-508b-46eb-74d8-6f9c06c006da \
  INSTANCE_INDEX=0 \
  LANG=en_US.UTF-8 \
  PORT=8080 \
  HOME=/home/vcap/app \
  TMPDIR=/home/vcap/tmp \
  VCAP_APPLICATION='{ \
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

EXPOSE 8080

ONBUILD COPY . /tmp/app/
ONBUILD RUN chown -R vcap:vcap /tmp/app
ONBUILD USER vcap
ONBUILD RUN /tmp/lifecycle/lifecycle-build.sh
ONBUILD VOLUME \
    /home/vcap/app/.cloudfoundry \
    /home/vcap/app/.profile.d
ENTRYPOINT ["/tmp/lifecycle/meta-launcher.sh"]
