#!/bin/bash

LOGS=""
if [ -d /opt/nginx/logs  -a ! -h /opt/nginx/logs ] ; then
  LOGS=`ls /opt/nginx/logs/*access*.log 2>/dev/null`
else
  LOGS=`ls /var/log/nginx/*access*.log 2>/dev/null`
fi
DATE=`LANG=C date --date "minute ago" +%d/%b/%Y:%H:%M`
HITS=0
for i in $LOGS ; do
  HITSN=`tail -50000 $i | grep $DATE | awk '{if($9>399 && $9<499) print $0}' | wc -l`
  HITS=$(($HITS+$HITSN))
done
echo nginx bad requests at $DATE: $HITS | logger -p local4.notice
echo $HITS
