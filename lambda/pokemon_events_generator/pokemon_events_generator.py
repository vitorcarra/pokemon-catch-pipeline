import json
from kafka import KafkaProducer, KafkaClient
import pandas as pd
import random
from faker import Faker
from uuid import uuid4
from datetime import datetime
import os

def lambda_handler(event, context):
    # initialize faker
    Faker.seed(0)
    fake = Faker()
    kafka_brokers = os.getenv('kafka_broker').split(',')
    kafka_topic = os.getenv('kafka_topic')    

    # load pokemon dataset
    pokemons = pd.read_csv(filepath_or_buffer="./data/pokemon.csv", delimiter=',', encoding="utf-8")

    # get a random events quantity
    events_to_generate_quantity = random.randint(10, 50)

    # create kafka producer
    producer = KafkaProducer(
        bootstrap_servers=kafka_brokers, 
        security_protocol="SSL", 
        value_serializer=lambda m: json.dumps(m).encode('ascii')
    )

    # generate pokemon catches
    for _ in range(events_to_generate_quantity):
        # get a random pokemon
        pokemon = list(pokemons.sample(n=1).to_dict('index').values())[0]

        # get a random location
        location = fake.location_on_land()

        pokemon_catch_event = {
            "event_id": str(uuid4()),
            "pokemon_name": pokemon["name"],
            "catch_ts": datetime.now().timestamp(),
            "location_coord": {
                "lat": location[0],
                "lon": location[1]
            },
            "place_name": location[2],
            "country": location[3]
        }

        # producer.send(kafka_topic, pokemon_catch_event)
        print(pokemon_catch_event)
    

if __name__ == '__main__':
    lambda_handler(None, None)