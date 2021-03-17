#!/bin/bash

/usr/bin/psql -qtAX -c  "SELECT version();" | egrep -o "PostgreSQL [-.0-9]+" | egrep -o "[-.0-9]+"
