This is an experiment to create a Docker container that approximates
the runtime environment of a cloud.gov/CloudFoundry droplet
using a Python buildpack.

The Dockerfile is heavily inspired by [sclevine/cflocal][].

Other references:

* [buildpackapplifecycle][] - Source code for the Diego builder and
  launcher used for CloudFoundry deployment.

* [python-buildpack][] - Repository for CloudFoundry's Python buildpack.

* [CloudFoundry custom buildpack documentation][cfdocs]

[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[python-buildpack]: https://github.com/cloudfoundry/python-buildpack
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
