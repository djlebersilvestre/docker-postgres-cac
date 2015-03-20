#!/bin/bash

set -e

scripts=${0%/*}/provision-steps
rm -rf $scripts
mkdir $scripts

github="https://raw.githubusercontent.com/djlebersilvestre/docker-postgres-debian7.4/master/provision-steps"
curl -sSL "$github/usrgrp.sh"     -o $scripts/usrgrp.sh
curl -sSL "$github/packages.sh"   -o $scripts/packages.sh
curl -sSL "$github/utf8.sh"       -o $scripts/utf8.sh
curl -sSL "$github/install.sh"    -o $scripts/install.sh
curl -sSL "$github/setup.sh"      -o $scripts/setup.sh
curl -sSL "$github/svscanboot.sh" -o $scripts/svscanboot.sh
chmod +x -R $scripts

# Step 1 - usrgrp:"
#   creates redis user and group"
#
# Step 2 - packages:"
#   installs all basic packages such as vim, screen and so on"
#
# Step 3 - utf8:"
#   sets utf8 as default locale - postgres will assume this as default for the DBs"
#
# Step 4 - install:"
#   installs PostgreSQL 9.4.1"
#
# Step 5 - setup DIR [PASS]:"
#   configures postgres"
#     DIR: pgsql data dir, recommended '/data/postgres'"
#     PASS: <optional> password for postgres. If not given it will generate one"
#
# Step 6 - svscanboot DIR:"
#   setup process monitoring over Redis and auto startup on boot. DIR: the same used with setup step"

STEPS_NUM=6
echo "Step 1 / $STEPS_NUM"
. $scripts/usrgrp.sh
echo "Step 2 / $STEPS_NUM"
. $scripts/packages.sh
echo "Step 3 / $STEPS_NUM"
. $scripts/utf8.sh
echo "Step 4 / $STEPS_NUM"
. $scripts/install.sh
echo "Step 5 / $STEPS_NUM"
. $scripts/setup.sh $2 $3
echo "Step 6 / $STEPS_NUM"
. $scripts/svscanboot.sh
echo "Finished all steps!"
exit 0
