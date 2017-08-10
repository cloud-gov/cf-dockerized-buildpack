# CloudFoundry Buildpack as Docker image
This is an experiment to create a Docker container that approximates
the runtime environment of a cloud.gov/CloudFoundry droplet on the
[cflinuxfs2][] stack.

The Dockerfile is heavily inspired by [sclevine/cflocal][].

## Using in your application

### Dockerfile and docker-compose.yml
To use the image in your application, you will create a `Dockerfile`. This `Dockerfile` is used to build your final container image with the correct language, or buildpack, that your application is using.

Valid buildpacks at this time are one of:
**binary | go | java | nodejs | dotnet-core | php | python | ruby | staticfile**

So for a `python` project, your `Dockerfile` will look like:

```Dockerfile
FROM cloud-gov-registry.app.cloud.gov/python-buildpack
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

### Ignoring files
When you push your application to CloudFoundry, there are often times when you want to ignore certain files from that push operation. Examples might include files in `node_modules`, python virtual environment dependencies, and more. To ignore these files, you typically create a `.cfignore`, much like a `.gitignore`, and lots of times, they can be sym-linked so you can keep track of these files in one place. If this applies to your project, you will also want to create a `.dockerignore` so that these files are not making their way into your container.

### Starting the app
Once you have both your `Dockerfile` and `docker-compose.yml`, you can then
run the app:

```shell
docker-compose up --build
```

As your container builds, it goes through the [buildpackapplifecycle][] to properly build and launch your application.

### Deploying changes
When you make changes to your app, you simply stop the container, and bring it back up again.

```shell
docker-compose down
docker-compose up
```

If you make changes to your required dependencies (through `requirements.txt`, `package.json`, `Gemfile`, etc) then you will need to force another build of the container with `docker-compose up --build`.

### Replicating services
To replicate CloudFoundry services, you will add a new service and update your app service in your `docker-compose.yml` to include a link to the service, and adding the proper `VCAP_SERVICES` environment variable structure.

An example diff of what these additions might look like for replicating an AWS RDS service:
```diff
--- ./old/docker-compose.yml  2017-05-15 09:30:48.000000000 -0400
+++ ./new/docker-compose.yml  2017-05-31 16:32:39.000000000 -0400
@@ -8,6 +8,36 @@
       - node-modules:/home/vcap/app/node_modules
     build:
       context: .
+    environment:
+      VCAP_SERVICES: |-
+        {
+          "aws-rds": [
+            {
+              "name": "my-rds-instance",
+              "label": "aws-rds",
+              "plan": "docker",
+              "credentials": {
+                "db_name": "mydb",
+                "host": "postgres-docker",
+                "password": "mysecret",
+                "port": "5432",
+                "uri": "postgres://myuser:mysecret@postgres-docker:5432/mydb",
+                "username": "myuser"
+              }
+            }
+          ]
+        }
+    links:
+      - postgres-docker
+
+  postgres-docker:
+    image: library/postgres:9.6.3
+    ports:
+      - 5432:5432
+    environment:
+      POSTGRES_USER: myuser
+      POSTGRESS_PASSWORD: mysecret
+      POSTGRES_DB: mydb

 volumes:
   node-modules:
```

You can take a look at the [services example][] written in nodejs for better idea of how you might define and use services.

## Creating the base images

### Building images locally
Make sure you have [jq][] installed to run the build script.

To build an image for a particular buildpack, you provide the language
as a argument to the build script. For example, to build an image for `python`:

```shell
./build.sh python
```

This will build a base image that can be used by your own application
to replicate the build lifecycle when pushing an application.

### Using the automated pipeline
The pipeline will publish each buildpack image to a repository hosted on [cloud.gov][]

**NOTE** This requires using [concourse.ci][] using AWS instance profiles that allows Concourse to publish to an S3 bucket, a deployment of [CloudFoundry][], and an instance of the [credentials broker][]

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

[services example]: https://github.com/18F/cf-dockerized-buildpack/tree/master/examples/services-example
[jq]: https://stedolan.github.io/jq/
[cflinuxfs2]: https://github.com/cloudfoundry/stacks/tree/master/cflinuxfs2
[sclevine/cflocal]: https://github.com/sclevine/cflocal
[buildpackapplifecycle]: https://github.com/cloudfoundry/buildpackapplifecycle
[cfdocs]: https://docs.cloudfoundry.org/buildpacks/custom.html
[buildpacks]: https://docs.cloudfoundry.org/buildpacks/#system-buildpacks
[concourse.ci]: https://concourse.ci
[cloud.gov]: https://cloud.gov
[CloudFoundry]: https://github.com/cloudfoundry/cf-release
[credentials broker]: https://github.com/cloudfoundry-community/uaa-credentials-broker