DOCKER_IMAGE_NAMESPACE ?= jetson-stacks
DOCKER_IMAGE_TAG ?= dev
BASE_DOCKER_IMAGE_NAME ?= base

PACKAGES_DIR := $(realpath $(dir $(patsubst %/,%,$(abspath $(CURDIR)))))

build:
	docker build -t ${DOCKER_IMAGE_NAMESPACE}/${BASE_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
