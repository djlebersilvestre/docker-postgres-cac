#!/bin/bash

if id -g "postgres" > /dev/null 2>&1; then
  echo "Group postgres already exists"
else
  groupadd -r postgres
fi

if id -u "postgres" > /dev/null 2>&1; then
  echo "User postgres already exists"
else
  useradd -r -g postgres postgres
fi
