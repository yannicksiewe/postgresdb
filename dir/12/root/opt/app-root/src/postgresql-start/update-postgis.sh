#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="postgres"

# Perform action $POSTGRES_DB
export POSTGRES_DB="postgres"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# define psql function
_psql () { psql --set ON_ERROR_STOP=1 "$@"; }

# Load PostGIS into both template_database and $POSTGRES_DB
PGPASSWORD=password
for DB in template_postgis "$POSTGRES_DB" "${@}"; do
    echo "Updating PostGIS extensions '$DB' to $POSTGIS_VERSION"
    _psql --set=username="${PGUSER}" --dbname="$DB" -c "
        -- Upgrade PostGIS (includes raster)
        CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';
        -- Upgrade Topology
        CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';
        -- Install Tiger dependencies in case not already installed
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        -- Upgrade US Tiger Geocoder
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
    "
done