CURRENT_DIR := $(shell pwd)

include mk/params.mk
include ../common_mk/common.mk
include mk/custom.mk

#--- don't edit above

prepare:
	make prepare-python func=sample_func-__LAMBDA_RUNTIME__
	bash -c "\
	    cd tests && \
	    python3 -mvenv venv && \
	    . venv/bin/activate && \
	    pip install -r requirements.txt"


lambda-test:
	make lambda-local-test func=SampleLambdaFunction


api-test:
	make api-test-unit


create-s3-local:
	make create-s3bucket-local bucket=${bucket_name}


dist-clean:
	make distclean-python func=sample_func-__LAMBDA_RUNTIME__
