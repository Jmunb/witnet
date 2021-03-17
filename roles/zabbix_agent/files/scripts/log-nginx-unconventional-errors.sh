#!/bin/bash

LOGS=""
if [ -d /opt/nginx/logs  -a ! -h /opt/nginx/logs ] ; then
  LOGS=`ls /opt/nginx/logs/*error*.log 2>/dev/null`
else
  LOGS=`ls /var/log/nginx/*error*.log 2>/dev/null`
fi
DATE=`LANG=C date --date "minute ago" +%d/%b/%Y:%H:%M`
HITS=0
for i in $LOGS ; do
  # detect format of log
  STATUSN=`tail $i | grep -c 'status='`
  if [ $STATUSN -eq 0 ] ; then
    # traditioan apache format
    HITSN=`tail -50000 $i | grep $DATE | grep " failed (" | tee -a /tmp/log-nginx-errors.log | wc -l`
  else
    # nano named format
    #HITSN=`tail -20000 $i | grep $DATE | sed -r 's/.*status=(\S+).*/\1/' | awk '{if($1>499) print $0}' | tee -a /tmp/log-nginx-errors.log | wc -l`
    HITSN=`tail -50000 $i | grep $DATE | grep " status=50" | tee -a /tmp/log-nginx-errors.log | wc -l`
  fi
  HITS=$(($HITS+$HITSN))
done
echo nginx unconventional errors at $DATE: $HITS | logger -p local4.notice
echo $HITS
