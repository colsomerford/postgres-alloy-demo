import os
import psycopg
from psycopg.rows import dict_row
import time
from faker import Faker

fake = Faker()

# Configuration: Update credentials or set them via environment variables
DB_HOST = os.getenv("DB_HOST", "my-postgres")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAMES = (os.getenv("DB_NAME", "mydatabase"), "cje_test_1", "cje_test_2", "cje_test_3")
DB_USER = os.getenv("DB_USER", "db-user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "o11y_password")
DATABASE_URL = os.getenv("DATABASE_URL")


def get_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, SQL):
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
            return conn.execute(SQL).fetchall()
            # query = "INSERT INTO Users(name, email) VALUES (%s, %s);"
            # conn.execute(query, (name, email))
        # return "success"
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
        # for i in range(1, count):
        #     name  = fake.name()
        #     email = fake.email()
        id = 123456
        dob = "2026-09-19"
        with psycopg.connect(conn_info) as conn:
            # return conn.execute("select * from users u join user_data d on u.id = d.user_id;").fetchall()
            query = "INSERT INTO schema2.user_data2(user_id, dob) VALUES (%s, %s);"
            conn.execute(query, (id, dob))
        print(f"Successfully inserted {count:,} records into PostgreSQL {DB_NAME}.")
    except psycopg.Error as e:
        print(f"Database error: {e}")
        return []
    


if __name__ == "__main__":
    SCHEMA = True
    SLEEP_FOR = 0.1
    count = 0
    while True:
        if count % 10 == 0:
            try:
                for DB_NAME in DB_NAMES:
                    generate_and_insert_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, 1000)
            except Exception as Ex:
                print(f"Database error: {Ex}")
        for DB_NAME in DB_NAMES:
            print(f"Fetching users from database {DB_NAME}...")
            match DB_NAME:
                case "mydatabase":
                    SQL = "select * from users1 u1 join user_data1 d1 on u1.id = d1.user_id;"
                    if SCHEMA:
                        SQL = "select * from schema1.users1 u1 join schema1.user_data1 d1 on u1.id = d1.user_id;"
                case "cje_test_1":
                    SQL = "select * from users2 u2 join user_data23 d2 on u2.id = d2.user_id;"
                    if SCHEMA:
                        SQL = "select * from schema2.users2 u2 join schema2.user_data2 d2 on u2.id = d2.user_id;"
                case "cje_test_2":
                    SQL = "select * from users3 u3 join user_data3 d3 on u3.id = d3.user_id;"
                    if SCHEMA:
                        SQL = "select * from schema3.users3 u3 join schema3.user_data3 d3 on u3.id = d3.user_id;"
                case "cje_test_3":
                    SQL = "select * from users4 u3 join user_data4 d4 on u4.id = d4.user_id;"
                    if SCHEMA:
                        SQL = "select * from schema4.users4 u4 join schema4.user_data4 d4 on u4.id = d4.user_id;"
            print(f"Executing SQL\n{SQL}...")    
            users = get_users(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, SQL)
            for user in users:
                print(user)
        time.sleep(SLEEP_FOR)
        count += 1