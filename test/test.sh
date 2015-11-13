#!/bin/sh +e
test_proj="btford/angular-express-blog"
proj_name=$(basename $test_proj)

if [[ ! -d test/$proj_name ]]; then
	git clone https://github.com/$test_proj
fi

docker run \
	--rm \
	-v $(pwd)/test/$proj_name:/src \
	-v /var/run/docker.sock:/var/run/docker.sock \
	alpine-nodejs-builder:4.2.1 \
	$proj_name

if [[ $? -gt 0 ]]; then
	echo "Test failed!"
	exit 1
fi
