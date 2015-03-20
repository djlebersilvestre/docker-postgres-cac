#!/bin/bash

set -e

groupadd -r postgres && useradd -r -g postgres postgres

exit 0
