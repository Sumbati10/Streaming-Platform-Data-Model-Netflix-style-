# Streaming Platform Data Model (Netflix-style)

## What is Data Modeling?

Data modeling is the process of designing how information will be stored in a database.
It turns business requirements (what the system must do) into:

- entities (things we store)
- attributes (details about each entity)
- relationships (how entities connect)
- rules/constraints (what is allowed)

The final output is usually a relational database schema (tables with primary keys and foreign keys).

## What is an ERD?

An **ERD (Entity Relationship Diagram)** is a diagram that visualizes the data model.
It shows:

- **Entities** (like `users`, `titles`, `subscriptions`)
- **Relationships** (like user has profiles, show has seasons)
- **Cardinality** (1-to-1, 1-to-many, many-to-many)

This project implements the ERD as SQL tables in MySQL.

## Contents

- `schema.sql`: MySQL 8+ DDL for the database structure (tables/PK/FK).
- `seed.sql`: Sample data (INSERT statements) to test the schema.

## Problem statement (what we built)

We designed a database for a streaming platform that:

- manages users and profiles
- stores movies and shows (including seasons and episodes)
- tracks subscriptions and plans
- records payments
- records watch history/progress

## Main entities and relationships

### Users and profiles

- `users (1) -> (many) profiles`

### Subscription and billing

- `plans (1) -> (many) subscriptions`
- `users (1) -> (many) subscriptions`
- `subscriptions (1) -> (many) payments`

### Content catalog

- `titles` stores shared data for all content.
- Movies use subtype table: `movies (1) -> (1) titles`
- Shows use subtype table: `shows (1) -> (1) titles`
- `shows (1) -> (many) seasons (1) -> (many) episodes`

### Genres

- Many-to-many between titles and genres via `title_genres`.

### Watch history

- `profiles (1) -> (many) watch_history`
- Each watch event references a `title` and may reference an `episode`.

## What this model covers

- Users + Profiles
- Titles (Movies + Shows)
- Seasons + Episodes
- Subscription Plans
- Subscriptions
- Payments
- Genres (many-to-many)
- Watch history / progress

## How to use (MySQL)

### If you are using Docker (recommended)

If port `3306` is busy on your machine, you can run MySQL on host port `3307`:

```bash
docker run --name streaming-mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=streaming_platform \
  -p 3307:3306 \
  -d mysql:8.0
```

Import the schema:

```bash
mysql -h 127.0.0.1 -P 3307 -u root -prootpass streaming_platform < schema.sql
```

Import sample data:

```bash
mysql -h 127.0.0.1 -P 3307 -u root -prootpass streaming_platform < seed.sql
```

Quick check:

```bash
mysql -h 127.0.0.1 -P 3307 -u root -prootpass -e "USE streaming_platform; SHOW TABLES;"
```

### Option A: Import from MySQL CLI

1. Create a database.
2. Run the SQL in `schema.sql`.

```sql
CREATE DATABASE streaming_platform;
USE streaming_platform;
SOURCE schema.sql;
```

### Option B: One-line import

```bash
mysql -u <user> -p -e "CREATE DATABASE IF NOT EXISTS streaming_platform;" && \
mysql -u <user> -p streaming_platform < schema.sql
```

## Example queries

### Continue watching (latest progress per profile)

```sql
SELECT wh.profile_id, wh.title_id, wh.episode_id, MAX(wh.watched_at) AS last_watch, MAX(wh.progress_seconds) AS progress
FROM watch_history wh
GROUP BY wh.profile_id, wh.title_id, wh.episode_id;
```

### Titles with their genres

```sql
SELECT t.title_name, GROUP_CONCAT(g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres
FROM titles t
JOIN title_genres tg ON tg.title_id = t.title_id
JOIN genres g ON g.genre_id = tg.genre_id
GROUP BY t.title_id;
```
