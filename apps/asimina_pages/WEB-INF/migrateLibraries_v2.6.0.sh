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
PAGES_DB_NAME=""$dbprefix"_pages"

($(mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${PAGES_DB_NAME} -e "create table libraries_files_b4_v260 as select * from libraries_files"))

results=($(mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -Bse "select id from sites;"))

mysqlResult=$?
if [ $mysqlResult -ne 0 ]; then
	echo "Error!! in mysql command"
	exit 1;
fi

cnt=${#results[@]}

re='^[0-9]+$'
if [[ ! $cnt =~ $re ]]; then
   echo "Error!! query result not a number : $cnt"
   exit 1;
fi

echo "No of sites : $cnt"

for (( i=0 ; i<${cnt} ; i++ ))
do
	echo "site_id = ${results[$i]}"
	mysql -u $dbuser -h $dbhost -P $dbport $cmdpass $PAGES_DB_NAME << EOF
	INSERT IGNORE INTO libraries_files(file_id, library_id, page_position, sort_order)
	SELECT t1.id, t2.library_id,  t2.page_position, t2.sort_order
	FROM (
		SELECT *
		FROM files
		WHERE site_id = ${results[$i]}
	) t1
	JOIN (
		SELECT f.file_name, lf.library_id, lf.page_position, lf.sort_order
		FROM libraries l
		JOIN libraries_files lf ON l.id = lf.library_id
		JOIN files f ON f.id = lf.file_id
		WHERE l.site_id = ${results[$i]}
		AND f.site_id = 0
	) t2 ON t1.file_name = t2.file_name
	ORDER BY t2.page_position,t2.sort_order;

	DELETE lf
	FROM libraries l
	JOIN libraries_files lf ON l.id = lf.library_id
	JOIN files f ON f.id = lf.file_id
	WHERE l.site_id = ${results[$i]}
	AND f.site_id = 0;

EOF

done

exit 0;