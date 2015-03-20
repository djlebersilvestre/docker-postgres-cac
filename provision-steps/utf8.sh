#!/bin/bash

set -e

apt-get update && apt-get upgrade -y \
  && apt-get install -y locales \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
echo "export LANG=en_US.utf8" >> /etc/profile
source /etc/profile
