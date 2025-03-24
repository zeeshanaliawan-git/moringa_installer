# this script will be called from the menu designer page for preprod sites only
#!/bin/sh

LANG=fr_FR.utf-8
PATH=/home/asimina/bin:/usr/local/bin:/usr/bin:/bin



cd /home/asimina/pjt/asimina_engines/portal
</dev/null 2>&1 >>purger.log java -cp .:lib/* com/etn/eshop/Purger

exit 0
