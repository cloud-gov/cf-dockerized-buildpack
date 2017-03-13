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

EXPOSE 8080

ONBUILD COPY . /tmp/app/
ONBUILD RUN chown -R vcap:vcap /tmp/app
ONBUILD USER vcap
ONBUILD RUN /tmp/lifecycle/lifecycle-build.sh

ENTRYPOINT ["/tmp/lifecycle/meta-launcher.sh"]
