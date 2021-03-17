#!/bin/bash
/bin/egrep -Ec "$(/bin/date +%H:%M --date "minute ago").*duration.*execute" /var/lib/pgsql/*/data/*log/postgresql-$(LANG=en_US.utf8 date +%a).* | /bin/awk -F":" '{ s+=$2 } END { print s }'
