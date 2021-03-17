#!/bin/bash

pg_version=`/usr/bin/psql -V | egrep -o '[0-9.]*' | cut -d\. -f1`
client_addr=$1
lag_type=$2

if [ $pg_version -lt 10 ]; then
#legacy for postgresql version < 10
  if [ -n "$client_addr" ]; then
#Run check on master if replica ip is given
    /usr/bin/psql -qAtX -c "select greatest(0,pg_xlog_location_diff(pg_current_xlog_location(), replay_location)) from pg_stat_replication where client_addr = '$1'"
  else
#Run old replica check on slave if no ip is given
    /usr/bin/psql -X -c 'SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp())::INTEGER END AS replication_lag' | egrep '[0-9]$' | tr -d [:blank:]
  fi
else
  if [ -n "$client_addr" ]; then
#Run check on master if replica ip is given
    if [ -n "$lag_type" ]; then
#get specific lag type: write_lag, flush_lag, replay_lag
      /usr/bin/psql -qAtX -c "SELECT CASE WHEN $2 IS NULL THEN '0' ELSE ROUND(EXTRACT(SECOND FROM $2)) END FROM pg_stat_replication WHERE client_addr = '$1'"
    else
#show replay_lag if lag type wasn't given
      /usr/bin/psql -qAtX -c "SELECT CASE WHEN replay_lag IS NULL THEN '0' ELSE ROUND(EXTRACT(SECOND FROM replay_lag)) END FROM pg_stat_replication WHERE client_addr = '$1'"
    fi
  else
#Run old replica check on slave if no ip is given
    /usr/bin/psql -X -c 'SELECT EXTRACT(EPOCH FROM now() - pg_last_xact_replay_timestamp())::INTEGER AS replication_lag' | egrep '[0-9]$' | tr -d [:blank:]
  fi
fi
