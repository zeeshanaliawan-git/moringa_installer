#!/bin/bash

echo "Enter release version ( example 3.9.0 )"
read rversion

echo "Enter next version ( example 4.0.0 )"
read nextversion

echo "Enter folder to create the release in"
read releasebasedir

echo "Enter svn user"
read svnuser

echo "Enter svn password"
read svnpass

if [ -z "$rversion" ]
then
	echo "Release version must be provided"
	echo "Exit"
	exit 1;
fi

if [ -z "$nextversion" ]
then
	echo "Next version must be provided"
	echo "Exit"
	exit 1;
fi

if [ -z "$releasebasedir" ]
then
	echo "Release base directory must be provided"
	echo "Exit"
	exit 1;
fi

if [ -z "$svnuser" ]
then
	echo "Svn user must be provided"
	echo "Exit"
	exit 1;
fi

if [ -z "$svnpass" ]
then
	echo "Svn password must be provided"
	echo "Exit"
	exit 1;
fi

if [ -d "$releasebasedir" ]; then
	echo ""$releasebasedir" exists"
else
	echo "Release folder does not exists : "$releasebasedir""
	echo "Exit"
	exit 1
fi

cd "$releasebasedir"
echo "current directory : "$PWD""
echo "create version directory : "$rversion""
mkdir "$rversion"

if [ -d "$rversion" ]; then
	echo "release version directory exists"
else
	echo "release version directory does not exists : "$rversion""
	echo "Exit"
	exit 1
fi

cd "$rversion"
releasefolder="$PWD"
echo "current directory : "$releasefolder""
echo "create directory : apps"
mkdir "apps"
echo "create directory : db"
mkdir "db"
echo "create directory : engines"
mkdir "engines"

cd "apps"
echo "current directory : "$PWD""
echo "SVN export apps"

svn export http://178.32.6.105/svn/asimina/dev_catalog/ asimina_catalog --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_catalog"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_expert_system/ asimina_expert_system --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_expert_system"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_forms/ asimina_forms --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_forms"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_menu/ asimina_menu --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_menu"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_pages/ asimina_pages --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_pages"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_portal/ asimina_portal --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_portal"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_prodcatalog/ asimina_prodcatalog --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_prodcatalog"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_prodportal/ asimina_prodportal --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_prodportal"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_prodshop/ asimina_prodshop --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_prodshop"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/dev_shop/ asimina_shop --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting asimina_shop"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/src/ src --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting src"
echo "Exit"
exit 1;
fi

cd "$releasefolder"
echo "current directory : "$PWD""
cd "engines"
echo "current directory : "$PWD""
echo "SVN export engines"

svn export http://178.32.6.105/svn/asimina/engines/cachesync/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting cachesync"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/catalog/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting catalog"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/forms/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting forms"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/pages/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting pages"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/portal/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting portal"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/prodshop/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting prodshop"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/selfcare/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting selfcare"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/shop/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting shop"
echo "Exit"
exit 1;
fi

svn export http://178.32.6.105/svn/asimina/engines/observer/ --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error exporting observer"
echo "Exit"
exit 1;
fi

echo ""
echo "SVN export completed"
echo ""

cd ~/tomcat/webapps/
echo "current directory : "$PWD""

echo "Find all sql_update_dev.sql files"
for fl in $(find . -name "sql_update_dev.sql"); do
NEWNAME=`echo $fl | sed 's/sql_update_dev.sql/sql_update_v'$rversion'.sql/g'`
echo "move file $fl to $NEWNAME"
mv "$fl" "$NEWNAME"
if [[ "$?" != 0 ]]; then
echo "Error moving file "$fl" to "$NEWNAME""
echo "Exit"
exit 1
fi
touch "$fl"
done

echo "Find all sql_update_v"$rversion".sql files"
for fl in $(find . -name "sql_update_v"$rversion".sql"); do
echo "$fl"
svn add "$fl" --non-interactive --username $svnuser --password $svnpass
if [[ "$?" != 0 ]]; then
echo "Error adding "$fl" to svn"
fi
done

echo "VERSION : "$nextversion"" > ./dev_catalog/WEB-INF/release.txt

echo "VERSION : "$nextversion"" > /home/etn/pjt/dev_engines/catalog/release.txt

echo "update dev_commons.config set val = '"$nextversion"' where code = 'APP_VERSION';" >> ./dev_catalog/WEB-INF/db/sql_update_dev.sql
echo "update dev_commons.config set val = '"$nextversion".1' where code = 'CSS_JS_VERSION';" >> ./dev_catalog/WEB-INF/db/sql_update_dev.sql


exit 0;
