import json
from kafka import KafkaProducer, KafkaClient
import pandas as pd
import random
from faker import Faker
from uuid import uuid4
from datetime import datetime

def lambda_handler(event, context):
    # initialize faker
    Faker.seed(0)
    fake = Faker()
    

    # load pokemon dataset
    pokemons = pd.read_csv(filepath_or_buffer="./data/pokemon.csv", delimiter=',', encoding="utf-8")

    # get a random events quantity
    events_to_generate_quantity = random.randint(10, 50)

    # create kafka producer
    #producer = KafkaProducer(value_serializer=lambda m: json.dumps(m).encode('ascii'))

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

        print(pokemon_catch_event)
    
    
    
    task_op = {
        "'message": "Hai, Calling from AWS Lambda"
    }
    # print(json.dumps(task_op))
    #producer.send_messages("topic_atx_ticket_update",json.dumps(task_op).encode('utf-8'))
    # print(producer.send_messages)
    #return ("Messages Sent to Kafka Topic")

if __name__ == '__main__':
    lambda_handler(None, None)