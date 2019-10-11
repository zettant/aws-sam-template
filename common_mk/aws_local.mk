
start-mongodb:
	docker run -p 27017:27017 --net ${DOCKER_NETWORK} --name dev-mongo -d mongo

stop-mongodb:
	docker stop dev-mongo
	docker rm dev-mongo


start-localstack:
	if [[ -n `docker ps -f name=localstack | grep -v CONTAINER` ]]; then \
	    make stop-localstack; \
	fi
	docker run -p 4567-4582:4567-4582 -p 8080:8080 --net=${DOCKER_NETWORK} --name localstack -d localstack/localstack
	-$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    rm -rf ${CURRENT_DIR}/dynamodb/ && \
	    mkdir -p ${CURRENT_DIR}/dynamodb/ && \
	    cd ${CURRENT_DIR}/dynamodb/ && \
	    python ${TOOL_DIR}/yj_converter_dynamodb.py -y ${CURRENT_DIR}/template.yaml"
	@for file in `find ${CURRENT_DIR}/dynamodb -name "*.json"`; do \
	    $(SHELL) -c ". ${SAMDIR}/venv/bin/activate && ${AWSCLI} dynamodb create-table --profile ${PROFILE} --cli-input-json file://$${file}"; \
	done

stop-localstack:
	docker stop localstack
	docker rm localstack


create-s3bucket-local:
	@-$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    ${AWSCLI} s3 mb s3://${bucket}"

