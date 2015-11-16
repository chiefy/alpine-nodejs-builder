#!/bin/sh

VERSION=${NODE_VERSION:?"No nodejs version provided"}

echo "Building alpine-nodejs-builder docker image with nodejs version ${VERSION}\n"
echo "--------------------------------------------------------------------------\n"

echo "Updating and installing alpine packages...\n"
apk add --update \
	curl \
	bash \
	build-base \
	make \
	git \
	gcc \
	g++ \
	python \
	linux-headers \
	paxctl \
	libgcc \
	libstdc++

# Make NodeJS
# TODO verify file hash
curl -sSL https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.gz | tar -xz
cd node-${VERSION}
./configure --prefix=/usr ${CONFIG_FLAGS}
make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)
make install
paxctl -cm /usr/bin/node

# Install npm
echo "Installing npm\n"
if [ -x /usr/bin/npm ]; then
	npm install -g npm &&
	find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf;
fi

echo "Cleaning up...\n"
rm -rf \
	/root/node-${VERSION} \
	/usr/share/man \
	/tmp/* \
	/var/cache/apk/* \
	/usr/lib/node_modules/npm/man \
	/usr/lib/node_modules/npm/doc \
	/usr/lib/node_modules/npm/html
