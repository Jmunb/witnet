#!/bin/bash

if [ -h /opt/nginx/logs ];
then
	LOGS=`ls /var/log/nginx/*access*.log 2>/dev/null`
else
	LOGS=`ls /opt/nginx/logs/*access*.log /var/log/nginx/*access*.log 2>/dev/null`
fi
DATE=`LANG=C date --date "minute ago" +%d/%b/%Y:%H:%M`
HITS=0
for i in $LOGS ; do
  HITSN=`tail -50000 $i | grep -c $DATE`
  HITS=$(($HITS+$HITSN))
done
echo nginx hits at $DATE: $HITS | logger -p local4.notice
echo $HITS
