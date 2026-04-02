-- Sample seed data for Streaming Platform Data Model
-- Assumes schema.sql has already been applied to database `streaming_platform`

START TRANSACTION;

-- Clean (optional) - keeps re-runs easier
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE watch_history;
TRUNCATE TABLE title_genres;
TRUNCATE TABLE genres;
TRUNCATE TABLE payments;
TRUNCATE TABLE subscriptions;
TRUNCATE TABLE episodes;
TRUNCATE TABLE seasons;
TRUNCATE TABLE shows;
TRUNCATE TABLE movies;
TRUNCATE TABLE titles;
TRUNCATE TABLE profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE plans;
SET FOREIGN_KEY_CHECKS = 1;

-- Plans
INSERT INTO plans (plan_name, monthly_price, max_screens, video_quality)
VALUES
  ('Basic', 7.99, 1, 'HD'),
  ('Standard', 10.99, 2, 'Full HD'),
  ('Premium', 13.99, 4, '4K');

-- Users
INSERT INTO users (email, password_hash, status)
VALUES
  ('linda@example.com', 'hash_linda', 'ACTIVE'),
  ('adam@example.com', 'hash_adam', 'ACTIVE');

-- Profiles
INSERT INTO profiles (user_id, profile_name, is_kids)
VALUES
  (1, 'Linda', FALSE),
  (1, 'Kids', TRUE),
  (2, 'Adam', FALSE);

-- Titles
INSERT INTO titles (title_name, content_type, description, release_year, maturity_rating)
VALUES
  ('The Data Heist', 'MOVIE', 'A thriller about stealing datasets.', 2024, 'PG-13'),
  ('Normalization Wars', 'SHOW', 'A series about schemas and constraints.', 2023, 'TV-14'),
  ('ERD Academy', 'SHOW', 'Learning ERDs one relationship at a time.', 2022, 'TV-PG');

-- Movies
INSERT INTO movies (title_id, duration_minutes)
VALUES
  (1, 118);

-- Shows
INSERT INTO shows (title_id)
VALUES
  (2),
  (3);

-- Seasons
INSERT INTO seasons (show_title_id, season_number)
VALUES
  (2, 1),
  (2, 2),
  (3, 1);

-- Episodes
INSERT INTO episodes (season_id, episode_number, episode_title, duration_minutes)
VALUES
  (1, 1, 'Pilot: First Normal Form', 42),
  (1, 2, 'Partial Dependencies', 45),
  (2, 1, 'Join Table Rising', 44),
  (2, 2, 'BCNF Finale', 48),
  (3, 1, 'Entities vs Attributes', 39),
  (3, 2, 'Cardinality Basics', 41);

-- Genres
INSERT INTO genres (genre_name)
VALUES
  ('Thriller'),
  ('Drama'),
  ('Education'),
  ('Tech');

-- Title Genres
INSERT INTO title_genres (title_id, genre_id)
VALUES
  (1, 1),
  (1, 4),
  (2, 2),
  (2, 4),
  (3, 3),
  (3, 4);

-- Subscriptions
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
  (1, 3, '2026-03-01', NULL, 'ACTIVE'),
  (2, 1, '2026-03-15', NULL, 'ACTIVE');

-- Payments
INSERT INTO payments (subscription_id, amount, payment_date, payment_method, provider_ref, status)
VALUES
  (1, 13.99, '2026-04-01 10:00:00', 'CARD', 'TXN-10001', 'PAID'),
  (2, 7.99,  '2026-04-01 11:00:00', 'CARD', 'TXN-10002', 'PAID');

-- Watch History
-- profile_id: 1=Linda, 2=Kids, 3=Adam
-- title_id: 1=Movie, 2/3=Shows
INSERT INTO watch_history (profile_id, title_id, episode_id, watched_at, seconds_watched, progress_seconds)
VALUES
  (1, 1, NULL, '2026-04-02 20:10:00', 1800, 1800),
  (1, 2, 1,    '2026-04-02 20:50:00', 1200, 1200),
  (2, 3, 5,    '2026-04-02 18:20:00', 900,  900),
  (3, 2, 3,    '2026-04-02 19:05:00', 600,  600);

COMMIT;
