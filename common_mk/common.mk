SHELL=/bin/bash
SAMDIR := $(shell cd `dirname $(lastword ${MAKEFILE_LIST})`; pwd)/..
TOOL_DIR=${SAMDIR}/tools

STACK_NAME := $(shell echo `pwd` | awk -F "/" '{ print $$NF }' | sed -e "s/_/-/g")

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

include ${SAMDIR}/common_mk/param.mk
include ${SAMDIR}/common_mk/lambda_api.mk
include ${SAMDIR}/common_mk/prepare.mk
include ${SAMDIR}/common_mk/aws_local.mk
include ${SAMDIR}/common_mk/deploy.mk
include ${SAMDIR}/common_mk/test.mk
