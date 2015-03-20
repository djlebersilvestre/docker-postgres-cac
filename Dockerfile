################################################################
## Dockerfile to build a Debian 7.4 - postgres image based on ##
## Cloud at Cost machine. Base script extracted from:         ##
## https://github.com/docker-library/postgres/tree/master/9.4 ##
################################################################

# Pull base image
FROM debian:7.4
MAINTAINER Daniel Silvestre (djlebersilvestre@github.com)

# Base script - all provisioning funcions
# COPY provision-postgres.sh /provision-postgres.sh
# RUN chmod +x /provision-postgres.sh

# Add postgres user and group first to make sure their IDs get assigned
# consistently, regardless of whatever dependencies get added
# RUN /provision-postgres.sh usrgrp
RUN  groupadd -r postgres && useradd -r -g postgres postgres

# Install basic packages
# RUN /provision-postgres.sh packages
RUN  apt-get update && apt-get upgrade -y \
    && apt-get install -y vim curl pwgen procps screen daemontools

# Grab gosu for easy step-down from root
# RUN /provision-postgres.sh gosu
RUN  gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN  apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# Make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
# RUN /provision-postgres.sh utf8
RUN  apt-get update && apt-get upgrade -y \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN  echo "export LANG=en_US.utf8" >> /etc/profile
ENV LANG en_US.utf8

# Install postgres 9.4.1
# RUN /provision-postgres.sh install
ENV  pg_major 9.4
ENV  pg_version 9.4.1-1.pgdg70+1
RUN  apt-key adv --keyserver pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN  echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' $pg_major > /etc/apt/sources.list.d/pgdg.list

RUN  apt-get update && apt-get install -y postgresql-common \
    && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y postgresql-$pg_major=$pg_version postgresql-contrib-$pg_major=$pg_version

RUN  mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql
RUN  chmod g+s /run/postgresql && chown -R postgres:postgres /run/postgresql
ENV  PATH $PATH:/usr/lib/postgresql/$pg_major/bin
RUN  echo "export PATH=$PATH:/usr/lib/postgresql/$pg_major/bin" >> /etc/profile

# Configure postgres (default data dir)
COPY provision-postgres.sh /provision-postgres.sh
RUN chmod +x /provision-postgres.sh
RUN /provision-postgres.sh setup /data/postgres testing
# ENV data_dir /data/postgres
# ENV passwd testing
# RUN  echo "PG_DATA_DIR: $data_dir"
# RUN  echo "PG_PASSWORD: $passwd"
# RUN  echo "Setting up $datadir and exporting as environment variable"
# RUN  mkdir -p $data_dir && chown -R postgres:postgres $data_dir
# ENV  PGDATA $data_dir
# RUN  echo "export PGDATA=$data_dir" >> /etc/profile
# RUN  echo "Creating the postgres DB structure"
# RUN  gosu postgres initdb
# RUN  echo "Configuring access"
# RUN  sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" $data_dir/postgresql.conf
# RUN  sed -ri "s/^#(log_destination\s*=\s*)\S+/\1'syslog'/" $data_dir/postgresql.conf
# RUN  echo "# Allow remote connections only from the range above. Password is required." >> $data_dir/pg_hba.conf
# RUN  echo "host    all             all             172.17.0.0/16           md5" >> $data_dir/pg_hba.conf
# RUN  echo "host    all             all             189.62.0.0/16           md5" >> $data_dir/pg_hba.conf
# RUN  echo "Setting the new password"
# RUN  gosu postgres postgres --single -jE <<-EOSQL ALTER USER postgres WITH ENCRYPTED PASSWORD '$passwd' ; EOSQL

# Setup process monitoring through daemontools
RUN /provision-postgres.sh svscanboot
# RUN  mkdir -p /etc/service/postgres
# RUN  echo -e '#!/bin/bash\ngosu postgres postgres' > /etc/service/postgres/run
# RUN  chmod +x /etc/service/postgres/run
# 
# RUN  if grep -q "svscanboot" /etc/inittab; then
    # echo "Svscanboot already configured to be loaded on startup. Skipping this step."
  # else
    # echo -e '\n# Svscanboot will load on startup and launch everyone under /etc/service' >> /etc/inittab
    # echo -e 'SV:123456:respawn:/usr/bin/svscanboot' >> /etc/inittab
  # fi

# Directory that stores postgres data
VOLUME /data/postgres
WORKDIR /data/postgres

EXPOSE 5432
CMD [ "svscanboot" ]
