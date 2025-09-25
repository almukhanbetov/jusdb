-- +goose Up
-- Создание ролей
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
-- Пользователи
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    phone TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    verified BOOLEAN NOT NULL DEFAULT false,
    role_id BIGINT REFERENCES roles(id),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Города
CREATE TABLE IF NOT EXISTS cities (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Районы
CREATE TABLE IF NOT EXISTS districts (
    id BIGSERIAL PRIMARY KEY,
    city_id BIGINT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(city_id, name)
);
-- Типы недвижимости
CREATE TABLE IF NOT EXISTS types (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Объявления
CREATE TABLE IF NOT EXISTS listings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    city_id BIGINT REFERENCES cities(id) ON DELETE SET NULL,
    district_id BIGINT REFERENCES districts(id) ON DELETE SET NULL,
    type_id BIGINT REFERENCES types(id) ON DELETE SET NULL,
    area DOUBLE PRECISION NOT NULL,
    rooms INT NOT NULL,
    price_current DOUBLE PRECISION NOT NULL,
    price_base DOUBLE PRECISION NOT NULL,
    description TEXT NOT NULL,
    moderation TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Фото объявлений
CREATE TABLE IF NOT EXISTS photos (
    id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Заявки покупателей
CREATE TABLE IF NOT EXISTS buy_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    city_id BIGINT REFERENCES cities(id) ON DELETE SET NULL,
    district_id BIGINT REFERENCES districts(id) ON DELETE SET NULL,
    type_id BIGINT REFERENCES types(id) ON DELETE SET NULL,
    area_min DOUBLE PRECISION,
    area_max DOUBLE PRECISION,
    rooms_min INT,
    rooms_max INT,
    budget_current DOUBLE PRECISION NOT NULL,
    budget_base DOUBLE PRECISION NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Совпадения
CREATE TABLE IF NOT EXISTS matches (
    id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    request_id BIGINT NOT NULL REFERENCES buy_requests(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'open',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(listing_id, request_id)
);

-- Депозиты
CREATE TABLE IF NOT EXISTS deposits (
    id BIGSERIAL PRIMARY KEY,
    match_id BIGINT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DOUBLE PRECISION NOT NULL,
    status TEXT NOT NULL DEFAULT 'held',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(match_id, user_id)
);

-- Уведомления
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_listings_city ON listings(city_id);
CREATE INDEX IF NOT EXISTS idx_listings_price ON listings(price_current);
CREATE INDEX IF NOT EXISTS idx_listings_rooms ON listings(rooms);
CREATE INDEX IF NOT EXISTS idx_buy_requests_city ON buy_requests(city_id);
CREATE INDEX IF NOT EXISTS idx_buy_requests_budget ON buy_requests(budget_current);

CREATE UNIQUE INDEX IF NOT EXISTS unique_listing_user_description_idx
    ON listings(user_id, description);

-- +goose Down
DROP INDEX IF EXISTS unique_listing_user_description_idx;
DROP INDEX IF EXISTS idx_buy_requests_budget;
DROP INDEX IF EXISTS idx_buy_requests_city;
DROP INDEX IF EXISTS idx_listings_rooms;
DROP INDEX IF EXISTS idx_listings_price;
DROP INDEX IF EXISTS idx_listings_city;

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS deposits;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS buy_requests;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS listings;
DROP TABLE IF EXISTS types;
DROP TABLE IF EXISTS districts;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;
