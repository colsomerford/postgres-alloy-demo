import os
import psycopg
from psycopg.rows import dict_row
import time
from faker import Faker

fake = Faker()

# Configuration: Update credentials or set them via environment variables
DB_HOST = os.getenv("DB_HOST", "192.168.10.197")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "mydatabase")
DB_USER = os.getenv("DB_USER", "db-user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "o11y_password")
DATABASE_URL = os.getenv("DATABASE_URL")

def generate_users(count: int = 10_000):
    users = []
    
    print(f"Generating {count:,} users...")
    start_time = time.perf_counter()
    
    for _ in range(count):
        user = {
            "name": fake.name(),
            "email": fake.email()
            # Or fake.unique.email() if you need guaranteed unique emails
        }
        users.append(user)
    
    elapsed = time.perf_counter() - start_time
    print(f"Generated {len(users):,} users in {elapsed:.2f} seconds.")
    return users


def get_users():
    """Connects to PostgreSQL and selects all rows from the users table."""
    conn_info = (
        f"host={DB_HOST} port={DB_PORT} dbname={DB_NAME} "
        f"user={DB_USER} password={DB_PASSWORD}"
    )

    try:
        # row_factory=dict_row returns records as dictionaries {column_name: value}
        # for i in range(1, 10000):
        name  = fake.name()
        email = fake.email()
        with psycopg.connect(conn_info) as conn:
            return conn.execute("select * from users u join user_data d on u.id = d.user_id;").fetchall()
            # query = "INSERT INTO Users(name, email) VALUES (%s, %s);"
            # conn.execute(query, (name, email))
        # return "success"
    except psycopg.Error as e:
        print(f"Database error: {e}")
        return []

def generate_and_insert_users(count: int = 10_000):
    """Connects to PostgreSQL and selects all rows from the users table."""
    conn_info = (
        f"host={DB_HOST} port={DB_PORT} dbname={DB_NAME} "
        f"user={DB_USER} password={DB_PASSWORD}"
    )

    try:
        # row_factory=dict_row returns records as dictionaries {column_name: value}
        for i in range(1, count):
            name  = fake.name()
            email = fake.email()
            with psycopg.connect(conn_info) as conn:
                # return conn.execute("select * from users u join user_data d on u.id = d.user_id;").fetchall()
                query = "INSERT INTO Users(name, email) VALUES (%s, %s);"
                conn.execute(query, (name, email))
        print(f"Successfully inserted {count:,} records into PostgreSQL.")
    except psycopg.Error as e:
        print(f"Database error: {e}")
        return []
    


if __name__ == "__main__":
    try:
        generate_and_insert_users(1000)
    except Exception as Ex:
        print(f"Database error: {Ex}")
    while True:
        print("Fetching users from database...")
        users = get_users()
        for user in users:
            print(user)
        time.sleep(1)