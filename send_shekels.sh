#!/bin/bash

set -e

MAIN=$1
HOST=$(cat ./$2|tail -n +2)
AMOUNT=$3

if [ x$1 = 'x' ] ; then
 MAIN=135.181.144.30
fi

if [ x$2 = 'x' ] ; then
 HOSTS=$(cat ./inventory.ini|tail -n +2)
fi

if [ x$3 = 'x' ] ; then
 AMOUNT=10000000000
fi

for i in $HOSTS
do
    ADRESS=$(ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec witnet_node witnet node address 2>/dev/null | grep \"Mainnet address\" | grep -oe \"\S*$\"")
    HOSTNAME=$(ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "hostname")
    ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $1 "docker exec witnet_node witnet node send 2>/dev/null --address=$ADRESS --value=$AMOUNT --fee=1"
    echo "Sended 1 shekel to $HOSTNAME"
    echo ""
done