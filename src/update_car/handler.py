import os
import json
import boto3
import datetime

dynamodb = boto3.client("dynamodb")
TABLE = os.environ["TABLE_NAME"]

def lambda_handler(event, context):
    try:
        path_params = event.get("pathParameters") or {}
        car_id = path_params.get("carId")
        if not car_id:
            return {"statusCode": 400, "body": json.dumps({"error": "carId path parameter missing"})}

        body = json.loads(event.get("body") or "{}")
        # build UpdateExpression
        expression = []
        values = {}
        for key in ["brand","model","year","price","mileage","description","imageUrl"]:
            if key in body:
                expression.append(f"{key} = :{key}")
                values[f":{key}"] = {"S": str(body[key])}

        # always update updatedAt
        expression.append("updatedAt = :updatedAt")
        values[":updatedAt"] = {"S": datetime.datetime.utcnow().isoformat()}

        if not expression:
            return {"statusCode": 400, "body": json.dumps({"error": "No fields to update"})}

        update_expr = "SET " + ", ".join(expression)

        dynamodb.update_item(
            TableName=TABLE,
            Key={"carId": {"S": car_id}},
            UpdateExpression=update_expr,
            ExpressionAttributeValues=values
        )

        return {"statusCode": 200, "body": json.dumps({"message": "Updated"})}

    except Exception as e:
        print("Error:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}