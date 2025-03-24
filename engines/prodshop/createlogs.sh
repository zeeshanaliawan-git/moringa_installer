#!/bin/bash

directory=""

res=$(mysql -u devdb dev_prod_shop -h 127.0.0.1 -P 3306 -N -e "SELECT val FROM config where code = 'LOGS_DIRECTORY'")
while read line
do
	IFS=$'\t' read -r val  <<< "$line"
	directory=$val
	echo "Logs directory is : "$directory""
done <<< "$(echo -e "$res")"

if [ -z "$directory" ]
then
	echo "LOGS_DIRECTORY config is empty";
	exit 1;
fi


if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    echo "Directory '$directory' created."
else
    echo "Directory '$directory' already exists."
fi

BASEDIR=$(dirname "$0")
cd "$BASEDIR"
echo "current directory : "$PWD""

log_file="sched.log"

if [ "$1" = "previous" ]; then
    search_pattern=$(date -d 'yesterday' +'%d/%m/%Y')
    date_pattern=$(date -d 'yesterday' +'%d-%m-%Y')
    first_line=$(grep -n "$search_pattern" "$log_file" | head -n 1 | cut -d ':' -f 1)
    last_line=$(grep -n "$search_pattern" "$log_file" | tail -n 1 | cut -d ':' -f 1)
    start_line=$((first_line))
    num_lines=$((last_line - first_line))
	echo "${directory}/sched_${date_pattern}.log"
    output_file="${directory}/sched_${date_pattern}.log"
    tail -n +"$start_line" "$log_file" | head -n "$num_lines" > "$output_file"
else
    search_pattern=$(date +'%d/%m/%Y')
    date_pattern=$(date +'%d-%m-%Y')
    first_line=$(grep -n "$search_pattern" "$log_file" | head -n 1 | cut -d ':' -f 1)
    start_line=$((first_line))
	echo "${directory}/sched_${date_pattern}.log"
    output_file="${directory}/sched_${date_pattern}.log"
    tail -n +"$start_line" "$log_file" > "$output_file"
fi

exit 0
