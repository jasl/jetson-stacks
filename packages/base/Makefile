DOCKER_IMAGE_NAMESPACE ?= jetson-stacks
DOCKER_IMAGE_TAG ?= dev
BASE_DOCKER_IMAGE_NAME ?= base

PACKAGES_DIR := $(realpath $(dir $(patsubst %/,%,$(abspath $(CURDIR)))))

build:
	docker build -t ${DOCKER_IMAGE_NAMESPACE}/${BASE_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

test: build
	docker build --build-arg BASE_IMAGE=${DOCKER_IMAGE_NAMESPACE}/${BASE_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} -t ${DOCKER_IMAGE_NAMESPACE}/${BASE_DOCKER_IMAGE_NAME}-test:${DOCKER_IMAGE_TAG} -f ./test.Dockerfile .
