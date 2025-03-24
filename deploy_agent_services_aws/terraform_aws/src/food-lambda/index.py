import logging
import os

LOG_LEVEL = os.getenv('LOG_LEVEL')

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

    for param in parameters:
        if param['name'] == 'city':
            city = param['value']

    city_to_dish = {
        "new york": "New York-style pizza",
        "paris": "Croissant",
        "tokyo": "Sushi",
        "bangkok": "Pad Thai",
        "mumbai": "Vada Pav",
        "rome": "Pasta Carbonara",
        "istanbul": "Kebap",
        "beijing": "Peking Duck",
        "mexico city": "Tacos al Pastor",
        "london": "Fish and Chips"
    }

    food = city_to_dish.get(city.lower(), f"No dish found for the city: {city.title()}")

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
