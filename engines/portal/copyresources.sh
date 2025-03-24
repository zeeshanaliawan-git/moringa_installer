#!/bin/sh

sourcefolder="${1}"
targetpath="${2}"
targetfolder="${3}"
publishedtargetfolder="$targetfolder"_published
backuptargetfolder="$targetfolder"_bkup

echo "Source folder : "$sourcefolder"" 
echo "Target path : "$targetpath"" 
echo "Target folder : "$targetfolder"" 
echo "Published target folder : "$publishedtargetfolder"" 

echo "check targetpath exists otherwise create it ... this is required for very first publication of a new site when that folder won't be there"
if [ -d "$targetpath" ]; then
	echo ""$targetpath" exists"
else
	echo "we need to create "$targetpath""
	mkdir -p "$targetpath"
fi

echo "change directory to "$targetpath""
cd "$targetpath"
echo "current directory is $PWD"

if [ -d "$backuptargetfolder" ]; then
	echo ""$backuptargetfolder" already exists in "$PWD" so we must delete it first "
	rm -rf "$backuptargetfolder"
fi

if [ -d "$publishedtargetfolder" ]; then
	echo ""$publishedtargetfolder" already exists in "$PWD" so we must delete it first "
	rm -rf "$publishedtargetfolder"
fi

echo "copy from "$sourcefolder" to "$targetpath""$publishedtargetfolder""
cp -r  "$sourcefolder" "$targetpath""$publishedtargetfolder"
echo "finished copy to "$publishedtargetfolder""

echo "move "$targetpath""$targetfolder" to "$targetpath""$backuptargetfolder""
mv "$targetpath""$targetfolder" "$targetpath""$backuptargetfolder"

echo "move "$targetpath""$publishedtargetfolder" to "$targetpath""$targetfolder""
mv "$targetpath""$publishedtargetfolder" "$targetpath""$targetfolder"

echo "remove "$targetpath""$backuptargetfolder""
rm -rf "$backuptargetfolder"

echo "done"

exit 0;

