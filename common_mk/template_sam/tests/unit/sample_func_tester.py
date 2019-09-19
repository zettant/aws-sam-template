# -*- coding: utf-8 -*-
import time
import os
import sys
import base64
sys.path.append("../")
from testutils import get_env_values, http_post

ENV_NAME = os.environ["DEPLOY_ENV"] if "DEPLOY_ENV" in os.environ else "local"
e = get_env_values(ENV_NAME)


class TestSampleFunction(object):

    def test_01_post_request(self):
        print("\n-----", sys._getframe().f_code.co_name, "-----")
        param = {
            "column1": "colA",
            "column2": "colB",
            "column3": int(time.time())
        }
        resp = http_post(path=e["base_url"]+"/rest_api", parameter=param)
        assert resp.status_code == 200

