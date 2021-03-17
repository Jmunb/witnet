#!/bin/bash

if [ x$1 = 'x' ] ; then

  dockerlist=$(docker ps --format {{.Names}})
  dockercount=`echo $dockerlist | wc -w`
  i=1

  echo ' { "data":[ '

  for docker in $dockerlist ; do
    echo '{'
    echo -n "\"{#NAME}\":\"$docker\""
    echo '}'
    if [ $((i++)) -lt $dockercount ] ; then
      echo -n ","
    fi
  done

  echo " ] } "
else
  docker stats --no-stream --format "{{.MemPerc}}" -- $1 | tr -d %
fi
