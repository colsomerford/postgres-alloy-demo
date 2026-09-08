import os
import psycopg
from psycopg.rows import dict_row
import time
from faker import Faker

fake = Faker()

# Configuration: Update credentials or set them via environment variables
DB_HOST = os.getenv("DB_HOST", "my-postgres")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAMES = (os.getenv("DB_NAME", "mydatabase"), "cje_test_1", "cje_test_2")
DB_USER = os.getenv("DB_USER", "db-user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "o11y_password")
DATABASE_URL = os.getenv("DATABASE_URL")
SLEEP_FOR = 1


def get_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD):
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
            return conn.execute("select * from schema1.users1 u join schema1.user_data1 d on u.id = d.user_id;").fetchall()
            # query = "INSERT INTO Users(name, email) VALUES (%s, %s);"
            # conn.execute(query, (name, email))
        # return "success"
    except psycopg.Error as e:
        try:
            with psycopg.connect(conn_info) as conn:
                return conn.execute("select * from schema2.users2 u join schema2.user_data2 d on u.id = d.user_id;").fetchall()
        except psycopg.Error as e:
            try:
                with psycopg.connect(conn_info) as conn:
                    return conn.execute("select * from schema3.users3 u join schema3.user_data3 d on u.id = d.user_id;").fetchall()
            except psycopg.Error as e:
                print(f"Database error: {e}")
                return []

def generate_and_insert_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, count: int = 10_000):
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
                query = "INSERT INTO users1(name, email) VALUES (%s, %s);"
                conn.execute(query, (name, email))
        print(f"Successfully inserted {count:,} records into PostgreSQL.")
    except psycopg.Error as e:
        print(f"Database error: {e}")
        return []
    


if __name__ == "__main__":
    try:
        for DB_NAME in DB_NAMES:
            generate_and_insert_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, 1000)
    except Exception as Ex:
        print(f"Database error: {Ex}")
    while True:
        for DB_NAME in DB_NAMES:
            print(f"Fetching users from database {DB_NAME}...")
            users = get_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
            for user in users:
                print(user)
            time.sleep(SLEEP_FOR)