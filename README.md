This is an experiment to create a Docker container that approximates
the runtime environment of a cloud.gov/CloudFoundry droplet on the
[cflinuxfs2][] stack.

The Dockerfile is heavily inspired by [sclevine/cflocal][].

## Quick start
Make sure you have [jq][] installed to run the build script.

To build an image for a particular buildpack, you provide the language
as a argument to the build script. For example, to build an image for `python`:

```shell
./build.sh python
```

This will build a base image that can be used by your own application
to replicate the build lifecycle when pushing an application.

### Using in your application
To use the image in your application, you will create a `Dockerfile`. This `Dockerfile` is used to build your final container image with the correct language, or buildpack, that your application is using.  So for a python project, your `Dockerfile` will look like:

```Dockerfile
FROM cf-python-buildpack
```

You then will add a `docker-compose.yml`. This file exposes the proper port
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

## Using the automated pipeline
**NOTE** This requires using [concourse.ci][] and [cloud.gov][]

* Copy `credentials.example.yml` to `credentials.yml` and start filling in with the appropriate information.

* Create a deployer user in the org and space you want the registry to live:
```shell
cf create-service cloud-gov-service-account space-deployer registry-deployer
cf service registry-deployer
```

* Visit the given Dashboard URL to get the account credentials. Update the `credentials.yml`

* Fly the pipeline
```shell
fly -t <TARGET> set-pipeline -p dockerized-buildpacks -c pipeline.yml -l credentials.yml
```

## Other references

* [CloudFoundry custom buildpack documentation][cfdocs]

* [CloudFoundry system buildpacks][buildpacks]

[jq]: https://stedolan.github.io/jq/
[cflinuxfs2]: https://github.com/cloudfoundry/stacks/tree/master/cflinuxfs2
[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
[buildpacks]: https://docs.cloudfoundry.org/buildpacks/#system-buildpacks
[concourse.ci]: https://concourse.ci
[cloud.gov]: https://cloud.gov