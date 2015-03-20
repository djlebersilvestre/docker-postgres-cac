#!/bin/bash

set -e

pg_major=9.4
pg_version=9.4.1-1.pgdg70+1

apt-key adv --keyserver pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' $pg_major > /etc/apt/sources.list.d/pgdg.list

apt-get update && apt-get install -y postgresql-common \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get install -y postgresql-$pg_major=$pg_version postgresql-contrib-$pg_major=$pg_version

mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql
chmod g+s /run/postgresql && chown -R postgres:postgres /run/postgresql
echo "export PATH=$PATH:/usr/lib/postgresql/$pg_major/bin" >> /etc/profile
source /etc/profile

exit 0
