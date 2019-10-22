import sys
from argparse import ArgumentParser
import json
import re
import pprint
from boto3.session import Session


def parser():
    usage = 'python {} [--file testenv.json] [--profile profile_name] [--stack stack_name] [--env deploy_env] [--help]'.format(__file__)
    argparser = ArgumentParser(usage=usage)
    argparser.add_argument('-f', '--file', type=str, help='env.json to overwrite')
    argparser.add_argument('-p', '--profile', type=str, help='profile name')
    argparser.add_argument('-e', '--env', type=str, help='DEPLOY_ENV value')
    argparser.add_argument('-s', '--stack', type=str, help='stack name (= directory name)')
    args = argparser.parse_args()
    return args


def overwrite_json(filepath, stack, profile, env_name):
    """Overwrite env.json

    Args:
        filepath(str|None): file path of "env.json"
        stack(str): stack name
        profile(str): aws profile name
        env_name(str): DEPLOY_ENV name (prod/dev/local)
    """
    if filepath is None:
        orig_env = dict()
    else:
        with open(filepath, "r") as f:
            dat = f.read()
        orig_env = json.loads(dat)

    try:
        session = Session(profile_name=profile)
        result = session.client('cloudformation').describe_stacks(StackName=stack)
    except Exception as e:
        print("Error:", e)
        sys.exit(1)

    target_stack = None
    for v in result["Stacks"]:
        if v["StackName"] == stack:
            target_stack = v["Outputs"]
            break
    if target_stack is None:
        print("No such stack:", stack)
        sys.exit(1)

    env_output = {"profile_name": profile}
    for v in target_stack:
        key = v["OutputKey"]
        value = v["OutputValue"]
        if re.search("UserPoolId", key):
            env_output.setdefault("user_pool_id", dict())[key] = value
        elif re.search("UserPoolAppClientId", key):
            env_output.setdefault("client_id", dict())[key] = value
        elif key == "ApiGateway":
            env_output["base_url"] = value+env_name
        elif re.search("ApiKey", key):
            response = session.client('apigateway').get_api_key(apiKey=value, includeValue=True)
            env_output.setdefault("apikey", dict())[key] = response['value']
        elif re.search("Function$", key):
            env_output.setdefault("lambda", dict())[key] = value
        elif re.search("S3Bucket", key):
            env_output.setdefault("s3", dict())[key] = value
        elif re.search("VpcId", key):
            env_output.setdefault("vpc", dict())[key] = value
        elif re.search("Subnet", key):
            env_output.setdefault("subnet", dict())[key] = value
        elif re.search("PrivateIP", key):
            env_output.setdefault("ipaddress", dict())[key] = value
        elif re.search("SecurityGroup", key):
            env_output.setdefault("securitygroup", dict())[key] = value

    for k in env_output.keys():
        if len(env_output[k]) == 1 and isinstance(env_output[k], dict):
            env_output[k] = list(env_output[k].values())[0]

    for k in env_output.keys():
        if len(env_output[k]) == 1 and isinstance(env_output[k], dict):
            env_output[k] = list(env_output[k].values())[0]

    print("--------------------------")
    pprint.pprint(env_output)
    print("--------------------------")
    orig_env[env_name] = env_output
    with open(filepath, "w") as f:
        f.write(json.dumps(orig_env, ensure_ascii=False, indent=4, sort_keys=True))
    print("** %s has been overwritten." % filepath)


if __name__ == '__main__':
    argresult = parser()
    filepath = argresult.file
    profile = argresult.profile
    stack_name = argresult.stack
    env_name = argresult.env
    if profile is None or stack_name is None or env_name is None:
        print("-p, -s and -e option are mandatory")
        sys.exit(1)
    if env_name == "local":
        print("The value of -e option must not be 'local'")
        sys.exit(1)
    overwrite_json(filepath, stack_name, profile, env_name)
