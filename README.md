# Postgres Docker Compose

To setup run the following command:
```
docker compose -f docker-compose-alloy.yaml up -d
```

To access the SQL shell run the following:
```
docker exec -it my-postgres psql -U postgres -d mydatabase
```

Example command to create a table:
```
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');

SELECT * FROM users;
```

## Setting up Postgres for Alloy

To give the alloy the information it needs to connect to fleet management and write telemetry create a .env file in the root directory and create the following variables:
```
FM_URL=
FM_USERNAME=
GCLOUD_RW_API_KEY=
DB_POSTGRES_DSN=postgresql://db-o11y:o11y_password@my-postgres:5432/mydatabase?sslmode=disable  
GCLOUD_HOSTED_METRICS_URL=
GCLOUD_HOSTED_METRICS_ID=
GCLOUD_HOSTED_LOGS_URL=
GCLOUD_HOSTED_LOGS_ID=
GCLOUD_HOSTED_OTLP_ENDPOINT=
GCLOUD_HOSTED_OTLP_INSTANCE_ID=

```

## Setting up Postgres for DB Observability

In alloy/alloy-postgres.conf several required settings have been configured.

Run the following commands:
```
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "CREATE USER \"db-o11y\" WITH PASSWORD 'o11y_password';GRANT pg_monitor TO \"db-o11y\";GRANT pg_read_all_stats TO \"db-o11y\";"
docker exec -i -e PGPASSWORD=o11y_password my-postgres psql -U db-o11y -d mydatabase -c "SELECT * FROM pg_stat_statements LIMIT 1;"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "ALTER ROLE \"db-o11y\" SET pg_stat_statements.track = 'none';"
docker exec -i -e PGPASSWORD=password my-postgres psql -U postgres -d mydatabase -c "GRANT pg_read_all_data TO \"db-o11y\";"
```

Go into DB o11y in Grafana and add a database via fleet management.
The DSN environment variable is called DB_POSTGRES_DSN.

## Troubleshooting and Stopping

To get logs from the docker run the following:
```
docker logs -f my-postgres
```

To stop the setup and delete voluemes run the following:
```
docker compose -f docker-compose-alloy.yaml down -v
```
