#!/bin/bash

set -o errexit
set -o pipefail

if [ x$1 = 'x' ]; then
	LV_LIST=$(dmsetup status --target cache | awk -F":" '{print $1}' | sed 's/\-/\//g')
	LV_COUNT=$(echo $LV_LIST | wc -w)
	
	# beginning of the JSON
	echo ' { "data":[ '
	
	# JSON data
	i=1
	for lv in $LV_LIST ; do 
		echo -n "{ \"{#CACHEDLV}\":\"$lv\" }"
		if [ $((i++)) -lt $LV_COUNT ] ; then
			echo -n ","
		fi
 		echo ""
	done
	
	# ending of the JSON
	echo " ] } "
else
	FIELDS=$(cat <<EOF
start
end
segment_type
md_block_size
md_utilization
cache_block_size
cache_utilization
read_hits
read_misses
write_hits
write_misses
demotions
promotions
dirty
features
EOF
	)
	FIELD_COUNT=$(echo "$FIELDS" | wc -l)
	
	function extract_stat()
	{
	    echo "$1" | awk "/$2/ { print \$2 }"
	}
	
	function percent()
	{
	    awk "BEGIN { printf \"%.2f%%\", 100*$1/$2 }"
	}

	function percent_clean()
	{
	    awk "BEGIN { printf \"%.2f\", 100*$1/$2 }"
	}
	
	function insert_after()
	{
	    awk "// { print } ; /$1/ { print \"\n$2 $3\" }"
	}
	
	CACHE_ID=`echo "$1" | sed 's/-/--/' | tr / -`
	CACHE_STATS=$(paste <(echo "$FIELDS") <(dmsetup status | grep "${CACHE_ID}:" | sed -r -e 's/.*: (.*)/\1/' | tr ' ' '\n' | head -n${FIELD_COUNT}))
	
	# calculate cache hit percentage
	READ_HITS=$(extract_stat "$CACHE_STATS" read_hits)
	READ_MISSES=$(extract_stat "$CACHE_STATS" read_misses)
	READ_HIT_RATIO=$(percent $READ_HITS $(($READ_MISSES+$READ_HITS)))
	READ_HIT_RATIO_CLEAN=$(percent_clean $READ_HITS $(($READ_MISSES+$READ_HITS)))
	
	WRITE_HITS=$(extract_stat "$CACHE_STATS" write_hits)
	WRITE_MISSES=$(extract_stat "$CACHE_STATS" write_misses)
	WRITE_HIT_RATIO=$(percent $WRITE_HITS $(($WRITE_MISSES+$WRITE_HITS)))
	WRITE_HIT_RATIO_CLEAN=$(percent_clean $WRITE_HITS $(($WRITE_MISSES+$WRITE_HITS)))
	
	# get other variables
	DEMOTIONS=$(extract_stat "$CACHE_STATS" demotions)
	PROMOTIONS=$(extract_stat "$CACHE_STATS" promotions)
	
	# calculate dirty size in bytes
	DIRTY_BLOCKS=$(extract_stat "$CACHE_STATS" dirty)
	CACHE_BLOCK_SIZE=$(extract_stat "$CACHE_STATS" cache_block_size)
	DIRTY_SIZE=$(($DIRTY_BLOCKS*$CACHE_BLOCK_SIZE*512))

	if [ x$2 = 'x' ]; then	
	echo "$CACHE_STATS" | \
	    insert_after read_misses read_hit_ratio "$READ_HIT_RATIO" | \
	    insert_after write_misses write_hit_ratio "$WRITE_HIT_RATIO" | \
	    column -t	
	else
		case "$2" in
        		read_hit_ratio)
				echo $READ_HIT_RATIO_CLEAN
				;;
			read_hits)
				echo $READ_HITS
				;;
			read_misses)
				echo $READ_MISSES
				;;
			write_hit_ratio)
				echo $WRITE_HIT_RATIO_CLEAN
				;;
			write_hits)
				echo $WRITE_HITS
				;;
			write_misses)
				echo $WRITE_MISSES
				;;
			demotions)
				echo $DEMOTIONS
				;;
			promotions)
				echo $PROMOTIONS
				;;
			dirty_size)
				echo $DIRTY_SIZE
				;;
			*)
				echo $"Usage: $0 $1 {read_hit_ratio|read_hits|read_misses|write_hit_ratio|write_hits|write_misses|demotions|promotions|dirty_size}"
				exit 1
		esac
	fi
fi	
