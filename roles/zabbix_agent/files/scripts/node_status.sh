#!/bin/bash


PARAM="$1"

case "$PARAM" in
'sync' )
        docker exec witnet_node witnet node nodeStats 2>/dev/null | grep -oe "Synchronization progress: \S*" | grep -oE '[0-9]{2}.[0-9]{2}'
;;
'proposed_blocks' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Proposed blocks" | grep -oe "[0-9]*"
;;
'blocks_included' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Blocks included in the block chain" | grep -oe "[0-9]*"
;;
'eligibility_to_mine' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Times with eligibility to mine a data request" | grep -oe "[0-9]*"
;;
'proposed_commits' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Proposed commits" | grep -oe "[0-9]*"
;;
'accepted_commits' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Accepted commits" | grep -oe "[0-9]*"
;;
'slashed_commits' )
        docker exec  witnet_node witnet node nodeStats 2>/dev/null | grep "Slashed commits" | grep -oe "[0-9]*"
;;
'balance_con' )
        docker exec  witnet_node witnet node balance 2>/dev/null | grep -oe "Confirmed balance:   \S*" | grep -oe '[0-9]*\.[0-9]*'
;;
'balance_pen' )
        docker exec  witnet_node witnet node balance 2>/dev/null | grep -e "Pending balance:" | grep -oe '[0-9]*\.[0-9]*'
;;
'reputation' )
        docker exec  witnet_node witnet node reputation 2>/dev/null | grep -o -E "Reputation: \S*," | grep -o -E '[0-9]*'
;;
'eligibility' )
        docker exec  witnet_node witnet node reputation 2>/dev/null | grep -oe "Eligibility: \S*%" | grep -oE '[0-9]*\.[0-9]*'
;;
'number' )
        docker ps | grep witnet_node | wc -l
;;
* ) echo "ZBX_UNSUPPORTED_SCRIPT"; exit 1;;
esac