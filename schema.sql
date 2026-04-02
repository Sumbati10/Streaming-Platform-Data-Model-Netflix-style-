-- Streaming Platform Data Model (Netflix-style)
-- MySQL 8+ compatible DDL

-- =========================
-- 1) USERS + PROFILES
-- =========================

CREATE TABLE users (
  user_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
  email          VARCHAR(255) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  status         VARCHAR(30)  NOT NULL DEFAULT 'ACTIVE',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE profiles (
  profile_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT NOT NULL,
  profile_name   VARCHAR(80) NOT NULL,
  is_kids        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_profiles_user_name UNIQUE (user_id, profile_name)
);

-- =========================
-- 2) PLANS + SUBSCRIPTIONS + PAYMENTS
-- =========================

CREATE TABLE plans (
  plan_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
  plan_name      VARCHAR(50) NOT NULL,
  monthly_price  DECIMAL(10,2) NOT NULL,
  max_screens    INT NOT NULL,
  video_quality  VARCHAR(30) NOT NULL,
  CONSTRAINT uq_plans_name UNIQUE (plan_name)
);

CREATE TABLE subscriptions (
  subscription_id  BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id          BIGINT NOT NULL,
  plan_id          BIGINT NOT NULL,
  start_date       DATE NOT NULL,
  end_date         DATE NULL,
  status           VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT fk_subscriptions_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_subscriptions_plan
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan_id);

CREATE TABLE payments (
  payment_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
  subscription_id  BIGINT NOT NULL,
  amount           DECIMAL(10,2) NOT NULL,
  payment_date     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  payment_method   VARCHAR(40) NOT NULL,
  provider_ref     VARCHAR(100) NULL,
  status           VARCHAR(30) NOT NULL DEFAULT 'PAID',
  CONSTRAINT fk_payments_subscription
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
    ON DELETE CASCADE
);

CREATE INDEX idx_payments_subscription ON payments(subscription_id);

-- =========================
-- 3) CONTENT CATALOG
-- =========================

CREATE TABLE titles (
  title_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  title_name        VARCHAR(255) NOT NULL,
  content_type      VARCHAR(10) NOT NULL,
  description       TEXT NULL,
  release_year      INT NULL,
  maturity_rating   VARCHAR(20) NULL,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_titles_content_type CHECK (content_type IN ('MOVIE','SHOW'))
);

CREATE INDEX idx_titles_type ON titles(content_type);
CREATE INDEX idx_titles_name ON titles(title_name);

CREATE TABLE movies (
  title_id          BIGINT PRIMARY KEY,
  duration_minutes  INT NOT NULL,
  CONSTRAINT fk_movies_title
    FOREIGN KEY (title_id) REFERENCES titles(title_id)
    ON DELETE CASCADE
);

CREATE TABLE shows (
  title_id          BIGINT PRIMARY KEY,
  CONSTRAINT fk_shows_title
    FOREIGN KEY (title_id) REFERENCES titles(title_id)
    ON DELETE CASCADE
);

CREATE TABLE seasons (
  season_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
  show_title_id   BIGINT NOT NULL,
  season_number   INT NOT NULL,
  CONSTRAINT fk_seasons_show
    FOREIGN KEY (show_title_id) REFERENCES shows(title_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_seasons_show_number UNIQUE (show_title_id, season_number)
);

CREATE INDEX idx_seasons_show ON seasons(show_title_id);

CREATE TABLE episodes (
  episode_id        BIGINT PRIMARY KEY AUTO_INCREMENT,
  season_id         BIGINT NOT NULL,
  episode_number    INT NOT NULL,
  episode_title     VARCHAR(255) NOT NULL,
  duration_minutes  INT NOT NULL,
  CONSTRAINT fk_episodes_season
    FOREIGN KEY (season_id) REFERENCES seasons(season_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_episodes_season_number UNIQUE (season_id, episode_number)
);

CREATE INDEX idx_episodes_season ON episodes(season_id);

-- =========================
-- 4) GENRES (M:N)
-- =========================

CREATE TABLE genres (
  genre_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
  genre_name   VARCHAR(60) NOT NULL,
  CONSTRAINT uq_genres_name UNIQUE (genre_name)
);

CREATE TABLE title_genres (
  title_id   BIGINT NOT NULL,
  genre_id   BIGINT NOT NULL,
  PRIMARY KEY (title_id, genre_id),
  CONSTRAINT fk_title_genres_title
    FOREIGN KEY (title_id) REFERENCES titles(title_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_title_genres_genre
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
    ON DELETE CASCADE
);

-- =========================
-- 5) WATCH HISTORY / PROGRESS
-- =========================

CREATE TABLE watch_history (
  watch_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
  profile_id        BIGINT NOT NULL,
  title_id          BIGINT NOT NULL,
  episode_id        BIGINT NULL,
  watched_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  seconds_watched   INT NOT NULL DEFAULT 0,
  progress_seconds  INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_watch_profile
    FOREIGN KEY (profile_id) REFERENCES profiles(profile_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_watch_title
    FOREIGN KEY (title_id) REFERENCES titles(title_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_watch_episode
    FOREIGN KEY (episode_id) REFERENCES episodes(episode_id)
    ON DELETE SET NULL
);

CREATE INDEX idx_watch_profile_time ON watch_history(profile_id, watched_at);
CREATE INDEX idx_watch_title ON watch_history(title_id);
