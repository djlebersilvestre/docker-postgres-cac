################################################################
## Dockerfile to build a Debian 7.4 - postgres image based on ##
## Cloud at Cost machine. Base script extracted from:         ##
## https://github.com/docker-library/postgres/tree/master/9.4 ##
################################################################

# Pull base image
FROM debian:7.4
MAINTAINER Daniel Silvestre (djlebersilvestre@github.com)

# Add postgres user and group first to make sure their IDs get assigned
# consistently, regardless of whatever dependencies get added
COPY provision-steps/usrgrp.sh /steps/usrgrp.sh
RUN /steps/usrgrp.sh

# Install basic packages
COPY provision-steps/packages.sh /steps/packages.sh
RUN /steps/packages.sh

# Make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
COPY provision-steps/utf8.sh /steps/utf8.sh
RUN /steps/utf8.sh
ENV LANG en_US.utf8

# Install postgres 9.4.1
COPY provision-steps/install.sh /steps/install.sh
RUN /steps/install.sh
ENV PATH $PATH:/usr/lib/postgresql/9.4/bin

# Configure postgres (default data dir)
COPY provision-steps/setup.sh /steps/setup.sh
ENV PGDATA /data/postgres
RUN /steps/setup.sh $PGDATA testing

# Setup process monitoring through daemontools
COPY provision-steps/svscanboot.sh /steps/svscanboot.sh
RUN /steps/svscanboot.sh

# Directory that stores postgres data
VOLUME /data/postgres
WORKDIR /data/postgres

EXPOSE 5432
CMD [ "svscanboot" ]
