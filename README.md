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

You can then add a `docker-compose.yml`. This file exposes the proper port
to your local system, and also maps your application to the proper location
inside the container for easy changes.

```yaml
version: '2'
services:
  app:
    ports:
      - 8080:8080
    volumes:
      - .:/home/vcap/app
    build:
      context: .
```

Once you have both your `Dockerfile` and `docker-compose.yml`, you can then
run the app:

```shell
docker-compose up --build
```

As your container builds, it goes through the [buildpackapplifecycle][] to properly build and launch your application.

#### Deploying changes
When you make changes to your app, you simply stop the container, and bring it back up again.

```shell
docker-compose down
docker-compose up
```

If you make changes to your required dependencies (through requirements.txt, package.json, Gemfile, etc) then you will need to force another build of the container with `docker-compose up --build`.

## Other references

* [CloudFoundry custom buildpack documentation][cfdocs]

* [CloudFoundry system buildpacks][buildpacks]

[cflinuxfs2]: https://github.com/cloudfoundry/stacks/tree/master/cflinuxfs2
[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
[buildpacks]: https://docs.cloudfoundry.org/buildpacks/#system-buildpacks
