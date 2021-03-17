#!/bin/bash

HOSTS=$(cat ./inventory.ini|tail -n +2)
for i in $HOSTS
do
echo $i
    KEYPATH=$(ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec  witnet_node witnet node masterKeyExport --write 2>/dev/null | grep 'Private key' | grep -oe '/.witnet\S*'")
    HSTNAME=$(ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "hostname")
    scp $i:/root$KEYPATH ~/witkeys/$HSTNAME.txt
echo ""
done
