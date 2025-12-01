from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pika
import os

app = FastAPI()

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "")
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "")
RABBITMQ_PASS = os.getenv("RABBITMQ_PASS", "")

def send_to_rabbitmq(message: str, QUEUE_NAME):
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    channel.queue_declare(queue=QUEUE_NAME, durable=True)
    channel.basic_publish(
        exchange='',
        routing_key=QUEUE_NAME,
        body=message.encode(),
        properties=pika.BasicProperties(delivery_mode=2)
    )
    connection.close()

@app.delete("/compras/cotacao/{id}")
def delete_cotacao(id: int):
    try:
        send_to_rabbitmq(str(id), "cotacao_offline_excluir")
        send_to_rabbitmq(str(id), "cotacao_online_excluir")
        return {"message": f"Cotação {id} enviada para exclusão."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))