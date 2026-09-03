import json
import os
import boto3
from datetime import datetime, timezone


s3 = boto3.client("s3")

BUCKET_NAME = os.environ["DATA_LAKE_BUCKET"]


def lambda_handler(event, context):
    print("Evento recibido desde EventBridge:")
    print(json.dumps(event))

    detail = event.get("detail", {})

    order_id = detail.get("orderId")
    customer_id = detail.get("customerId")
    customer_email = detail.get("customerEmail")
    total = detail.get("total")
    created_at = detail.get("createdAt")

    if not order_id:
        raise ValueError("El evento no contiene detail.orderId")

    now = datetime.now(timezone.utc)

    analytics_record = {
        "eventType": event.get("detail-type"),
        "source": event.get("source"),
        "orderId": order_id,
        "customerId": customer_id,
        "customerEmail": customer_email,
        "total": total,
        "createdAt": created_at,
        "processedAt": now.isoformat()
    }

    key = (
        f"raw/orders/"
        f"year={now.year}/"
        f"month={now.month:02d}/"
        f"day={now.day:02d}/"
        f"{order_id}.json"
    )

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=json.dumps(analytics_record),
        ContentType="application/json"
    )

    print(f"Evento analítico almacenado en s3://{BUCKET_NAME}/{key}")

    return {
        "statusCode": 200,
        "orderId": order_id,
        "s3Key": key
    }