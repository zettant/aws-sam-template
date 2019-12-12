CURRENT_DIR := $(shell pwd)

include mk/params.mk
include ../aws-sam-template/common_mk/common.mk
include mk/custom.mk

#--- don't edit above

prepare:
	make prepare-python func=sample_func-python3.7
	make build-go func=sample_func-go1.x
	bash -c "\
	    cd tests && \
	    python3 -mvenv venv && \
	    . venv/bin/activate && \
	    pip install -r requirements.txt"
	make update-source


update-source:
        echo "call this rule if you want to copy latest codes from somewhere"


lambda-test:
	make lambda-local-test func=SampleLambdaFunction
	make lambda-local-test func=SampleLambdaFunctionGo


api-test:
	make api-test-unit


create-s3-local:
	make create-s3bucket-local bucket=${bucket_name}


dist-clean:
	make distclean-python func=sample_func-python3.7
	make distclean-go func=sample_func-go1.x
