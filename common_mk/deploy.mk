package:
	@$(eval AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --profile $(PROFILE) | jq -r ."Account"))
	@$(eval STACK_NAME_LCASE := $(shell echo $(STACK_NAME) | tr A-Z a-z))
	@$(eval S3_TEMPLATE_BUCKET := $(AWS_ACCOUNT_ID)-$(STACK_NAME_LCASE)-sam)
	if [[ -z `. ${SAMDIR}/venv/bin/activate && ${AWSCLI} s3 ls --profile ${PROFILE} | grep ${S3_TEMPLATE_BUCKET}-${PROFILE}` ]]; then \
		$(SHELL) -c "\
		    . ${SAMDIR}/venv/bin/activate && \
		    ${AWSCLI} s3 mb s3://${S3_TEMPLATE_BUCKET}-${PROFILE} --profile ${PROFILE}"; \
	fi	
	@$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    ${AWSCLI} cloudformation package --profile ${PROFILE} --template-file template.yaml --output-template-file packaged.yaml --s3-bucket ${S3_TEMPLATE_BUCKET}-${PROFILE}"


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
	    $(SHELL) -c "\
	        . ${SAMDIR}/venv/bin/activate && \
	        ${AWSCLI} cloudformation delete-stack --profile ${PROFILE} --stack-name ${STACK_NAME}"; \
	fi
