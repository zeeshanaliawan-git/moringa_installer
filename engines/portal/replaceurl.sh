#!/bin/sh

echo 1st param : "$1"
echo 2nd param : "$2"
echo 3rd param : "$3"

#echo find "$3" -type f -name '*.html' -exec sed -i 's/'$1'/'$2'/g' {} +
</dev/null >>replacer.log echo find $3 -type f -name '*.html' -exec sed -i 's/'$1'/'$2'/g' {} +
find $3 -type f -name '*.html' -exec sed -i 's/'$1'/'$2'/g' {} +


exit 0
