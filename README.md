# Streaming Platform Data Model (Netflix-style)

## Contents

- `schema.sql`: MySQL 8+ DDL for a Netflix-style streaming platform database.

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
