-- Удаление базы данных
-- DROP DATABASE fitness_center_db;

-- Создание таблиц
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('клиент', 'тренер'))
);

CREATE TABLE trainers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(255) NOT NULL
);

CREATE TABLE trainings (
    id BIGSERIAL PRIMARY KEY,
    trainer_id BIGINT NOT NULL REFERENCES trainers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    capacity INT NOT NULL CHECK (capacity > 0),
    duration INT NOT NULL CHECK (duration > 0)
);

CREATE TABLE reservations (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    training_id BIGINT NOT NULL REFERENCES trainings(id) ON DELETE CASCADE,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('Подтверждено', 'Отменено'))
);

-- Вставка тестовых данных в users
WITH users_data AS (
    SELECT unnest(array['Анна', 'Олег', 'Мария', 'Сергей', 'Дмитрий']) AS name,
           unnest(array['anna@example.com', 'oleg@example.com', 'maria@example.com', 'sergey@example.com', 'dmitry@example.com']) AS email,
           unnest(array['+79110000001', '+79110000002', '+79110000003', '+79110000004', '+79110000005']) AS phone,
           unnest(array['клиент', 'тренер', 'клиент', 'тренер', 'клиент']) AS role
)
INSERT INTO users (name, email, phone, role)
SELECT name, email, phone, role FROM users_data;

-- Вставка тестовых данных в trainers
INSERT INTO trainers (user_id, specialty)
SELECT id, unnest(array['Фитнес', 'Йога']) FROM users WHERE role = 'тренер';

-- Вставка тестовых данных в trainings
WITH trainings_data AS (
    SELECT unnest(array['Кардио', 'Силовая тренировка', 'Йога для начинающих']) AS name,
           unnest(array['Тренировка для развития выносливости', 'Комплекс упражнений с отягощением', 'Расслабляющие упражнения']) AS description,
           unnest(array[10, 8, 12]) AS capacity,
           unnest(array[60, 45, 90]) AS duration
)
INSERT INTO trainings (trainer_id, name, description, capacity, duration)
SELECT (random() * 2 + 1)::int, name, description, capacity, duration FROM trainings_data;

-- Вставка тестовых данных в reservations
INSERT INTO reservations (user_id, training_id, reserved_at, status)
SELECT 
    (random() * 3 + 1)::int,
    (random() * 3 + 1)::int,
    NOW() - (trunc(random() * 5) || ' days')::interval,
    'Подтверждено';

-- Проверка
SELECT * FROM users;
SELECT * FROM trainers;
SELECT * FROM trainings;
SELECT * FROM reservations;
