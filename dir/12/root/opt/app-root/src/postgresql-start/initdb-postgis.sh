#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="postgres"

# Perform action $POSTGRES_DB
export POSTGRES_DB="$POSTGRESQL_DATABASE"

# define psql function
_psql () { psql --set ON_ERROR_STOP=1 "$@"; }

# Create the 'template_postgis' template db
PGPASSWORD=password
_psql -U ${PGUSER} -c "CREATE DATABASE template_postgis IS_TEMPLATE true"

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	_psql --set=username="${PGUSER}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done