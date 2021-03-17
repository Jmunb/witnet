#!/bin/bash

DATE=`LANG=C date --date "minute ago" +%b\ %e\ %H:%M`
COUNT=`/usr/bin/tail -n 20000 /var/log/syslog | grep "$DATE" | grep -c "conntrack: table full"`

echo $COUNT
