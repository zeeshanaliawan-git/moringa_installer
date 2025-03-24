#!/bin/sh

mysql -u devdb -h 127.0.0.1 -P 3306  dev_sync  -e " insert into cache_sync (priority,status,insertion_date,is_forced_sync) values (now(),0,now(),1); select semfree('D099'); "

