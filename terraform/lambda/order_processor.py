import json


def lambda_handler(event, context):
    print("Evento recibido desde SQS:")
    print(json.dumps(event))

    for record in event["Records"]:
        message = json.loads(record["body"])

        # EventBridge envuelve nuestros datos dentro de "detail"
        detail = message.get("detail", {})

        event_type = message.get("detail-type")
        order_id = detail.get("orderId")
        customer_id = detail.get("customerId")
        customer_email = detail.get("customerEmail")
        total = detail.get("total")

        print(f"Procesando evento: {event_type}")
        print(f"Order ID: {order_id}")
        print(f"Customer ID: {customer_id}")
        print(f"Customer Email: {customer_email}")
        print(f"Total: {total}")

        # Validación: no queremos procesar eventos incompletos
        if not order_id:
            raise ValueError("El evento no contiene detail.orderId")

        # Nos permitirá seguir probando intencionalmente la DLQ después
        if detail.get("forceFailure") is True:
            raise Exception("Fallo intencional para probar DLQ")

        print(f"Pedido {order_id} procesado correctamente")

    return {
        "statusCode": 200
    }