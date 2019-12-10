include common_mk/param.mk

prepare:
	cp common_mk/Makefile ..
	rm -rf venv
	@bash -c "\
          python3 -mvenv venv && \
          . venv/bin/activate && \
          pip install -r requirements.txt"
	#@-docker network create ${DOCKER_NETWORK}
	#@-docker pull localstack/localstack
	#@-docker pull mongo

