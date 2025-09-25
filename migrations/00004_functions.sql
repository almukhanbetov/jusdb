-- +goose Up
---------------------------------------------------
-- 🔹 Совпадения для объявлений
---------------------------------------------------
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION check_matches_for_listing()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO matches (listing_id, request_id, status, created_at)
    SELECT NEW.id, br.id, 'open', now()
    FROM buy_requests br
    WHERE (br.city_id = NEW.city_id OR br.city_id IS NULL)
      AND (br.district_id = NEW.district_id OR br.district_id IS NULL)
      AND (br.type_id = NEW.type_id OR br.type_id IS NULL)
      AND (NEW.area BETWEEN COALESCE(br.area_min, 0) AND COALESCE(br.area_max, NEW.area))
      AND (NEW.rooms BETWEEN COALESCE(br.rooms_min, 0) AND COALESCE(br.rooms_max, NEW.rooms))
      AND (NEW.price_current <= br.budget_current)
      AND NOT EXISTS (
          SELECT 1 FROM matches m
          WHERE m.listing_id = NEW.id
            AND m.request_id = br.id
      );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_check_matches_for_listing
AFTER INSERT ON listings
FOR EACH ROW
EXECUTE FUNCTION check_matches_for_listing();
---------------------------------------------------
-- 🔹 Совпадения для заявок
---------------------------------------------------
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION check_matches_for_request()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO matches (listing_id, request_id, status, created_at)
    SELECT l.id, NEW.id, 'open', now()
    FROM listings l
    WHERE (l.city_id = NEW.city_id OR NEW.city_id IS NULL)
      AND (l.district_id = NEW.district_id OR NEW.district_id IS NULL)
      AND (l.type_id = NEW.type_id OR NEW.type_id IS NULL)
      AND (l.area BETWEEN COALESCE(NEW.area_min, l.area) AND COALESCE(NEW.area_max, l.area))
      AND (l.rooms BETWEEN COALESCE(NEW.rooms_min, l.rooms) AND COALESCE(NEW.rooms_max, l.rooms))
      AND (l.price_current <= NEW.budget_current)
      AND NOT EXISTS (
          SELECT 1 FROM matches m
          WHERE m.listing_id = l.id
            AND m.request_id = NEW.id
      );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_check_matches_for_request
AFTER INSERT ON buy_requests
FOR EACH ROW
EXECUTE FUNCTION check_matches_for_request();

---------------------------------------------------
-- 🔹 Уведомления при совпадении
---------------------------------------------------
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION notify_on_match()
RETURNS TRIGGER AS $$
DECLARE
    seller_id BIGINT;
    buyer_id BIGINT;
    listing_desc TEXT;
BEGIN
    SELECT l.user_id, l.description
    INTO seller_id, listing_desc
    FROM listings l
    WHERE l.id = NEW.listing_id;

    SELECT br.user_id
    INTO buyer_id
    FROM buy_requests br
    WHERE br.id = NEW.request_id;

    INSERT INTO notifications (user_id, message, created_at)
    VALUES (
        seller_id,
        '🔔 Ваш объект "' || listing_desc || '" совпал с запросом покупателя!',
        now()
    );

    INSERT INTO notifications (user_id, message, created_at)
    VALUES (
        buyer_id,
        '✅ Найдено совпадение по вашему запросу. Объект: "' || listing_desc || '"',
        now()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_notify_on_match
AFTER INSERT ON matches
FOR EACH ROW
EXECUTE FUNCTION notify_on_match();

-- +goose Down
DROP TRIGGER IF EXISTS trg_notify_on_match ON matches;
DROP TRIGGER IF EXISTS trg_check_matches_for_request ON buy_requests;
DROP TRIGGER IF EXISTS trg_check_matches_for_listing ON listings;

-- +goose StatementBegin
DROP FUNCTION IF EXISTS notify_on_match();
DROP FUNCTION IF EXISTS check_matches_for_request();
DROP FUNCTION IF EXISTS check_matches_for_listing();
-- +goose StatementEnd
