CURRENT_DIR := $(shell pwd)
include common_mk/common.mk


prepare:
	make prepare-sam
	make prepare-localstack
	make prepare-mongodb


prepare-sam:
	@bash -c "\
	  python3 -mvenv venv && \
	  . venv/bin/activate && \
	  pip install -r requirements.txt"
	@-docker network create ${DOCKER_NETWORK}

prepare-localstack:
	@-docker pull localstack/localstack

prepare-mongodb:
	@-docker pull mongo


stack:
	mkdir ${name}-stack
	cp -RP common_mk/template_sam/* ${name}-stack
