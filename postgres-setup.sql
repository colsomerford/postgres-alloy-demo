CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE USER "db-o11y" WITH PASSWORD 'o11y_password';
SELECT * FROM pg_stat_statements LIMIT 1;
ALTER ROLE "db-o11y" SET pg_stat_statements.track = 'none';
GRANT pg_monitor TO "db-o11y";
GRANT pg_read_all_stats TO "db-o11y";
GRANT pg_read_all_data TO "db-o11y";

-- -- Ensure table-level permissions for EXPLAIN queries
-- GRANT USAGE ON SCHEMA public TO "db-o11y";
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO "db-o11y";
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "db-o11y";

CREATE USER "db-user" WITH PASSWORD 'o11y_password';
GRANT pg_read_all_data TO "db-user";
GRANT pg_write_all_data TO "db-user";
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');
CREATE TABLE user_data (
    user_id INT NOT NULL,
    dob VARCHAR(100)
);
ALTER TABLE user_data ADD CONSTRAINT FK_User_Data_User_Id_Users_id FOREIGN KEY (user_id) REFERENCES users (id);
INSERT INTO user_data (user_id, dob) 
VALUES 
    (1, '2022-01-01'),
    (2, '2021-01-01'),
    (3, '2020-01-01');