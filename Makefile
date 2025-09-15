DOCKER_IMAGE_NAMESPACE ?= jetson-stacks
DOCKER_IMAGE_TAG ?= dev

build_base:
	$(MAKE) -C packages/base build

test_base: 
	$(MAKE) -C test/base build