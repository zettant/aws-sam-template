SHELL=/bin/bash
ROOT_DIR := $(shell cd `dirname $(lastword ${MAKEFILE_LIST})`; pwd)/..
TOOL_DIR=${ROOT_DIR}/tools

S3_BUCKET="sam-stack-deployment"

DYNAMO_PORT=8001
DOCKER_NETWORK=lambda-local

STACK_NAME := $(shell echo `pwd` | awk -F "/" '{ print $$NF }' | sed -e "s/_/-/g")


ifeq ($(DEPLOY_ENV),prod)
	PROFILE=${PROFILE_PROD}
else ifeq ($(DEPLOY_ENV),dev)
	PROFILE=${PROFILE_DEV}
else
	PROFILE=${PROFILE_LOCAL}
	DEPLOY_ENV=local
endif

include ${ROOT_DIR}/common_mk/dynamodb.mk
include ${ROOT_DIR}/common_mk/lambda_api.mk
include ${ROOT_DIR}/common_mk/prepare.mk
include ${ROOT_DIR}/common_mk/deploy.mk
include ${ROOT_DIR}/common_mk/test.mk
