#!/bin/bash -e

image_name=${1:?"Enter a name for your docker image"}
image_version=${2:-"latest"}

source=/src
build=/build
package=/src/package.json

env=${NODE_ENV:-"prod"}

if [[ ! -f "$package" ]]; then
	echo "Could not find package.json, please check your volume mounts and re-try"
	exit 1
fi

if [[ ! -z "$EXTRA_PKGS" ]]; then
	apk update
	apk add $EXTRA_PKGS
fi

cp -R $source/* $build
rm -rf $build/node_modules

if [[ "$env" = "prod" ]]; then
	npm_args="--production"
fi

npm install --unsafe-perm $npm_args

if [[ -e "/var/run/docker.sock" ]]; then
	if [[ ! -f "$build/Dockerfile" ]]; then
		echo "No Dockerfile found in project dir, copying default Dockerfile."
		cp /root/Dockerfile $build/Dockerfile
	fi
	echo "Building docker image ${image_name}:${image_version}..."
	docker build -t ${image_name}:${image_version} .
fi
