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

#
# EXTRA_PKGS is a space separated list of extra Alpine packages to install
# before running `npm install`
# @see-also: https://pkgs.alpinelinux.org/packages
#
if [[ ! -z "$EXTRA_PKGS" ]]; then
	apk update
	apk add $EXTRA_PKGS
fi

cp -R $source/* $build
# Remove `node_modules` folder in build folder since we're going to re-install
# packages anyhow, `npm rebuild` might be a better choice here
rm -rf $build/node_modules

if [[ "$env" = "prod" || "$env" = "production" ]]; then
	npm_args="--production"
fi

# Using `--unsafe-perm` option because `npm` was yelling at me as root
npm install --unsafe-perm $npm_args

if [[ -e "/var/run/docker.sock" ]]; then
	if [[ ! -f "$build/Dockerfile" ]]; then
		echo "No Dockerfile found in project dir, copying default Dockerfile."
		cp /root/Dockerfile $build/Dockerfile
	fi
	echo "Building docker image ${image_name}:${image_version}..."
	docker build -t ${image_name}:${image_version} .
else
	echo "Not building docker image because /var/run/docker.sock was not mounted. See docs for example."
fi
