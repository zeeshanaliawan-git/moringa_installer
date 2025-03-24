#!/bin/bash

dbprefix="${1}"
dbhost="${2}"
dbport="${3}"
dbuser="${4}"
dbpass="${5}"
tomcatpath="${6}"
appprefix="${7}"

echo "dbprefix : "$dbprefix""
echo "db host : "$dbhost""
echo "db port : "$dbport""
echo "db user : "$dbuser""
echo "db pass : "$dbpass""
echo "tomcat path : "$tomcatpath""
echo "appprefix : "$appprefix""

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
TABLE=""$dbprefix"_pages.files"

echo "change directory to "$tomcatpath"webapps/"$appprefix"_pages"
cd ""$tomcatpath"webapps/"$appprefix"_pages"
echo "current directory is "$PWD""

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

uploadsbackupfolder="uploads_bk_$(date +%Y-%m-%d-%H_%M_%S)"

echo "backup folder: "$uploadsbackupfolder""

if [ -d "uploads" ]; then
	# backup
	echo "moving uploads to backup folder "
	mv -f "uploads" ""$uploadsbackupfolder""
	echo "mv command complete"
	mkdir uploads
	echo "empty uploads folder created"
else
	echo "Error!! uploads directory not found"
	exit 1;
fi


for (( i=0 ; i<${cnt} ; i++ ))
do
	echo "site_id = ${results[$i]}"
	mysql -u $dbuser -h $dbhost -P $dbport $cmdpass $DB_NAME << EOF
	INSERT IGNORE INTO $TABLE (file_name, label, type, file_size, images_generated, created_ts, updated_ts, created_by, updated_by, site_id)
		select file_name, label, type, file_size, images_generated, created_ts, updated_ts, created_by, updated_by, ${results[$i]} from $TABLE;
EOF
	if [ ! -d ""$uploadsbackupfolder"/${results[$i]}" ]; then
		mkdir uploads/${results[$i]}/
    	cp -fr "$uploadsbackupfolder"/css uploads/${results[$i]}/css
    	cp -fr "$uploadsbackupfolder"/fonts uploads/${results[$i]}/fonts
    	cp -fr "$uploadsbackupfolder"/img uploads/${results[$i]}/img
    	cp -fr "$uploadsbackupfolder"/js uploads/${results[$i]}/js
    	cp -fr "$uploadsbackupfolder"/other uploads/${results[$i]}/other
    	cp -fr "$uploadsbackupfolder"/video uploads/${results[$i]}/video
    else
    	echo "Site directory already exists"
	fi

	if [ ! -d ""$uploadsbackupfolder"/${results[$i]}/components" ]; then
		if [ -d ""$uploadsbackupfolder"/components/${results[$i]}" ]; then
			cp -fr "$uploadsbackupfolder"/components/${results[$i]}/ uploads/${results[$i]}/components/
		fi
	fi
	if [ ! -d ""$uploadsbackupfolder"/${results[$i]}/component_images" ]; then
		if [ -d ""$uploadsbackupfolder"/component_images" ]; then
			cp -fr "$uploadsbackupfolder"/component_images uploads/${results[$i]}/component_images
		fi
	fi

done

exit 0;