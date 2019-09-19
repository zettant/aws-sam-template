
start-dynamodb:
	if [[ -n `docker ps -f name=dynamodb | grep -v CONTAINER` ]]; then \
	    make stop-dynamodb; \
	fi
	docker run -d --network lambda-local --name dynamodb -p ${DYNAMO_PORT}:8000 amazon/dynamodb-local -jar DynamoDBLocal.jar -sharedDb
	-$(SHELL) -c "\
	    . ${ROOT_DIR}/venv/bin/activate && \
	    rm -rf ${CURRENT_DIR}/dynamodb/ && \
	    mkdir -p ${CURRENT_DIR}/dynamodb/ && \
	    cd ${CURRENT_DIR}/dynamodb/ && \
	    python ${TOOL_DIR}/yj_converter_dynamodb.py -y ${CURRENT_DIR}/template.yaml"
	@for file in `find ${CURRENT_DIR}/dynamodb -name "*.json"`; do \
	    $(SHELL) -c ". ${ROOT_DIR}/venv/bin/activate && aws dynamodb create-table --profile ${PROFILE} --cli-input-json file://$${file} --endpoint-url http://localhost:${DYNAMO_PORT}"; \
	done


stop-dynamodb:
	@-docker stop dynamodb
	@-docker rm dynamodb

