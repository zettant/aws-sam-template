
api-test-unit:
	bash -c "\
	    cd tests && \
	    . venv/bin/activate && \
	    cd unit && \
	    DEPLOY_ENV=${DEPLOY_ENV} pytest *_tester.py"

