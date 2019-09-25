import os
import sys
sys.path.append("pymodules")
import json
import boto3


if "TABLE_NAME1" not in os.environ:
    raise Exception("No env for DynamoDB tables")

if "S3BUCKET_NAME1" not in os.environ:
    raise Exception("No env for S3Bucket name")

if "DEPLOY_ENV" not in os.environ or os.environ["DEPLOY_ENV"] == "local":
    dynamodb = boto3.resource('dynamodb', endpoint_url="http://localstack:4569")
    s3 = boto3.resource('s3', endpoint_url="http://localstack:4572")
    #sqs = boto3.resource('sqs', endpoint_url="http://localstack:4576")
    #ses = boto3.resource('sqs', endpoint_url="http://localstack:4579")
    #import pymongo
    #mongodb = pymongo.MongoClient("mongodb://dev-mongo:27017")

else:
    dynamodb = boto3.resource('dynamodb')
    s3 = boto3.resource('s3')
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

    obj = s3.Object(os.environ["S3BUCKET_NAME1"], "test.json")
    obj.put(Body=event["body"])

    obj.delete()

    return {
        'statusCode': 200,
        'body': json.dumps({"message": "test message"})
    }
