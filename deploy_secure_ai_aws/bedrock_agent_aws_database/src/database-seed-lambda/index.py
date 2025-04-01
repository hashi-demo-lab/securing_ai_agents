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

    # create_table_sql = """
    # CREATE TABLE IF NOT EXISTS public.city_dishes (
    #     id SERIAL PRIMARY KEY,
    #     city VARCHAR(255) NOT NULL UNIQUE,
    #     dish VARCHAR(255) NOT NULL
    # )
    # """

    seed_data_sql = """
    INSERT INTO public.city_dishes (city, dish) VALUES
    ('New York', 'New York-style pizza'),
    ('Paris', 'Croissant'),
    ('Tokyo', 'Sushi'),
    ('Bangkok', 'Pad Thai'),
    ('Mumbai', 'Vada Pav'),
    ('Rome', 'Pasta Carbonara'),
    ('Istanbul', 'Kebap'),
    ('Beijing', 'Peking Duck'),
    ('Mexico City', 'Tacos al Pastor'),
    ('London', 'Fish and Chips')
    ON CONFLICT (city) DO NOTHING;
    """

    check_data_seeding_sql = """
    SELECT * FROM public.city_dishes;
    """

    try:
        with conn.cursor() as cursor:
            # cursor.execute(create_table_sql)
            cursor.execute(seed_data_sql)

        conn.commit()
    except Exception as e:
        logging.error("Error seeding database: %s", str(e))
        return {"statusCode": 500, "body": str(e)}

    try:
        with conn.cursor() as cursor:
            cursor.execute(check_data_seeding_sql)
            data = cursor.fetchall()
            print(data)
    except Exception as e:
        logging.error("Error seeding database: %s", str(e))
        return {"statusCode": 500, "body": str(e)}

    conn.close()

    return {"statusCode": 200, "body": "Table created and data seeded successfully."}
