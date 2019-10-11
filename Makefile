DOCKER_NETWORK=lambda-local

prepare:
	cp common_mk/Makefile ..
	#@-docker network create ${DOCKER_NETWORK}
	#@-docker pull localstack/localstack
	#@-docker pull mongo

