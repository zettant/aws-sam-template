import requests
import json
import os

TOKEN = None


def get_env_values(env_name):
    this_directory = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(this_directory, "../env.json"), "r") as f:
        dat = f.read()
    jsondat = json.loads(dat)
    return jsondat.get(env_name, None)


def http_post(path='', parameter={}):
    headers = {u'Content-Type': u'application/json'}
    if TOKEN is not None:
        headers[u'Authorization'] = u'Bearer %s' % TOKEN

    return requests.post(path, json=parameter, headers=headers, verify=True)
