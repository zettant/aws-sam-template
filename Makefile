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
	@if [[ -z "${runtime}" ]]; then \
	    echo "** runtime is mandatory! (python3.7|go1.x|nodejs10.x)"; \
	    exit 1; \
	fi
	mkdir ${name}-stack
	cp -RP common_mk/template_sam/* ${name}-stack
	cd ${name}-stack && \
	sed -i -e 's/__LAMBDA_RUNTIME__/${runtime}/g' template.yaml && \
	sed -i -e 's/__LAMBDA_RUNTIME__/${runtime}/g' Makefile && \
	rm -f template.yaml-e Makefile-e
