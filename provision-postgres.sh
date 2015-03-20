#!/bin/bash

set -e

usrgrp() {
  groupadd -r postgres && useradd -r -g postgres postgres
}

packages() {
  apt-get update && apt-get upgrade -y \
    && apt-get install -y vim curl pwgen procps screen daemontools
}

gosu() {
  gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
  apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu
}

utf8() {
  apt-get update && apt-get upgrade -y \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
  echo "export LANG=en_US.utf8" >> /etc/profile
  source /etc/profile
}

install() {
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
}

setup() {
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
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  gosu postgres initdb -d
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"
  echo "echo $PGDATA"

  echo "Configuring access"
  sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" $data_dir/postgresql.conf
  sed -ri "s/^#(log_destination\s*=\s*)\S+/\1'syslog'/" $data_dir/postgresql.conf
  echo "# Allow remote connections only from the range above. Password is required." >> $data_dir/pg_hba.conf
  echo "host    all             all             172.17.0.0/16           md5" >> $data_dir/pg_hba.conf
  echo "host    all             all             189.62.0.0/16           md5" >> $data_dir/pg_hba.conf

  echo "Setting the new password"
  gosu postgres postgres --single -jE <<-EOSQL
    ALTER USER postgres WITH ENCRYPTED PASSWORD '$passwd' ;
EOSQL
}

svscanboot() {
  mkdir -p /etc/service/postgres
  echo -e '#!/bin/bash\ngosu postgres postgres' > /etc/service/postgres/run
  chmod +x /etc/service/postgres/run

  if grep -q "svscanboot" /etc/inittab; then
    echo "Svscanboot already configured to be loaded on startup. Skipping this step."
  else
    echo -e '\n# Svscanboot will load on startup and launch everyone under /etc/service' >> /etc/inittab
    echo -e 'SV:123456:respawn:/usr/bin/svscanboot' >> /etc/inittab
  fi
}


case "$1" in
  usrgrp)
    usrgrp
    ;;
  packages)
    packages
    ;;
  gosu)
    gosu
    ;;
  utf8)
    utf8
    ;;
  install)
    install
    ;;
  setup)
    setup $2 $3
    ;;
  svscanboot)
    svscanboot
    ;;
  all)
    STEPS_NUM=7
    echo "Step 1 / $STEPS_NUM"
    usrgrp
    echo "Step 2 / $STEPS_NUM"
    packages
    echo "Step 3 / $STEPS_NUM"
    gosu
    echo "Step 4 / $STEPS_NUM"
    utf8
    echo "Step 5 / $STEPS_NUM"
    install
    echo "Step 6 / $STEPS_NUM"
    setup $2 $3
    echo "Step 7 / $STEPS_NUM"
    svscanboot
    echo "Finished all steps!"
    ;;
  *)
    echo "Usage: $0 {usrgrp|packages|gosu|utf8|install|setup|svscanboot|all}"
    echo ""
    echo "Details"
    echo "  usrgrp:"
    echo "    creates redis user and group"
    echo ""
    echo "  packages:"
    echo "    installs all basic packages such as vim, screen and so on"
    echo ""
    echo "  gosu:"
    echo "    installs gosu since we cannot run postgres under root"
    echo ""
    echo "  utf8:"
    echo "    sets utf8 as default locale - postgres will assume this as default for the DBs"
    echo ""
    echo "  install:"
    echo "    installs PostgreSQL 9.4.1"
    echo ""
    echo "  setup DIR [PASS]:"
    echo "    configures postgres"
    echo "      DIR: pgsql data dir, recommended '/data/postgres'"
    echo "      PASS: <optional> password for postgres. If not given it will generate one"
    echo ""
    echo "  svscanboot DIR:"
    echo "    setup process monitoring over Redis and auto startup on boot. DIR: the same used with setup step"
    echo ""
    echo "  all:"
    echo "    triggers all installing Redis from the scratch: usrgrp > packages > install > setup > svscanboot"
    echo ""
    exit 1
esac

exit 0
