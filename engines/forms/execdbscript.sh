#!/bin/sh

fname="${1}"
qry="${2}"

echo ""$qry""

mysql -sN -u devdb dev_forms -h 127.0.0.1 -P 3306 -e """$qry""" > ""$fname""

exit 0
