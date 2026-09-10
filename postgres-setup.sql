CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE USER "db-o11y" WITH PASSWORD 'o11y_password';
SELECT * FROM pg_stat_statements LIMIT 1;
ALTER ROLE "db-o11y" SET pg_stat_statements.track = 'none';
GRANT pg_monitor TO "db-o11y";
GRANT pg_read_all_stats TO "db-o11y";
GRANT pg_read_all_data TO "db-o11y";

CREATE USER "db-user" WITH PASSWORD 'o11y_password';
GRANT pg_read_all_data TO "db-user";
GRANT pg_write_all_data TO "db-user";

-- Setup mydatabase
CREATE DATABASE mydatabase;
\connect mydatabase
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE SCHEMA schema1;
ALTER ROLE "db-o11y" IN DATABASE mydatabase SET search_path TO schema1, public;

CREATE TABLE schema1.users1 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO schema1.users1 (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');

CREATE TABLE schema1.user_data1 (
    user_id INT NOT NULL,
    dob VARCHAR(100)
);
ALTER TABLE schema1.user_data1 ADD CONSTRAINT FK_User_Data_User_Id_Users_id FOREIGN KEY (user_id) REFERENCES schema1.users1 (id);
INSERT INTO schema1.user_data1 (user_id, dob) 
VALUES 
    (1, '2022-01-01'),
    (2, '2021-01-01'),
    (3, '2020-01-01');

-- Setup cje_test_1
CREATE DATABASE cje_test_1;
\connect cje_test_1
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE SCHEMA schema2;
ALTER ROLE "db-o11y" IN DATABASE cje_test_1 SET search_path TO schema2, public;

CREATE TABLE schema2.users2 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO schema2.users2 (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');

CREATE TABLE schema2.user_data2 (
    user_id INT NOT NULL,
    dob VARCHAR(100)
);
ALTER TABLE schema2.user_data2 ADD CONSTRAINT FK_User_Data_User_Id_Users_id FOREIGN KEY (user_id) REFERENCES schema2.users2 (id);
INSERT INTO schema2.user_data2 (user_id, dob) 
VALUES 
    (1, '2022-01-01'),
    (2, '2021-01-01'),
    (3, '2020-01-01');

-- Setup cje_test_2
CREATE DATABASE cje_test_2;
\connect cje_test_2
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE SCHEMA schema3;
ALTER ROLE "db-o11y" IN DATABASE cje_test_2 SET search_path TO schema3, public;

CREATE TABLE schema3.users3 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO schema3.users3 (name, email) 
VALUES 
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');

CREATE TABLE schema3.user_data3 (
    user_id INT NOT NULL,
    dob VARCHAR(100)
);
ALTER TABLE schema3.user_data3 ADD CONSTRAINT FK_User_Data_User_Id_Users_id FOREIGN KEY (user_id) REFERENCES schema3.users3 (id);
INSERT INTO schema3.user_data3 (user_id, dob) 
VALUES 
    (1, '2022-01-01'),
    (2, '2021-01-01'),
    (3, '2020-01-01');
ALTER ROLE "db-user" IN DATABASE mydatabase SET search_path TO schema1, public;
ALTER ROLE "db-user" IN DATABASE cje_test_1 SET search_path TO schema2, public;
ALTER ROLE "db-user" IN DATABASE cje_test_2 SET search_path TO schema3, public;