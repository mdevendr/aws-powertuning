import json
import os
import boto3

TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    method = event.get("httpMethod")
    rid = (event.get("pathParameters") or {}).get("id")
    body = json.loads(event.get("body") or "{}")

    if method == "GET" and not rid:
        items = table.scan().get("Items", [])
        return response(200, items)

    if method == "POST":
        if "id" not in body:
            return response(400, {"message": "id required"})
        table.put_item(Item=body)
        return response(201, body)

    if method == "GET" and rid:
        item = table.get_item(Key={"id": rid}).get("Item")
        return response(200, item or {})

    if method == "DELETE" and rid:
        table.delete_item(Key={"id": rid})
        return response(204, {"message": "deleted"})

    return response(404, {"message": "not found"})
