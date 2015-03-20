#!/bin/bash

set -e

apt-get update && apt-get upgrade -y \
  && apt-get install -y vim pwgen procps screen daemontools
