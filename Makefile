
NODE_VERSION := 4.2.1
TAG := alpine-nodejs-builder

default:
	@docker build -t $(TAG):$(NODE_VERSION) builder/

test: default
	@test/test.sh

.PHONY: test
