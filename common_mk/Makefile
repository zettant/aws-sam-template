CURRENT_DIR := $(shell pwd)
COMMONMK_DIR=${CURRENT_DIR}/aws-sam-template/common_mk
include ${COMMONMK_DIR}/common.mk

S3_TEMPLATE_BUCKET=

prepare-venv:
	@bash -c "\
	  cd ${COMMONMK_DIR}/.. && \
	  python3 -mvenv venv && \
	  . venv/bin/activate && \
	  pip install -r requirements.txt"

stack:
	if [[ ! -d ${COMMONMK_DIR}/../venv ]]; then \
		make prepare-venv; \
	fi
	@if [[ -z "${S3_TEMPLATE_BUCKET}" ]]; then \
		echo "### set unique s3 backet name to S3_TEMPLATE_BUCKET in Makefile"; \
		echo; \
	else \
		mkdir ${name}-stack; \
		cp -RP ${COMMONMK_DIR}/template_sam/* ${name}-stack; \
		cd ${name}-stack && sed -i -e 's/S3_TEMPLATE_BUCKET=/S3_TEMPLATE_BUCKET=${S3_TEMPLATE_BUCKET}/' Makefile; \
	fi
