"""
DynamoDBをローカル環境でもAWSでも同じ設定で使えるようにするために、tmplate.yamlからテーブルごとのjsonファイルに変換する

SAMのテンプレートファイル"template.yaml"には!Refなどの独自関数が記述されている。
しかしそれはyamlモジュールでは読み込めない（エラーになる）ので、文字列置換して読み込めるようにし、
あとで、Refで参照していたところの値に置換する。
"""

from argparse import ArgumentParser
import json
import yaml
import re

ex_regex = re.compile(r"___EXCLAMATION___Ref '(.*?)'")


def parser():
    usage = 'python {} [--yaml template.yml] [--help]'.format(__file__)
    argparser = ArgumentParser(usage=usage)
    argparser.add_argument('-y', '--yaml', type=str, default='-', help='template.yaml')
    args = argparser.parse_args()
    return args


def _replace_value(v, orig):
    if isinstance(v, dict):
        return replace_dict_values(v, orig)
    elif isinstance(v, list):
        return replace_list_values(v, orig)
    elif isinstance(v, str):
        if v.find("___EXCLAMATION___") >= 0:
            m = ex_regex.match(v)
            if m is not None:
                key = m.groups()[0]
                return orig["Parameters"][key]["Default"]

    return v


def replace_dict_values(conf, orig):
    for k, v in conf.items():
        conf[k] = _replace_value(v, orig)
    return conf


def replace_list_values(conf, orig):
    for i, v in enumerate(conf):
        conf[i] = _replace_value(v, orig)
    return conf


if __name__ == "__main__":
    argresult = parser()
    yaml_file = argresult.yaml

    with open(yaml_file, "r") as f:
        template_str = f.read()
    template_str_replaced = template_str.replace("!", "___EXCLAMATION___")
    template = yaml.load(template_str_replaced, Loader=yaml.SafeLoader)
    template2 = yaml.load(template_str_replaced, Loader=yaml.SafeLoader)

    for k, v in template["Resources"].items():
        if k.find("Table") < 0:
            continue
        dynamo_conf = replace_dict_values(v["Properties"], template2)

        with open("%s.json" % k, "w") as f:
            json.dump(dynamo_conf, f)
