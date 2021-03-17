#!/bin/bash

/usr/bin/psql -qtAX -c 'SELECT sum(numbackends) FROM pg_stat_database;'
