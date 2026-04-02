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

1. Create a database.
2. Run the SQL in `schema.sql`.

Example:

```sql
CREATE DATABASE streaming_platform;
USE streaming_platform;
SOURCE schema.sql;
```
