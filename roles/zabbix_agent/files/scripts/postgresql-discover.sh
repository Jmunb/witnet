#!/bin/bash

isslave=$(/usr/bin/psql -qtAX -c 'SELECT pg_is_in_recovery();')
version=$(/usr/bin/psql -qtAX -c 'SELECT version();' | egrep -o "PostgreSQL [0-9]+" | egrep -o "[-.0-9]+")

if [ "$1" = "table" ] ; then

  databases=$(/usr/bin/psql -X -c '\l' | awk '{print $1}' | awk 'NR>3' | grep -e '^\w' | grep -v 'template' | grep -v 'postgres')
  dbcount=$(echo $databases | wc -w)

  #begin json
  echo ' { "data":[ '

  if [[ "$isslave" = "f" ]]  ; then
    #db counter
    i=1
    #not empty db counter
    nedb=0

    for db in $databases ; do
      #get tables JSON
      tablename=$(/usr/bin/psql -X -d $db -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'" | awk '{print $1}' | awk 'NR>2' | grep -e '^\w')
      tablecount=$(echo $tablename | wc -w)
      z=1
      if [ $tablecount -gt 0 ] ; then
        if [ $nedb -gt 0  ] ; then
          echo -n ","
        fi
        ((nedb++))
        for tb in $tablename ; do
          echo '{'
          echo -n "\"{#NAME}\":\"$tb\","
          echo -n "\"{#TYPE}\":\"table\","
          echo -n "\"{#DBNAME}\":\"$db\""
          echo '}'
          if [ $((z++)) -lt $tablecount ] ; then
            echo -n ","
          fi
        done
        #get indexes JSON
        indexname=$(/usr/bin/psql -X -d $db -c "select indexname from pg_indexes where schemaname = 'public';" | awk '{print $1}' | awk 'NR>2' | grep -e '^\w')
        indexcount=$(echo $indexname | wc -w)
        if [ $indexcount -gt 0 ] ; then
          echo -n ","
          y=1
          for id in $indexname ; do
            echo '{'
            echo -n "\"{#NAME}\":\"$id\","
            echo -n "\"{#TYPE}\":\"index\","
            echo -n "\"{#DBNAME}\":\"$db\""
            echo '}'
            if [ $((y++)) -lt $indexcount ] ; then
              echo -n ","
            fi
          done
        fi
      else
        ((i++))
      fi
    done
  fi

  #end json
  echo " ] } "

elif [ "$1" = "slave" ] ; then

  echo ' { "data":[ '

  if [ "$version" -lt 10 -a "$isslave" = "t" ]  ; then
    # We're definitly on a slave
    echo "{ \"{#IS_SLAVE9}\":\"\" }"
  elif [ "$version" -lt 10 -a "$isslave" = "f" ] ; then
    slaveslist=$(/usr/bin/psql -qtAX -c 'select client_addr from pg_stat_replication;')
    slavescount=$(echo $slaveslist | wc -w)
    i=1
    for slave in $slaveslist ; do
      echo "{ \"{#IS_MASTER9}\":\"$slave\" }"
      if [ $((i++)) -lt $slavescount ] ; then
        echo -n ","
      fi
    done
  elif [ "$version" -ge 10 -a "$isslave" = "t" ] ; then
    echo "{ \"{#IS_SLAVE}\":\"\" }"
  elif [ "$version" -ge 10 -a "$isslave" = "f" ] ; then
    slaveslist=$(/usr/bin/psql -qtAX -c 'select client_addr from pg_stat_replication;')
    slavescount=$(echo $slaveslist | wc -w)
    i=1
    for slave in $slaveslist ; do
      echo "{ \"{#IS_MASTER}\":\"$slave\" }"
      if [ $((i++)) -lt $slavescount ] ; then
        echo -n ","
      fi
    done
  fi

  echo " ] } "

else

  #begin json
  echo ' { "data":[ '

  #get databases json
  databases=$(/usr/bin/psql -X -c '\l' | awk '{print $1}' | awk 'NR>3' | grep -e '^\w' | grep -v 'template' | grep -v 'postgres')
  dbcount=$(echo $databases | wc -w)
  i=1
  for db in $databases ; do
    echo -n "{ \"{#NAME}\":\"$db\" }"
    if [ $((i++)) -lt $dbcount ] ; then
      echo -n ","
    fi
    echo ""
  done

  #end json
  echo " ] } "

fi
