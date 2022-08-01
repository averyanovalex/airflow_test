#!/usr/bin/env bash

TRY_LOOP="20"

# Global defaults and back-compat
: "${AIRFLOW_HOME:="/usr/local/airflow"}"
: "${AIRFLOW__CORE__LOAD_EXAMPLES:="False"}"

#Global AIRFLOW мфкы
export \
  AIRFLOW_HOME \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \


wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

# Global PG vars
export \
  POSTGRES_HOST \
  POSTGRES_PORT \
  POSTGRES_USER \
  POSTGRES_PASSWORD \
  POSTGRES_DB \
  POSTGRES_EXTRAS \

# PG connection
AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}${POSTGRES_EXTRAS}"
export AIRFLOW__CORE__SQL_ALCHEMY_CONN

# Derive useful variables from the AIRFLOW__ variables provided explicitly by the user
POSTGRES_ENDPOINT=$(echo -n "$AIRFLOW__CORE__SQL_ALCHEMY_CONN" | cut -d '/' -f3 | sed -e 's,.*@,,')
POSTGRES_HOST=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f1)
POSTGRES_PORT=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f2)

wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"


# Init database
airflow initdb

# Create `Admin` user
python /create_user.py 

# Run worker and scheduler
airflow scheduler &
exec airflow webserver