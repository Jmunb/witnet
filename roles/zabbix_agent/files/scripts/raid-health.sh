#!/bin/bash

lspci 2>&1 | grep -qio megaraid
if [[ $? -eq 0 ]]; then
    /opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep -A 8 "Device Present" | grep "Degraded\|Offline\|Critical\|Failed" | awk -F ':' '{sum=sum+$2} END {print sum}'
    exit 0
else
    /bin/cat /proc/mdstat | grep -c _
    exit 0
fi
