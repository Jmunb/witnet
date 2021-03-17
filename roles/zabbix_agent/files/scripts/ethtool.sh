#!/bin/bash
if [[ $1 =~ 'tun' ]] ; then
    echo "100"
else
    check=$(ethtool $1 | grep Speed: | sed 's/[^0-9]*//g')
    if [[ -z $check ]] ; then
        echo "0"
    else
        echo $check
    fi
fi