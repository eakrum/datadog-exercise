#!/bin/sh
set -m
node database.js # create table
npm run serve # run server

exec "$@"