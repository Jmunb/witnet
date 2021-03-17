#!/bin/bash

if [ "$1" = "table"  ] ; then

/usr/bin/psql -X -d $2 -c "select pg_table_size('\"$3\"');" | awk 'NR==3' | sed 's/^ *//g'

else

/usr/bin/psql -X -c "select pg_database_size('$2');" | awk 'NR==3' | sed 's/^ *//g'

fi
