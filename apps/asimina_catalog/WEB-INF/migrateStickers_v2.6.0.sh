#!/bin/bash

dbprefix="${1}"
dbhost="${2}"
dbport="${3}"
dbuser="${4}"
dbpass="${5}"

echo "dbprefix : "$dbprefix""
echo "db host : "$dbhost""
echo "db port : "$dbport""
echo "db user : "$dbuser""
echo "db pass : "$dbpass""

cmdpass=""
if [ -z "$dbpass" ]
then
	cmdpass=""
else
	cmdpass="-p"$dbpass""
fi

if [ -z "$dbhost" ]
then
	dbhost="127.0.0.1"
fi

if [ -z "$dbport" ]
then
	dbport="3306"
fi

DB_NAME=""$dbprefix"_portal"
TABLE=""$dbprefix"_catalog.stickers"

results=($(mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -Bse "select id from sites;"))

cnt=${#results[@]}

for (( i=0 ; i<${cnt} ; i++ ))
do 
echo "site id = ${results[$i]}"

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass $DB_NAME << EOF
INSERT INTO $TABLE (site_id, sname, display_name_1, display_name_2, display_name_3, display_name_4, display_name_5, color, priority)  select ${results[$i]}, "web", "Exclu Web", "Web exclusive", "", "", "", "#ffd600",1  from dual;
INSERT INTO $TABLE (site_id, sname, display_name_1, display_name_2, display_name_3, display_name_4, display_name_5, color, priority)  select ${results[$i]}, "orange", "Exclu Orange", "Orange exclusive", "", "", "", "#ffd600",2  from dual;
INSERT INTO $TABLE (site_id, sname, display_name_1, display_name_2, display_name_3, display_name_4, display_name_5, color, priority)  select ${results[$i]}, "new", "Nouveau", "New", "", "", "", "#4cb4e6",3  from dual;
EOF

done


exit 0