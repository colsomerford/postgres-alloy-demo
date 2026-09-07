#!/bin/sh

docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE USER \"db-o11y\" WITH PASSWORD 'o11y_password';"
docker exec -i -e PGPASSWORD=o11y_password my-postgres psql -U db-o11y -d mydatabase -c "SELECT * FROM pg_stat_statements LIMIT 1;"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "ALTER ROLE \"db-o11y\" SET pg_stat_statements.track = 'none';"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_monitor TO \"db-o11y\";"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_read_all_stats TO \"db-o11y\";"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_read_all_data TO \"db-o11y\";"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE USER \"db-user\" WITH PASSWORD 'o11y_password';"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_read_all_data TO \"db-user\";"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_write_all_data TO \"db-user\";"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "INSERT INTO users (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE TABLE user_data (
    user_id INT NOT NULL,
    dob VARCHAR(100)
);"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "ALTER TABLE user_data ADD CONSTRAINT FK_User_Data_User_Id_Users_id FOREIGN KEY (user_id) REFERENCES users (id);"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "INSERT INTO user_data (user_id, dob) 
VALUES 
    (1, '2022-01-01'),
    (2, '2021-01-01'),
    (3, '2020-01-01');"