-- +goose Up
-- Демо-данные

INSERT INTO roles (name) VALUES 
    ('buyer'),
    ('seller'),
    ('admin')
ON CONFLICT DO NOTHING;

INSERT INTO cities (name) VALUES 
    ('Алматы'),
    ('Астана'),
    ('Шымкент')
ON CONFLICT DO NOTHING;

INSERT INTO districts (city_id, name) VALUES
    (1, 'Бостандыкский'),
    (1, 'Алмалинский'),
    (2, 'Есильский'),
    (2, 'Сарыаркинский'),
    (3, 'Абайский')
ON CONFLICT DO NOTHING;

INSERT INTO types (name) VALUES
    ('Квартира'),
    ('Дом'),
    ('Участок'),
    ('Коммерческая недвижимость')
ON CONFLICT DO NOTHING;

INSERT INTO users (phone, password_hash, name, email, verified, role_id)
VALUES ('+77010000001', 'hash123', 'Тестовый Продавец', 'seller@test.kz', true, 2)
ON CONFLICT DO NOTHING;

INSERT INTO users (phone, password_hash, name, email, verified, role_id)
VALUES ('+77010000002', 'hash456', 'Тестовый Покупатель', 'buyer@test.kz', true, 1)
ON CONFLICT DO NOTHING;

INSERT INTO listings (user_id, city_id, district_id, type_id, area, rooms, price_current, price_base, description, moderation)
VALUES (1, 1, 1, 1, 60, 2, 25000000, 26000000, '2-комнатная квартира в центре Алматы', 'approved')
ON CONFLICT DO NOTHING;

INSERT INTO photos (listing_id, url)
VALUES (1, 'https://example.com/photo1.jpg')
ON CONFLICT DO NOTHING;

INSERT INTO buy_requests (user_id, city_id, district_id, type_id, area_min, area_max, rooms_min, rooms_max, budget_current, budget_base, description)
VALUES (2, 1, 1, 1, 50, 70, 2, 3, 26000000, 27000000, 'Ищу квартиру в Алматы, 2-3 комнаты, Бостандыкский район')
ON CONFLICT DO NOTHING;

INSERT INTO matches (listing_id, request_id, status)
VALUES (1, 1, 'open')
ON CONFLICT DO NOTHING;

INSERT INTO deposits (match_id, user_id, amount, status)
VALUES (1, 2, 1000000, 'held')
ON CONFLICT DO NOTHING;

INSERT INTO notifications (user_id, message)
VALUES (1, 'Ваш объект совпал с заявкой покупателя!'),
       (2, 'Найдено совпадение по вашему запросу!')
ON CONFLICT DO NOTHING;

-- +goose Down
TRUNCATE notifications RESTART IDENTITY CASCADE;
TRUNCATE deposits RESTART IDENTITY CASCADE;
TRUNCATE matches RESTART IDENTITY CASCADE;
TRUNCATE buy_requests RESTART IDENTITY CASCADE;
TRUNCATE photos RESTART IDENTITY CASCADE;
TRUNCATE listings RESTART IDENTITY CASCADE;
TRUNCATE users RESTART IDENTITY CASCADE;
TRUNCATE types RESTART IDENTITY CASCADE;
TRUNCATE districts RESTART IDENTITY CASCADE;
TRUNCATE cities RESTART IDENTITY CASCADE;
TRUNCATE roles RESTART IDENTITY CASCADE;
