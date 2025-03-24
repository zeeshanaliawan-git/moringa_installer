#!/usr/bin/env bash

echo "-------------------------------------------------------------------------------------"

now=$(date +"%d-%m-%Y %r")
echo "Started at : $now"

#umask 027

echo "START Sync from server 1 to 2"
echo copying prodportal invoices
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodportal/invoices/ /home/obw/tomcat/webapps/botswana_prodportal/invoices/

echo copying prodportal uploads
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodportal/uploads/ /home/obw/tomcat/webapps/botswana_prodportal/uploads/

echo copying prodshop variant_images
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodshop/variant_images/ /home/obw/tomcat/webapps/botswana_prodshop/variant_images/

echo copying form module uploads
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_forms/uploads/ /home/obw/tomcat/webapps/botswana_forms/uploads/


echo "START Sync from server 2 to 1"
echo copying prodportal invoices
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_prodportal/invoices/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodportal/invoices/

echo copying prodportal uploads
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_prodportal/uploads/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodportal/uploads/

echo copying prodshop variant_images
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_prodshop/variant_images/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodshop/variant_images/

echo copying form module uploads
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_forms/uploads/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_forms/uploads/

echo copying form Shop/Prodshop uploads
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_shop/uploads/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_shop/uploads/
rsync -avzhe "ssh -i /home/obw/.ssh/cache_sync" /home/obw/tomcat/webapps/botswana_prodshop/uploads/ obw@192.168.22.141:/home/obw/tomcat/webapps/botswana_prodshop/uploads/

now=$(date +"%d-%m-%Y %r")
echo "Finished at : $now"

echo "-------------------------------------------------------------------------------------"
