[![Docker Repository on Quay](https://quay.io/repository/chiefy/alpine-nodejs-builder/status "Docker Repository on Quay")](https://quay.io/repository/chiefy/alpine-nodejs-builder)

# alpine-nodejs-builder
Build lightweight docker images of your nodejs application, inspired by [golang-builder](https://github.com/CenturyLinkLabs/golang-builder)

## What is this?
This project was heavily inspired by the [golang-builder](https://github.com/CenturyLinkLabs/golang-builder) which uses a docker image to build a go project and copy the binary to a new `"FROM scratch"` docker image. This produces a super-slim docker image.

The difference here is that node applications are not compiled and need the node binary to run. The node binary is compiled with `--fully-static` in the builder docker image and copied into a new docker image along with your application.

## Why would I want to use this?
With docker, it is beneficial to keep a small footprint for your image. Basing your image on a trusted name like Ubuntu, CentOS, Fedora etc. is nice, but often these images include unnecessary packages and files.

Pulling images from repositories is not exactly cheap and/or fast, and when deploying or scheduling containers to run, it can reduce deployment time and developer frustration (why is this taking so long?).

## Should I be using this for important (prod) stuff?
No! At this point this is an experiment to see just how slim I can make a node-based docker image. There are likely issues when compiling native modules in certain situations.

## Quickstart / TL;DR
```bash
$ docker run \
  --rm \
  -v /path/to/node/app:/src \
  -v /var/run/docker.sock:/var/run/docker.sock \
  quay.io/chiefy/alpine-nodejs-builder:4.2.1 \
  my_node_app:latest
```

## Usage

### Building an image from your application

#### Your `Dockerfile`
You need to include a `Dockerfile` in your project root which will get built and tagged. The file should look something like the following:
```Dockerfile
# Dog, look, our docker image is FROM scratch! Wheeeee!
FROM scratch
# Add your application to the root, don't change this
ADD . /
# Set / as the working directory for commands, don't change this
WORKDIR /
# Expose whatever ports you need to here
EXPOSE 3000
# The node binary is copied to the root, and serves as an entrypoint
ENTRYPOINT ["/node"]
# The command to start your application
CMD ["index.js"]
```

#### Mounting the docker sock
In order to create a new docker image, you must volume-mount the docker sock as such:
```
$ docker run \
  --rm \
  -v /var/run/docker.sock:/var/run/docker/sock \
  quay.io/chiefy/alpine-nodejs-builder:4.2.1
```

#### Mounting your source application
Volume mount the root of your application which contains your `package.json` file:
```
$ docker run \
  --rm \
  -v /path/to/my/project:/src \
  quay.io/chiefy/alpine-nodejs-builder:4.2.1
```

#### Options
Options are set by using environment variables.

  * `EXTRA_PKGS` - if your application requires extra packages for `npm install`, include them here, space separated. You will find a list of available packages at the [Alpine website](https://pkgs.alpinelinux.org/packages).
  * `NODE_ENV` - set to `prod` or `production` to enable the `--production` flag with `npm install`

Example:
```bash
$ docker run \
  --rm \
  -v /path/to/my/app:/src \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e "EXTRA_PKGS=krb5-dev" \
  -e "NODE_ENV=dev" \
  quay.io/chiefy/alpine-nodejs-builder:4.2.1 \
  my_app:latest
```

## Why am I getting `npm install` errors?
During `npm install` your node dependencies may need to use `node-gyp` to compile any native extensions. If the compiler needs certain headers or libraries, you may need to add them (see the [`EXTRA_PKGS`](#options) option below).


### Building the builder image

You will need:
  * Docker / docker-machine
  * Make

To build different versions of node, you will need to change the `NODE_VERSION` in `Makefile`.
```
$ make build
```
If you have caching issues, try `make force_build`


### Tests
Not exactly sure the best way to test this yet, so far I am just using a simple express app.
```
$ make test
```
