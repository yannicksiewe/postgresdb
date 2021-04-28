# postgres-db

## Description

Postgres container based on https://github.com/sclorg/postgresql-container but create multiple databases

# Environment

| Key | Description | Example |
|-----|-------------|---------|
| `POSTGRESQL_ADDITIONAL_DATABASES` | additional databases as comma separated list | `POSTGRESQL_ADDITIONAL_DATABASES=db` |
| `POSTGRESQL_DATABASE_<name>_USER` | username for database `<name>` | `POSTGRESQL_DATABASE_db_USER=dbuser` |
| `POSTGRESQL_DATABASE_<name>_PASSWORD` | password for database `<name>` | `POSTGRESQL_DATABASE_db_PASSWORD=dbpassword` |


## Initial DB seeding

If you need to seed your database, e.g. create schema, etc. just create a file called `/docker-entrypoint-initdb.d/${DATABASE_NAME}.sql`.

# Example
```bash
docker run -d --rm \
  -p 5432:5432
  -e POSTGRESQL_ADMIN_PASSWORD=password \
  -e POSTGRESQL_USER=defaultuser \
  -e POSTGRESQL_PASSWORD=defaultpassword \
  -e POSTGRESQL_DATABASE=defaultdb \
  -e POSTGRESQL_ADDITIONAL_DATABASES=db \
  -e POSTGRESQL_DATABASE_db_USER=dbuser \
  -e POSTGRESQL_DATABASE_db_PASSWORD=dbpassword \
  adorsys/postgres:10-scl
```