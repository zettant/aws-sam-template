
start-api:
	-$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    sam local start-api --profile ${PROFILE} --docker-network ${DOCKER_NETWORK}"

lambda-local-test:
	-$(SHELL) -c "\
	    . ${SAMDIR}/venv/bin/activate && \
	    sam local invoke ${func} -e event.json --profile ${PROFILE} --docker-network ${DOCKER_NETWORK}"

