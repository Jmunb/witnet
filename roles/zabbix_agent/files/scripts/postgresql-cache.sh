#!/bin/bash

/usr/bin/psql -qtAX $1 -c 'SELECT sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) FROM pg_statio_user_tables;'
