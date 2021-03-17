#!/bin/bash

PARAM="$1"
DB="$2"

case "$PARAM" in
  'status' )
    STATUS=$(psql -c "show autovacuum;" | grep -o on); if test -z $STATUS; then echo 0; else echo 1; fi
  ;;
  'current' )
    /usr/bin/psql -c "SELECT datname, age(datfrozenxid), current_setting('autovacuum_freeze_max_age') FROM pg_database ORDER BY 2 DESC;" | grep $DB | grep -Eo '[0-9]*' | head -n1
  ;;
  'max' )
    /usr/bin/psql -c "SELECT datname, age(datfrozenxid), current_setting('autovacuum_freeze_max_age') FROM pg_database ORDER BY 2 DESC;" | grep $DB | grep -Eo '[0-9]*' | tail -n1
  ;;
  * ) 
    echo "ZBX_NOTSUPPORTED"; exit 1
  ;;
esac