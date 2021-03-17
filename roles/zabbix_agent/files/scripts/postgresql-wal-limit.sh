#!/bin/bash

walbs=$(/usr/bin/psql -qtAX -c "select setting from pg_settings where name = 'wal_block_size';")
walks=$(/usr/bin/psql -qtAX -c "select setting from pg_settings where name = 'wal_keep_segments';")
walss=$(/usr/bin/psql -qtAX -c "select setting from pg_settings where name = 'wal_segment_size';")
echo $(($walbs * $walks * $walss))