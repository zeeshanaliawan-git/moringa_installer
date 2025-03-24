#!/bin/bash

echo "-----------------------------------------------------------------------------------------"
now=$(date +"%d-%m-%Y %r")
echo "Started at : $now"

#umask 027

echo copying shop module mails
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodshop/mail_sms/mail/ /home/obw/tomcat/webapps/botswana_prodshop/mail_sms/mail/ --delete

echo copying form module mails
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_forms/mail_sms/mail/ /home/obw/tomcat/webapps/botswana_forms/mail_sms/mail/ --delete

echo copying uploaded images to botswana_pages
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_pages/uploads/ /home/obw/tomcat/webapps/botswana_pages/uploads/ --delete

echo copying uploaded admin/pages to botswana_pages
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_pages/admin/pages/ /home/obw/tomcat/webapps/botswana_pages/admin/pages/ --delete

echo copying uploaded pages to botswana_pages
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_pages/pages/ /home/obw/tomcat/webapps/botswana_pages/pages/ --delete

echo copying menu images to botswana_portal
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_portal/menu_resources/uploads/ /home/obw/tomcat/webapps/botswana_portal/menu_resources/uploads/ --delete

echo copying custom css to botswana_portal
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_portal/menu_resources/css/custom_* /home/obw/tomcat/webapps/botswana_portal/menu_resources/css/ --delete

echo copying shop module mails
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_shop/mail_sms/mail/ /home/obw/tomcat/webapps/botswana_shop/mail_sms/mail/ --delete

echo copying uploaded themes to pages module
rsync -avzhe "ssh  -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_pages/themes/ /home/obw/tomcat/webapps/botswana_pages/themes/ --delete

now=$(date +"%d-%m-%Y %r")
echo "Finished at : $now"
echo "-----------------------------------------------------------------------------------------"
