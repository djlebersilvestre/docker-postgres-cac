#!/bin/bash

set -e

data_dir=$1
passwd=$2

if [ -z "$data_dir" ]; then
  echo "The postgres data dir must be passed to $0 in order to continue with the configuration."
  exit 1
fi
if [ -z "$passwd" ]; then
  echo "Password not given. Generating random password."
  passwd=$(pwgen -s -1 16)
fi

echo "PG_DATA_DIR: $data_dir"
echo "PG_PASSWORD: $passwd"

echo "Setting up $data_dir and exporting as environment variable"
mkdir -p $data_dir && chown -R postgres:postgres $data_dir
echo "export PGDATA=$data_dir" >> /etc/profile
source /etc/profile

echo "Creating the postgres DB structure under $data_dir"
su postgres sh -lc "initdb"

echo "Configuring access"
sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" $data_dir/postgresql.conf
sed -ri "s/^#(log_destination\s*=\s*)\S+/\1'syslog'/" $data_dir/postgresql.conf
echo "# Allow remote connections only from the range above. Password is required." >> $data_dir/pg_hba.conf
echo "host    all             all             172.17.0.0/16           md5" >> $data_dir/pg_hba.conf
echo "host    all             all             189.62.0.0/16           md5" >> $data_dir/pg_hba.conf

echo "Setting the new password"
su postgres sh -lc "postgres --single -jE" <<-EOSQL
  ALTER USER postgres WITH ENCRYPTED PASSWORD '$passwd';
EOSQL
