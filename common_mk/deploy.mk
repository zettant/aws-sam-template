
package:
	if [[ -z `. ${SAMDIR}/venv/bin/activate && ${AWSCLI} s3 ls --profile ${PROFILE} | grep ${S3_TEMPLATE_BUCKET}` ]]; then \
		@-$(SHELL) -c "\
		    . ${SAMDIR}/venv/bin/activate && \
		    ${AWSCLI} s3 mb s3://${S3_BUCKET} --profile ${PROFILE}"; \
	fi	
	@-$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    ${AWSCLI} cloudformation package --profile ${PROFILE} --template-file template.yaml --output-template-file packaged.yaml --s3-bucket ${S3_BUCKET}"


deploy:
	$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    ${AWSCLI} cloudformation deploy --profile ${PROFILE} --template-file packaged.yaml --stack-name ${STACK_NAME} --capabilities CAPABILITY_IAM --parameter-overrides DeployEnv=${DEPLOY_ENV}"
	make update-env


update-env:
	@$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    python ${TOOL_DIR}/make_env.py -f ${CURRENT_DIR}/env.json -s ${STACK_NAME} -p ${PROFILE} -e ${DEPLOY_ENV}"


delete-stack:
	@# ******* 危険 (productionでは使わない)*******
	if [[ "${DEPLOY_ENV}" != "prod" ]]; then \
	    bash -c "\
	        . ${SAMDIR}/venv/bin/activate && \
	        ${AWSCLI} cloudformation delete-stack --profile ${PROFILE} --stack-name ${STACK_NAME}"; \
	fi
