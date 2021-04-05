SHELL := '/bin/bash'

.DEFAULT_GOAL := default


MKFILE_DIR = $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CWD = $(CURDIR)



CONTAINER_IMAGE_TAG ?= node-app
DOCKER_BUILD_CONTEXT_PATH = $(MKFILE_DIR)

.PHONY: build
.SILENT: build
build:
	docker build \
		--file $(MKFILE_DIR)/Dockerfile \
		--tag $(CONTAINER_IMAGE_TAG) \
		$(DOCKER_BUILD_CONTEXT_PATH)

.PHONY: clean
.SILENT: clean
clean:
	docker container stop --time=0 $$(docker ps --quiet) 2>/dev/null ||:
	docker container prune --force
	docker image prune --all --force

.PHONY: start
.SILENT: start
start:
	docker run \
		--detach \
		--publish 8080:8080 \
		--name $(CONTAINER_IMAGE_TAG) \
		$(CONTAINER_IMAGE_TAG)

.PHONY: stop
.SILENT: stop
stop:
	docker container stop --time=0 $$(docker ps --quiet) 2>/dev/null ||:

.PHONY: shell
.SILENT: shell
shell:
	docker exec -it $$(docker run --entrypoint '/bin/sh' --detach $(CONTAINER_IMAGE_TAG) "-c" "while true; do sleep 3600; done") /bin/bash
