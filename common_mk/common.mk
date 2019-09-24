SHELL=/bin/bash
ROOT_DIR := $(shell cd `dirname $(lastword ${MAKEFILE_LIST})`; pwd)/..
TOOL_DIR=${ROOT_DIR}/tools

S3_BUCKET="sam-stack-deployment"

STACK_NAME := $(shell echo `pwd` | awk -F "/" '{ print $$NF }' | sed -e "s/_/-/g")

DOCKER_NETWORK=lambda-local
AWSCLI=aws

ifeq ($(DEPLOY_ENV),prod)
	PROFILE=${PROFILE_PROD}
else ifeq ($(DEPLOY_ENV),dev)
	PROFILE=${PROFILE_DEV}
else
	PROFILE=${PROFILE_LOCAL}
	DEPLOY_ENV=local
	AWSCLI=awslocal
endif

include ${ROOT_DIR}/common_mk/lambda_api.mk
include ${ROOT_DIR}/common_mk/prepare.mk
include ${ROOT_DIR}/common_mk/aws_local.mk
include ${ROOT_DIR}/common_mk/deploy.mk
include ${ROOT_DIR}/common_mk/test.mk
