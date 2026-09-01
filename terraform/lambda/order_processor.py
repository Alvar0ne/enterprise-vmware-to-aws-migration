import json


def lambda_handler(event, context):
    print("Evento recibido desde SQS:")
    print(json.dumps(event))

    for record in event["Records"]:
        message = json.loads(record["body"])

        print(f"Procesando evento: {message.get('event')}")
        print(f"Order ID: {message.get('orderId')}")
        print(f"Customer ID: {message.get('customerId')}")
        print(f"Total: {message.get('total')}")

        # Nos permitirá probar intencionalmente la DLQ después
        if message.get("forceFailure") is True:
            raise Exception("Fallo intencional para probar DLQ")

        print(f"Pedido {message.get('orderId')} procesado correctamente")

    return {
        "statusCode": 200
    }