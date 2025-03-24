# this script will be called from the menu designer page for preprod sites only
#!/bin/sh

BASEDIR=$(dirname "$0")
echo "$BASEDIR"
cd "$BASEDIR"
java -cp .:lib/* com/etn/pages/CheckMediaUses Scheduler.conf >> CheckMediaUses.log 2>&1 &

exit 0
