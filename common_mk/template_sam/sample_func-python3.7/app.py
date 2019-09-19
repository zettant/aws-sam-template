import os
import sys
sys.path.append("pymodules")
import json
import boto3


if "TABLE_NAME1" not in os.environ:
    raise Exception("No env for DynamoDB tables")

if "DEPLOY_ENV" not in os.environ or os.environ["DEPLOY_ENV"] == "local":
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://dynamodb:8000")
else:
    dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ["TABLE_NAME1"])


def lambda_handler(event, context):
    body = json.loads(event["body"])
    record = body.get("record", {"column1": "test1", "column2": "test1-2", "column3": 10})

    table.put_item(
        Item={
            "column1": record["column1"],
            "column2": record["column2"],
            "column3": record["column3"],
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps({"message": "test message"})
    }
