DOCKER_IMAGE_NAMESPACE ?= jetson-stacks
DOCKER_IMAGE_TAG ?= dev

BASE_IMAGE_NAME := base
BUILD_FROM_BASE_IMAGE := "docker build --build-arg BASE_IMAGE=$(DOCKER_IMAGE_NAMESPACE)/$(BASE_DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)"
base:
	cd packages/base
	docker build -t $(DOCKER_IMAGE_NAMESPACE)/$(BASE_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

BASE_TEST_IMAGE_NAME := base-test
base-test: base
	cd packages/base-test
	$(BUILD_FROM_BASE_IMAGE) -t $(DOCKER_IMAGE_NAMESPACE)/base-test:$(DOCKER_IMAGE_TAG) .
