import os
import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    try:
        path_params = event.get("pathParameters") or {}
        car_id = path_params.get("carId")
        if not car_id:
            return {"statusCode": 400, "body": json.dumps({"error": "carId path parameter missing"})}

        resp = table.get_item(Key={"carId": car_id})
        item = resp.get("Item")
        if not item:
            return {"statusCode": 404, "body": json.dumps({"error": "Car not found"})}
        return {"statusCode": 200, "body": json.dumps(item)}
    except Exception as e:
        print("Error:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}