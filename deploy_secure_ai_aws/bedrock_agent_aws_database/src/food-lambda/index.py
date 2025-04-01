import logging
import os
import json
import psycopg2

LOG_LEVEL = os.getenv('LOG_LEVEL')
DATABASE_URL = os.getenv("DATABASE_URL")

def lambda_handler(event, context):
    global log_level
    log_level = str(LOG_LEVEL).upper()
    if log_level not in { 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL' }:
        log_level = 'ERROR'
    logging.getLogger().setLevel(log_level)

    agent = event['agent']
    actionGroup = event['actionGroup']
    function = event['function']
    parameters = event.get('parameters', [])

    try:
        logging.info("Reading file /tmp/vault_secret.json")
        with open("/tmp/vault_secret.json", "r") as f:
            secret = json.load(f)
            logging.info(secret)
    except Exception as e:
        logging.error("Error reading file: %s", str(e))

    try:
        conn = psycopg2.connect(
            dbname="lambdadb",
            user=secret["data"]["username"],
            password=secret["data"]["password"],
            host=DATABASE_URL,
        )
    except Exception as e:
        logging.error("Database connection error: %s", str(e))

    # try:
    #     with conn.cursor() as cursor:
    #         cursor.execute("SELECT usename FROM pg_catalog.pg_user")
    #         logging.info("Users:")
    #         logging.info(cursor.fetchall())
    # except Exception as e:
    #     logging.error("Error querying database: %s", str(e))

    for param in parameters:
        if param['name'] == 'city':
            city = param['value']

    food = f"No dish found for the city: {city.title()}"

    try:
        with conn.cursor() as cursor:
            cursor.execute(f"SELECT * FROM public.city_dishes WHERE city='{city.title()}';")
            food_raw = cursor.fetchall()
            food = food_raw[0][2]
    except Exception as e:
        logging.error("Error querying database: %s", str(e))

    logging.info(f'City: {city}. Food detected: {food}')

    responseBody =  {
        "TEXT": {
            "body": f"City: {city}. Food detected: {food}"
        }
    }

    action_response = {
        'actionGroup': actionGroup,
        'function': function,
        'functionResponse': {
            'responseBody': responseBody
        }

    }

    dummy_function_response = {'response': action_response, 'messageVersion': event['messageVersion']}
    logging.info(f"Response: {dummy_function_response}")

    return dummy_function_response
