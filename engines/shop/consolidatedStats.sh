# this script will be called from the menu designer page for preprod sites only
#!/bin/sh


PATH=/home/etn/bin:/usr/local/bin:/usr/bin:/bin

cd /home/etn/pjt/dev_engines/shop
</dev/null >>consolidatedLogs.log java -cp .:lib/* com/etn/eshop/cron/ConsolidatedStatLog $1

exit 0
