FROM cloudfoundry/cflinuxfs2

ENV BUILDPACKS \
  http://github.com/cloudfoundry/python-buildpack

ENV \
  GO_VERSION=1.7 \
  DIEGO_VERSION=0.1482.0

RUN \
  curl -L "https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz

RUN \
  mkdir -p /tmp/compile && \
  git -C /tmp/compile clone --single-branch https://github.com/cloudfoundry/diego-release && \
  cd /tmp/compile/diego-release && \
  git checkout "v${DIEGO_VERSION}" && \
  git submodule update --init --recursive \
    src/code.cloudfoundry.org/archiver \
    src/code.cloudfoundry.org/buildpackapplifecycle \
    src/code.cloudfoundry.org/bytefmt \
    src/code.cloudfoundry.org/cacheddownloader \
    src/github.com/cloudfoundry-incubator/candiedyaml \
    src/github.com/cloudfoundry/systemcerts

RUN \
  export PATH=/usr/local/go/bin:$PATH && \
  export GOPATH=/tmp/compile/diego-release && \
  go build -o /tmp/lifecycle/launcher code.cloudfoundry.org/buildpackapplifecycle/launcher && \
  go build -o /tmp/lifecycle/builder code.cloudfoundry.org/buildpackapplifecycle/builder

ENV \
  CF_INSTANCE_ADDR= \
  CF_INSTANCE_PORT= \
  CF_INSTANCE_PORTS=[] \
  CF_INSTANCE_IP=0.0.0.0 \
  CF_STACK=cflinuxfs2 \
  HOME=/home/vcap \
  MEMORY_LIMIT=512m \
  VCAP_SERVICES={}

ENV VCAP_APPLICATION '{ \
    "limits": {"fds": 16384, "mem": 512, "disk": 1024}, \
    "application_name": "local", "name": "local", "space_name": "local-space", \
    "application_uris": ["localhost"], "uris": ["localhost"], \
    "application_id": "01d31c12-d066-495e-aca2-8d3403165360", \
    "application_version": "2b860df9-a0a1-474c-b02f-5985f53ea0bb", \
    "version": "2b860df9-a0a1-474c-b02f-5985f53ea0bb", \
    "space_id": "18300c1c-1aa4-4ae7-81e6-ae59c6cdbaf1" \
  }'

USER vcap

ARG PYTHON_VERSION=3.6.0

RUN \
  mkdir -p /tmp/app && \
  echo ${PYTHON_VERSION} > /tmp/app/runtime.txt && \
  touch /tmp/app/requirements.txt && \
  mkdir -p /home/vcap/tmp && \
  cd /home/vcap && \
  /tmp/lifecycle/builder -buildpackOrder "$(echo "$BUILDPACKS" | tr -s ' ' ,)"

COPY staging_info.yml launcher-launcher.sh sub-launcher.sh /home/vcap/

ENTRYPOINT ["/home/vcap/launcher-launcher.sh"]
