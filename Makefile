DOCKER_NETWORK=lambda-local

prepare:
	cp common_mk/Makefile ..
	@bash -c "\
          python3 -mvenv venv && \
          . venv/bin/activate && \
          pip install -r requirements.txt"
	#@-docker network create ${DOCKER_NETWORK}
	#@-docker pull localstack/localstack
	#@-docker pull mongo

