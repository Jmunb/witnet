#!/bin/bash

if [ "$1" = "stats"  ] ; then

PSQL=$(which psql)

hostname=localhost
port=6432
username=stats
dbname="pgbouncer"
PARAM="$2"

IFS=':'; arr_poolname=($3); unset IFS;

conn_param="-qAtX -F: -h $hostname -p $port -U $username $dbname"

case "$PARAM" in
'avg_req' )
        $PSQL $conn_param -c "show stats" |grep -w ${arr_poolname[0]} |cut -d: -f6
;;
'avg_recv' )
        $PSQL $conn_param -c "show stats" |grep -w ${arr_poolname[0]} |cut -d: -f11
;;
'avg_sent' )
        $PSQL $conn_param -c "show stats" |grep -w ${arr_poolname[0]} |cut -d: -f12
;;
'avg_query' )
        $PSQL $conn_param -c "show stats" |grep -w ${arr_poolname[0]} |cut -d: -f9
;;
'cl_active' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f3
;;
'cl_waiting' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f4
;;
'sv_active' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f5
;;
'sv_idle' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f6
;;
'sv_used' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f7
;;
'sv_tested' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f8
;;
'sv_login' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f9
;;
'maxwait' )
        $PSQL $conn_param -c "show pools" |grep -w ^$3 |cut -d: -f10
;;
'max_clients' )
        cat /etc/pgbouncer/pgbouncer.ini | grep "client_conn" | grep -Eo '[0-9]*' | awk '{s+=$1} END {print s}'
;;
'used_clients' )
        $PSQL $conn_param -c "show lists" |grep -w used_clients |cut -d: -f2
;;
'login_clients' )
        $PSQL $conn_param -c "show lists" |grep -w login_clients |cut -d: -f2
;;
'max_servers' )
        cat /etc/pgbouncer/pgbouncer.ini | grep "pool_size" | grep -Eo '[0-9]*' | awk '{s+=$1} END {print s}'
;;
'used_servers' )
        $PSQL $conn_param -c "show lists" |grep -w used_servers |cut -d: -f2
;;
'total_avg_req' )
        $PSQL $conn_param -c "show stats" |cut -d: -f6 |awk '{ s += $1 } END { print s }' | while read foo; do echo $(( foo / 1000000 )); done
;;
'total_avg_recv' )
        $PSQL $conn_param -c "show stats" |cut -d: -f7 |awk '{ s += $1 } END { print s }'
;;
'total_avg_sent' )
        $PSQL $conn_param -c "show stats" |cut -d: -f8 |awk '{ s += $1 } END { print s }'
;;
'total_avg_query' )
        $PSQL $conn_param -c "show stats" |cut -d: -f6,9 |awk -F: '{ a += $1 * $2} { b += $1} END { print a / b }' | while read foo; do echo $(( foo / 1000000 )); done
;;
* ) echo "ZBX_NOTSUPPORTED"; exit 1;;
esac

else

poollist=$(psql -h localhost -p 6432 -U stats -tAF: pgbouncer -c "show pools" | awk -F ':' '{print $1}' | grep -v 'pgbouncer')

echo -n '{"data":['
for pool in $poollist; do echo -n "{\"{#POOLNAME}\": \"$pool\"},"; done |sed -e 's:\},$:\}:'
echo -n ']}'

fi