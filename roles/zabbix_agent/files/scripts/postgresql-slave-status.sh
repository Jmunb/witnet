#!/bin/bash

var=$(psql -x -c "select * from pg_stat_wal_receiver;" | grep streaming) ; [ -z "$var" ] && echo "0" || echo "1"