import os
import json
import boto3
import uuid

s3_client = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")

        original_name = body.get("filename")
        content_type = body.get("contentType", "application/octet-stream")

        ext = ""
        if original_name and "." in original_name:
            ext = original_name.split(".")[-1]

        key = f"cars/{uuid.uuid4()}" + (f".{ext}" if ext else "")

        # Generate presigned PUT URL WITH Content-Type header
        url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={
                "Bucket": BUCKET,
                "Key": key,
                "ContentType": content_type
            },
            ExpiresIn=3600
        )

        object_url = f"https://{BUCKET}.s3.amazonaws.com/{key}"

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "uploadUrl": url,
                "objectUrl": object_url
            })
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
