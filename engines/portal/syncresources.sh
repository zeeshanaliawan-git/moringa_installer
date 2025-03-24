#!/bin/sh

sourcefolder="${1}"
targetpath="${2}"
targetfolder="${3}"

echo "Source folder : "$sourcefolder"" 
echo "Target path : "$targetpath"" 
echo "Target folder : "$targetfolder"" 

echo "check "$targetpath" exists otherwise create it"
if [ -d "$targetpath" ]; then
	echo ""$targetpath" exists"
else
	echo "we need to create "$targetpath""
	mkdir -p "$targetpath"
fi

echo ""
echo "check "$targetpath""$targetfolder" exists otherwise create it"
if [ -d "$targetpath""$targetfolder" ]; then
	echo ""$targetpath""$targetfolder" exists"
else
	echo "we need to create "$targetpath""$targetfolder""
	mkdir -p "$targetpath""$targetfolder"
fi

echo ""

echo "rsync -ah "$sourcefolder" "$targetpath""$targetfolder" --delete"
rsync -ah "$sourcefolder" "$targetpath""$targetfolder" --delete

echo "done"

exit 0;

