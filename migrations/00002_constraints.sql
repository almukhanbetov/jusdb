-- +goose Up
-- Индексы и уникальные ограничения

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
