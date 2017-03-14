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
ONBUILD VOLUME /home/vcap/app/.cloudfoundry
ONBUILD VOLUME /home/vcap/app/.profile.d
ONBUILD VOLUME /home/vcap/app
ONBUILD RUN /tmp/lifecycle/lifecycle-build.sh
ONBUILD RUN chown -R vcap:vcap /home/vcap
ONBUILD USER vcap
ENTRYPOINT ["/tmp/lifecycle/meta-launcher.sh"]
