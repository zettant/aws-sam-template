
prepare-python:
	# TODO: 本当はここで"sam build"をしたいのだが、msgpack-pythonモジュールがビルドに失敗するので主導でビルドする
	if [[ ! -e ${CURRENT_DIR}/${func}/pymodules ]]; then \
	    python3 -mvenv ${CURRENT_DIR}/venv; \
	    bash -c "\
	        . ${CURRENT_DIR}/venv/bin/activate && \
	        mkdir -p ${CURRENT_DIR}/${func}/pymodules && \
	        cd ${CURRENT_DIR}/${func} && \
	        pip install -r requirements.txt -t ./pymodules"; \
	fi


distclean-python:
	rm -rf ${CURRENT_DIR}/venv
	rm -rf ${CURRENT_DIR}/${func}/pymodules
