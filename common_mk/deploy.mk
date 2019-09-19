
package:
	bash -c "\
	    . ${ROOT_DIR}/venv/bin/activate && \
	    sam package --profile ${PROFILE} --template-file template.yaml --output-template-file packaged.yaml --s3-bucket ${S3_BUCKET}"


deploy:
	bash -c "\
	    . ${ROOT_DIR}/venv/bin/activate && \
	    sam deploy --debug --profile ${PROFILE} --template-file packaged.yaml --stack-name ${STACK_NAME} --capabilities CAPABILITY_IAM --parameter-overrides DeployEnv=${DEPLOY_ENV}"
	make update-env


update-env:
	@bash -c "\
	    . ${ROOT_DIR}/venv/bin/activate && \
	    python ${TOOL_DIR}/make_env.py -f ${CURRENT_DIR}/env.json -s ${STACK_NAME} -p ${PROFILE} -e ${DEPLOY_ENV}"


delete-stack:
	@# ******* 危険 (productionでは使わない)*******
	if [[ "${DEPLOY_ENV}" != "prod" ]]; then \
	    bash -c "\
	        . ${ROOT_DIR}/venv/bin/activate && \
	        aws cloudformation delete-stack --profile ${PROFILE} --stack-name ${STACK_NAME}"; \
	fi
