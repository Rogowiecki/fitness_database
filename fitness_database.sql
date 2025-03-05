-- Удаление базы данных 
-- DROP DATABASE fitness_center_db;

-- Создание таблиц
CREATE TABLE IF NOT EXISTS trainers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50),
    specialization VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    trainer_id INT REFERENCES trainers(id)
);

CREATE TABLE IF NOT EXISTS memberships (
    id SERIAL PRIMARY KEY,
    membership_name VARCHAR(50),
    price NUMERIC(7,2),
    duration_days INT
);

CREATE TABLE IF NOT EXISTS visits (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    visit_date TIMESTAMP
);

-- Очистка таблиц перед вставкой тестовых данных
TRUNCATE TABLE visits RESTART IDENTITY CASCADE;
TRUNCATE TABLE clients RESTART IDENTITY CASCADE;
TRUNCATE TABLE memberships RESTART IDENTITY CASCADE;
TRUNCATE TABLE trainers RESTART IDENTITY CASCADE;

-- Вставка тестовых данных в тренеров
INSERT INTO trainers (full_name, specialization)
SELECT
    trainer_name,
    specialization
FROM (
    SELECT unnest(array['Sergey Ivanov', 'Alexey Petrov', 'Dmitry Sidorov', 'Nikolay Smirnov', 'Andrey Fedorov']) AS trainer_name,
           unnest(array['Yoga', 'Boxing', 'Crossfit', 'Pilates', 'Bodybuilding']) AS specialization
) AS trainer_data;

-- Список имен и фамилий для случайной генерации клиентов
WITH name_data AS (
    SELECT 
        unnest(array['Anna', 'Maria', 'Elena', 'Olga', 'Natalia', 'Irina', 'Tatiana', 'Yulia', 'Victoria', 'Daria']) AS first_name,
        unnest(array['Ivanova', 'Petrova', 'Sidorova', 'Kozlova', 'Smirnova', 'Volkova', 'Lebedeva', 'Fedorova', 'Makarova', 'Orlova']) AS last_name
)
-- Вставка тестовых данных в клиентов
INSERT INTO clients (full_name, phone, email, trainer_id)
SELECT
    first_name || ' ' || last_name,
    '+7' || trunc(9000000000 + random() * 100000000)::bigint,
    lower(first_name) || trunc(random() * 100)::int || '@fitness.com',
    trunc(random() * 5 + 1)::int  -- случайный тренер от 1 до 5
FROM name_data
ORDER BY random()
LIMIT 10;

-- Вставка тестовых данных в абонементы
INSERT INTO memberships (membership_name, price, duration_days)
SELECT
    membership,
    round((1500 + random() * 5000)::numeric, 2),
    duration
FROM (
    SELECT unnest(array['Basic', 'Standard', 'Premium', 'VIP']) AS membership,
           unnest(array[30, 60, 90, 180]) AS duration
) AS membership_data;

-- Вставка тестовых данных в посещения
INSERT INTO visits (client_id, visit_date)
SELECT
    trunc(random() * 10 + 1)::int,
    NOW() - (trunc(random() * 60) || ' days')::interval
FROM generate_series(1, 30);

-- Проверка
SELECT * FROM clients;
