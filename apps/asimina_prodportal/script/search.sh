#!/bin/bash
cd $1
for i in $(grep -rli $2 *); 
	do 
		ext=$(echo $i | cut -d '.' -f 2)

		if [ $ext = 'html' ] || [ $ext = 'HTML' ]; then
			my_title=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' "$i" ); 
			my_result=$(sed '1,/<\/header>/d;/<div class="etnhf-HomeFooter/,$d' "$i" | sed '/<script/,/<\/script>/{s/.//g}' | sed 's/<[^>]*>//g' | grep -i -m1 $2);
			if [ ${#my_result} != 0 ]; then
	 			output=$(echo $my_result | grep -o -P -i '.{0,'$3'}'$2'.{0,'$3'}');
		 		echo $i"|"$output"__t|"$my_title;
			fi
		fi
done
