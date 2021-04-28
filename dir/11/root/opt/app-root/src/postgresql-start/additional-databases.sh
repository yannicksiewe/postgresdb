#!/usr/bin/env bash

set -euo pipefail

_psql () { psql --set ON_ERROR_STOP=1 "$@" ; }


for POSTGRESQL_DATABASE in $(echo "${POSTGRESQL_ADDITIONAL_DATABASES:-}" | tr ',' ' '); do
  # Use subshell to preserve external environment
  (
    echo "Setup additional database ${POSTGRESQL_DATABASE} ..."

    unset POSTGRESQL_ADMIN_PASSWORD
    unset POSTGRESQL_MASTER_USER
    unset POSTGRESQL_MASTER_PASSWORD

    if [ ${#POSTGRESQL_DATABASE} -gt 63 ]; then
      echo "Additional PostgreSQL database '${POSTGRESQL_DATABASE}' too long (maximum 63 characters)"
      exit 0
    fi

    POSTGRESQL_USER_VAR="POSTGRESQL_DATABASE_${POSTGRESQL_DATABASE}_USER"
    POSTGRESQL_PASSWORD_VAR="POSTGRESQL_DATABASE_${POSTGRESQL_DATABASE}_PASSWORD"

    if [ -z "${!POSTGRESQL_USER_VAR+x}" ]; then
      echo "Missing PostgreSQL username for additional databse '${POSTGRESQL_DATABASE}'."
      echo "Use '${POSTGRESQL_USER_VAR}' to define one."
      exit 1
    fi

    if [ -z "${!POSTGRESQL_PASSWORD_VAR+x}" ]; then
      echo "Missing PostgreSQL password for additional databse '${POSTGRESQL_DATABASE}'."
      echo "Use '${POSTGRESQL_PASSWORD_VAR}' to define one."
      exit 1
    fi

    POSTGRESQL_USER="${!POSTGRESQL_USER_VAR}"

    if [ ${#POSTGRESQL_USER} -gt 63 ]; then
      echo "PostgreSQL username too long (maximum 63 characters)"
    fi

    # shellcheck disable=SC2034
    POSTGRESQL_PASSWORD="${!POSTGRESQL_PASSWORD_VAR}"

    export postinitdb_actions=simple_db

    if ! _psql --set=username="${POSTGRESQL_USER}" -tA <<< "SELECT 1 FROM pg_roles WHERE rolname=:'username';" | grep -q 1; then
      echo "Creating additional database ${POSTGRESQL_DATABASE} ..."
      create_users

      # shellcheck source=/dev/null
      . "${CONTAINER_SCRIPTS_PATH}/start/set_passwords.sh"

      if [ -f "/docker-entrypoint-initdb.d/${POSTGRESQL_DATABASE}.sql" ]; then

        echo "Import init sql file for database ${POSTGRESQL_DATABASE} ..."
        PGPASSWORD="${POSTGRESQL_PASSWORD}" _psql --username "${POSTGRESQL_USER}" --dbname "${POSTGRESQL_DATABASE}" < "/docker-entrypoint-initdb.d/${POSTGRESQL_DATABASE}.sql"
      fi
    else
      # shellcheck source=/dev/null
      . "${CONTAINER_SCRIPTS_PATH}/start/set_passwords.sh"
    fi
  )
done
