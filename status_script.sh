#!/bin/bash


PARAM="$1"
HOSTS=$(cat ./inventory.ini|tail -n +2)

case "$PARAM" in
'sync' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep 'Synchronization progress:'"
        echo ""
    done
;;
'nodestats' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec  witnet_node witnet node nodeStats 2>/dev/null"
        echo ""
    done
;;
'balance' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec  witnet_node witnet node balance 2>/dev/null"
        echo ""
    done
;;
'reputation' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec  witnet_node witnet node reputation 2>/dev/null"
        echo ""
    done
;;
'restart' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker restart witnet_node"
        echo ""
    done
;;
'forked' )
    for i in $HOSTS
    do
        echo $i
        ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $i "docker exec witnet_node sh -c \"witnet node blockchain --epoch 248839 --limit 2 2>&1 | grep -q '#248921 had digest 7556670d' && echo 'Your node seems to be OK' || echo 'Oh no! Your node is forked'\""
        echo ""
    done
;;
* ) echo "Use one of following: sync, nodestats, balance, reputation"; exit 1;;
esac
