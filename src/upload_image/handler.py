import os
import json
import boto3
import uuid

s3_client = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
    "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")

        original_name = body.get("filename")
        ext = ""
        if original_name and "." in original_name:
            ext = original_name.split(".")[-1]

        key = f"cars/{uuid.uuid4()}" + (f".{ext}" if ext else "")

        url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={"Bucket": BUCKET, "Key": key},
            ExpiresIn=3600
)


        object_url = f"https://{BUCKET}.s3.amazonaws.com/{key}"

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({
                "uploadUrl": url,
                "objectUrl": object_url,
                "key": key
            })
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }
