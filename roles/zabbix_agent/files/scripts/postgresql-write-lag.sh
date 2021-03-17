#!/bin/bash

psql -qtAX -c "SELECT CASE WHEN write_lag IS NULL THEN '0' ELSE ROUND(EXTRACT(SECOND FROM write_lag)) END FROM pg_stat_replication"
