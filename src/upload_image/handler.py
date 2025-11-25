import os
import json
import boto3
import uuid

s3_client = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
        # client can request original filename or let server generate key
        original_name = body.get("filename")
        ext = ""
        if original_name and "." in original_name:
            ext = original_name.split(".")[-1]
        key = f"cars/{str(uuid.uuid4())}" + (f".{ext}" if ext else "")

        # generate presigned PUT URL
        url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={"Bucket": BUCKET, "Key": key, "ACL": "public-read"},
            ExpiresIn=3600
        )

        object_url = f"https://{BUCKET}.s3.amazonaws.com/{key}"

        return {
            "statusCode": 200,
            "body": json.dumps({"uploadUrl": url, "key": key, "objectUrl": object_url})
        }

    except Exception as e:
        print("Error:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}