
import json
import os
import boto3
from boto3.dynamodb.conditions import Key

TABLE_NAME = os.environ["TABLE_NAME"]
dynamo = boto3.resource("dynamodb")
table = dynamo.Table(TABLE_NAME)

def _resp(status, body):
    return {"statusCode": status, "headers": {"Content-Type": "application/json"}, "body": json.dumps(body)}

def lambda_handler(event, context):
    method = event.get("httpMethod")
    path   = event.get("path", "")
    body   = json.loads(event.get("body") or "{}")
    rid    = (event.get("pathParameters") or {}).get("id")

    if method == "GET" and path.endswith("/items") and not rid:
        items = table.scan().get("Items", [])
        return _resp(200, items)

    if method == "POST" and path.endswith("/items"):
        if "id" not in body:
            return _resp(400, {"message": "id required"})
        table.put_item(Item=body)
        return _resp(201, body)

    if method == "GET" and rid:
        item = table.get_item(Key={"id": rid}).get("Item")
        return _resp(200, item or {})

    if method == "DELETE" and rid:
        table.delete_item(Key={"id": rid})
        return _resp(204, {"message": "deleted"})

    return _resp(404, {"message": "not found"})
