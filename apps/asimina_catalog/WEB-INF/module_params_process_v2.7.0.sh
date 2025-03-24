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

DB_NAME=""$dbprefix"_catalog"

echo "$DB_NAME"

procname="moduleparams"

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass $DB_NAME << EOF
insert into rules (start_proc,start_phase,errCode,next_proc,next_phase,nextestado,action,priorite,tipo,rdv,nstate,type) values ('$procname','delete','0','$procname','deleted','0','remove:moduleparams','0','0','And','0','Cancelled');
insert into rules (start_proc,start_phase,errCode,next_proc,next_phase,nextestado,action,priorite,tipo,rdv,nstate,type) values ('$procname','publish','0','$procname','published','0','publish:moduleparams','0','0','And','0','Cancelled');
EOF

results=($(mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -Bse "select cle from rules where start_proc = '$procname' and start_phase = 'delete'"))
cnt=${#results[@]}
if [ 0 = "$cnt" ]
then
	echo "No record found against the rule so exiting"
	exit 1
else
	cle=${results[0]}
	echo "cle: $cle"
	mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "insert into has_action (start_proc,start_phase,cle,action) values ('$procname','delete','$cle','remove:moduleparams');"
fi

results=($(mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -Bse "select cle from rules where start_proc = '$procname' and start_phase = 'publish'"))
cnt=${#results[@]}
if [ 0 = "$cnt" ]
then
	echo "No record found against the rule so exiting"
	exit 1
else
	cle=${results[0]}
	echo "cle: $cle"
	mysql -u $dbuser -h $dbhost -P $dbport $cmdpass ${DB_NAME} -e "insert into has_action (start_proc,start_phase,cle,action) values ('$procname','publish','$cle','publish:moduleparams');"
fi

mysql -u $dbuser -h $dbhost -P $dbport $cmdpass $DB_NAME << EOF
insert into phases (process,phase,topLeftX,topLeftY,visc,isManual,displayName,rulesVisibleTo,reverse,oprType) values ('$procname','cancel','138','418','1','1','cancel last action','ADMIN','R','O');
insert into phases (process,phase,topLeftX,topLeftY,visc,isManual,displayName,rulesVisibleTo,reverse,oprType) values ('$procname','delete','45','282','1','1','delete from prod','ADMIN','R','O');
insert into phases (process,phase,topLeftX,topLeftY,visc,isManual,displayName,rulesVisibleTo,reverse,oprType) values ('$procname','deleted','250','286','1','1','deleted from prod','ADMIN','R','O');
insert into phases (process,phase,topLeftX,topLeftY,visc,isManual,displayName,rulesVisibleTo,reverse,oprType) values ('$procname','publish','28','65','1','1','publish','ADMIN','R','O');
insert into phases (process,phase,topLeftX,topLeftY,visc,isManual,displayName,rulesVisibleTo,reverse,oprType) values ('$procname','published','279','83','1','1','published','ADMIN','R','O');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('28','65','120','80','$procname','ADMIN','publish');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('487','9','128','500','$procname','PROD_CACHE_MGMT','');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('10','10','473','500','$procname','ADMIN','');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('279','83','120','80','$procname','ADMIN','published');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('45','282','120','80','$procname','ADMIN','delete');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('250','286','120','80','$procname','ADMIN','deleted');
insert into coordinates (topLeftX,topLeftY,width,height,process,profile,phase) values ('138','418','120','80','$procname','ADMIN','cancel');
EOF

exit 0