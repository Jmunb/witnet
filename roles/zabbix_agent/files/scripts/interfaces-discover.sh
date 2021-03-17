#!/bin/bash
# ekoz 10.01.2018

if [ x$1 = 'xbonding' ] ; then
  interfaces=`awk '/Slave Interface/ {print $3}' /proc/net/bonding/*`
else
  interfaces=`/sbin/ip address show | grep "inet " | grep global | awk '{print $(NF)}' | grep -v ^docker | sort | uniq`
fi
echo ' { "data":[ '

count=`echo $interfaces | wc -w`

i=1
for iface in $interfaces; do
  echo -n "{ \"{#IFNAME}\":\"$iface\" }"
  if [ $((i++)) -lt $count ] ; then
    echo -n ","
  fi
  echo ""
done

echo " ] } "
