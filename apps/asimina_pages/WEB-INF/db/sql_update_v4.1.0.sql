-------------------------------Ahsan Start 4 April 2023-------------------------------

CREATE TABLE locked_items (
  id int(11) auto_increment not null,
  item_id int(11) not null,
  item_type varchar(100) not null,
  site_id int(11) not null,
  is_locked tinyint(1) DEFAULT 0,
  locked_by int(11) DEFAULT 0,
  created_ts datetime NOT NULL default CURRENT_TIMESTAMP(),
  updated_ts datetime NOT NULL default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_locked` (`item_id`,`site_id`,`item_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-------------------------------Ahsan End 4 April 2023-------------------------------

drop table if exists unpublished_pages_applied_files;
create table unpublished_pages_applied_files (
page_id int(11) not null,
bloc_template_id int(11),
bloc_templates_lib_id int(11),
library_id int(11),
file_id int(11) not null,
file_name varchar(500),
file_type varchar(50),
file_update_ts varchar(75),
library_name varchar(500),
page_position varchar(25),
sort_order int(10),
applicable_sort_order int(10),
index idx1 (page_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

drop table if exists published_pages_applied_files;
create table published_pages_applied_files (
page_id int(11) not null,
bloc_template_id int(11),
bloc_templates_lib_id int(11),
library_id int(11),
file_id int(11) not null,
file_name varchar(500),
file_type varchar(50),
file_update_ts varchar(75),
library_name varchar(500),
page_position varchar(25),
sort_order int(10),
applicable_sort_order int(10),
index idx1 (page_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

