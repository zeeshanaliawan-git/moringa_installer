#!/usr/bin/env bash

now=$(date +"%d-%m-%Y %r")
echo "Started at : $now"

#umask 027

echo "Copy cache"
rsync -avzhe "ssh  -i /home/asimina/.ssh/cache_sync" asimina@127.0.0.1:/home/asimina/tomcat/webapps/asimina_prodportal/sites/ /home/asimina/tomcat/webapps/asimina_prodportal/sites/ --delete

echo "Copy mjs"
rsync -avzhe "ssh  -i /home/asimina/.ssh/cache_sync" asimina@127.0.0.1:/home/asimina/tomcat/webapps/asimina_prodportal/mjs/ /home/asimina/tomcat/webapps/asimina_prodportal/mjs/ --delete

echo "Copy custom css"
rsync -avzhe "ssh  -i /home/asimina/.ssh/cache_sync" asimina@127.0.0.1:/home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/css/custom* /home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/css/ --delete

echo "Copy sitemap"
rsync -avzhe "ssh  -i /home/asimina/.ssh/cache_sync" asimina@127.0.0.1:/home/asimina/tomcat/webapps/asimina_prodportal/generatedSitemap/ /home/asimina/tomcat/webapps/asimina_prodportal/generatedSitemap/ --delete

echo "Copy menu images"
rsync -avzhe "ssh  -i /home/asimina/.ssh/cache_sync" asimina@127.0.0.1:/home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/uploads/ /home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/uploads/ --delete


now=$(date +"%d-%m-%Y %r")
echo "Finished at : $now"
echo "---------------------------------------------------------"
