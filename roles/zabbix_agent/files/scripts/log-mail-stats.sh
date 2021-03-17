#bin/bash 
LOG=/var/log/maillog
DATE=`LANG=C date --date "minute ago" "+%b %_d %R"`
HITS=`tail -100000 $LOG | grep "$DATE" | grep -c 'status=sent'`
echo $HITS
