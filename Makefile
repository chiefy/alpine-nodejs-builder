
NODE_VERSION ?= 4.2.2
TAG := alpine-nodejs-builder
BUILDER := "builder/"
DOCKERFILE_TEMPLATE := "$(BUILDER)_Dockerfile"
DOCKERFILE := "$(BUILDER)Dockerfile"

$(DOCKERFILE):
	@sed "s/%NODE_VERSION%/$(NODE_VERSION)/" $(DOCKERFILE_TEMPLATE) > $@

default: build

build: $(DOCKERFILE)
	docker build -t $(TAG):$(NODE_VERSION) $(BUILDER)

force_build: $(DOCKERFILE)
	@docker build --rm --no-cache -t $(TAG):$(NODE_VERSION) $(BUILDER)

test: build
	@test/test.sh

clean:
	@rm -rf $(DOCKERFILE)

.PHONY: test force_build build clean
