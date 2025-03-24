#!/bin/bash

dbprefix="${1}"
dbhost="${2}"
dbport="${3}"
dbuser="${4}"
dbpass="${5}"
semaprefix="${6}"

semaphore=""$semaprefix"04"

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

echo "dbprefix : "$dbprefix""
echo "db host : "$dbhost""
echo "db port : "$dbport""
echo "db user : "$dbuser""
echo "db pass : "$dbpass""
echo "semaphore prefox : "$semaprefix""
echo "semaphore : "$semaphore""

DB_NAME=""$dbprefix"_pages"

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "update pages set to_generate = 1;"
mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "update pages set to_publish = 1, to_publish_ts = now() where coalesce(published_html_file_path,'') <> '';"

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "update structured_contents set to_generate = 1;"
mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "update structured_contents set to_publish = 1, to_publish_ts = now() where publish_status = 'published';"

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -se "select semfree('$semaphore');"
mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -se "select semfree('$semaphore');"

exit;