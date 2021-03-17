#!/bin/bash

psql -qtAX -c "SELECT CASE WHEN replay_lag IS NULL THEN '0' ELSE ROUND(EXTRACT(SECOND FROM replay_lag)) END FROM pg_stat_replication"
