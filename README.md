This is an experiment to create a Docker container that approximates
the runtime environment of a cloud.gov/CloudFoundry droplet
using a Python buildpack.

The Dockerfile is heavily inspired by [sclevine/cflocal][].

## Quick start

```
docker-compose build
docker-compose run app python
```

## Changing the Python version

To change the version of Python being used, you can change the
`PYTHON_VERSION` argument in `docker-compose.yml`. It needs
to be a valid Python version supported by
[CloudFoundry's Python buildpack][python-buildpack].

## Other references

* [buildpackapplifecycle][] - Source code for the Diego builder and
  launcher used for CloudFoundry deployment.

* [CloudFoundry custom buildpack documentation][cfdocs]

[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[python-buildpack]: https://github.com/cloudfoundry/python-buildpack
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
