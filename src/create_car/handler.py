import os
import json
import uuid
import datetime
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
        # expected fields: brand, model, year, price, mileage, description, imageUrl
        car_id = str(uuid.uuid4())
        now = datetime.datetime.utcnow().isoformat()

        item = {
            "carId": car_id,
            "brand": body.get("brand", ""),
            "model": body.get("model", ""),
            "year": str(body.get("year", "")),
            "price": str(body.get("price", "")),
            "mileage": str(body.get("mileage", "")),
            "description": body.get("description", ""),
            "imageUrl": body.get("imageUrl", ""),
            "createdAt": now,
            "updatedAt": now
        }

        table.put_item(Item=item)

        return {
            "statusCode": 201,
            "body": json.dumps({"carId": car_id})
        }

    except Exception as e:
        print("Error:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}