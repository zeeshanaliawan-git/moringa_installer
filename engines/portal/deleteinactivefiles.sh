#!/bin/sh

find $1 -type f -name '*.html_inactive' -exec rm {} +

exit 0
