This is an experiment to create a Docker container that approximates
the runtime environment of a cloud.gov/CloudFoundry droplet on the
[cflinuxfs2][] stack.

The Dockerfile is heavily inspired by [sclevine/cflocal][].

## Quick start
To build an image for a particular buildpack, you provide  the language
as a argument to the build script. For example, to build an image for `python`:

```shell
./build.sh python
```

This will build a base image that can be used by your own application
to replicate the build lifecycle when pushing an application.

### Using in your application
Once you have
built this image, you can then add a Dockerfile to your own application
that looks like:

```Dockerfile
FROM cloud-gov/python
```

You can then add a `docker-compose.yml` to setup ports to be exposed to your
local system:

```yaml
version: '2'
services:
  app:
    ports:
      - 8080:8080
    build:
      context: .
```

Once you have both your `Dockerfile` and `docker-compose.yml`, you can then
run the app:

```shell
docker-compose up --build
```

As your container builds, it goes through the [buildpackapplifecycle][] to properly build and launch your application.

## Other references

* [CloudFoundry custom buildpack documentation][cfdocs]

* [CloudFoundry system buildpacks][buildpacks]

[cflinuxfs2]: https://github.com/cloudfoundry/stacks/tree/master/cflinuxfs2
[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
[buildpacks]: https://docs.cloudfoundry.org/buildpacks/#system-buildpacks
