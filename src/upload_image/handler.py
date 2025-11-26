import os
import json
import boto3
import uuid

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    try:
        # Parse request
        body = json.loads(event.get("body") or "{}")

        filename = body.get("filename")
        content_type = body.get("contentType", "image/jpeg")  # Default if missing

        # Extract extension
        if filename and "." in filename:
            ext = filename.split(".")[-1]
        else:
            ext = "jpg"

        # Build the S3 key (path inside bucket)
        key = f"cars/{uuid.uuid4()}.{ext}"

        # Generate presigned PUT URL (must sign with Content-Type)
        upload_url = s3.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": BUCKET,
                "Key": key,
                "ContentType": content_type
            },
            ExpiresIn=3600
        )

        # Public object URL
        object_url = f"https://{BUCKET}.s3.amazonaws.com/{key}"

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Allow-Methods": "*"
            },
            "body": json.dumps({
                "uploadUrl": upload_url,
                "objectUrl": object_url
            })
        }

    except Exception as e:
        print("Error:", e)
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
