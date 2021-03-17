#!/bin/bash

TYPE=$1
BLK=$2
DID=$3


MD=$(cat /proc/mdstat | grep md)
if [ -z "$MD" ]
then
    case "$TYPE" in
    'discovery' )
            BLKD=$(lsblk | grep disk | awk '{ print $1 }' | head -n1)
            COUNT=$(/opt/MegaRAID/MegaCli/MegaCli64  -PDList -aALL  | sed -n -e 's/^.*Slot Number: //p' | wc -l)
            MAXCOUNT=$(( $COUNT - 1 ))

            echo -n '{"data":['
            for i in $(/opt/MegaRAID/MegaCli/MegaCli64  -PDList -aALL  | sed -n -e 's/^.*Slot Number: //p')
            do
                SSD=$(smartctl -a -d megaraid,$i /dev/$BLKD | grep Solid)
                if [ ! -z "$SSD" ]
                then
                    echo '{'
                    echo -n "\"{#BLK}\": \"$BLKD\","
                    #echo "Device id $i is SSD"
                    echo -n "\"{#ID}\": \"$i\""
                    echo '}'
                    if [ "$i" -lt "$MAXCOUNT"  ]
                    then
                        echo -n ","
                    else
                        echo " ] } "
                    fi
                fi
            done
    ;;
    'life' )
            LIFE=$(smartctl -a -d megaraid,$DID /dev/$BLK | grep "231 Temperature_Celsius" | awk '{print $10}')
            if [ -z "$LIFE" ]
            then
                echo "ZBX_NOTSUPPORTED"
            elif [ "$LIFE" -eq 0 ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $LIFE
            fi
    ;;
    'realloc' )
            RELOC=$(smartctl -a -d megaraid,$DID /dev/$BLK | grep "Reallocated_Sector_Ct" | awk '{print $10}')
            if [ -z "$RELOC" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $RELOC
            fi
    ;;
    'read_err' )
            READ_ERR=$(smartctl -a -d megaraid,$DID /dev/$BLK | grep "Raw_Read_Error_Rate" | awk '{print $10}')
            if [ -z "$READ_ERR" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $READ_ERR
            fi
    ;;
    'rsvd_block' )
            BLK_CNT=$(smartctl -a -d megaraid,$DID /dev/$BLK | grep "Used_Rsvd_Blk_Cnt_Tot" | awk '{print $10}')
            if [ -z "$BLK_CNT" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $BLK_CNT
            fi
    ;;  
    * ) echo "ZBX_NOTSUPPORTED"; exit 1;;
    esac
else
    case "$TYPE" in
    'discovery' )
            COUNT=$(lsblk | grep disk | awk '{ print $1 }' | wc -l)
            MAXCOUNT=$(( $COUNT - 1 ))
            z=0
            echo -n '{"data":['
            for i in $(lsblk | grep disk | awk '{ print $1 }')
            do
                SSD=$(smartctl -a /dev/$i | grep Solid)
                if [ ! -z "$SSD" ]
                then
                    echo '{'
                    echo -n "\"{#BLK}\": \"$i\","
                    #echo "Device id $i is SSD"
                    echo -n "\"{#ID}\": \"$z\""
                    echo '}'
                    if [ "$z" -lt "$MAXCOUNT"  ]
                    then
                        echo -n ","
                    else
                        echo " ] } "
                    fi
                    ((z++))
                fi
            done            
    ;;
    'life' )
            LIFE=$(smartctl -a /dev/$BLK | grep "231 Temperature_Celsius" | awk '{print $10}')
            if [ -z "$LIFE" ]
            then
                echo "ZBX_NOTSUPPORTED"
            elif [ "$LIFE" -eq 0 ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $LIFE
            fi
    ;;
    'realloc' )
            RELOC=$(smartctl -a /dev/$BLK | grep "Reallocated_Sector_Ct" | awk '{print $10}')
            if [ -z "$RELOC" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $RELOC
            fi
    ;;
    'read_err' )
            READ_ERR=$(smartctl -a /dev/$BLK | grep "Raw_Read_Error_Rate" | awk '{print $10}')
            if [ -z "$READ_ERR" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $READ_ERR
            fi
    ;;
    'rsvd_block' )
            BLK_CNT=$(smartctl -a /dev/$BLK | grep "Used_Rsvd_Blk_Cnt_Tot" | awk '{print $10}')
            if [ -z "$BLK_CNT" ]
            then
                echo "ZBX_NOTSUPPORTED"
            else
                echo $BLK_CNT
            fi
    ;;  
    * ) echo "ZBX_NOTSUPPORTED"; exit 1;;
    esac
fi