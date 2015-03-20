#!/bin/bash

DKR_PG_IMAGE=djlebersilvestre/postgres:9.4.1
DKR_PG_CONTAINER=postgres
PG_PASS=testing
PG_HOST=127.0.0.1
PG_PORT=5432

pg_build() {
  docker build -t $DKR_PG_IMAGE https://github.com/djlebersilvestre/docker-postgres-cac.git
}

pg_setup() {
  if ! docker ps -a | grep -q " $DKR_PG_CONTAINER "; then
    docker run --name $DKR_PG_CONTAINER -d -p $PG_HOST:$PG_PORT:$PG_PORT $DKR_PG_IMAGE
  fi
}

pg_start() {
  pg_setup
  pg_stop
  docker start $DKR_PG_CONTAINER
}

pg_restart() {
  pg_start
}

pg_stop() {
  docker stop $DKR_PG_CONTAINER
}

pg_client() {
  docker run --rm -it --link $DKR_PG_CONTAINER:$DKR_PG_CONTAINER $DKR_PG_IMAGE sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
}

pg_console() {
  docker run --rm -it $DKR_PG_IMAGE /bin/bash
}
