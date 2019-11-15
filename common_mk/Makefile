CURRENT_DIR := $(shell pwd)
COMMONMK_DIR=${CURRENT_DIR}/aws-sam-template/common_mk
include ${COMMONMK_DIR}/common.mk

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
	mkdir ${name}-stack; \
	cp -RP ${COMMONMK_DIR}/template_sam/* ${name}-stack;

