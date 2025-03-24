-------------------------Ahsan start 9 Feb 2023 ---------------------
alter table pages_tbl modify column social_title varchar(500) NOT null;
alter table pages_tbl modify column title varchar(500) NOT null;

alter table folders_tbl modify column folder_level enum('1','2','3','4') not null default '1';

drop VIEW if exists pages_folders_lang_path;
CREATE VIEW `pages_folders_lang_path` AS select `f`.`site_id` AS `site_id`,`f`.`id` AS `folder_id`,
`fd`.`langue_id` AS `langue_id`,concat_ws('/',nullif(`fd4`.`path_prefix`,''),nullif(`fd3`.`path_prefix`,''),nullif(`fd2`.`path_prefix`,''),nullif(`fd`.`path_prefix`,'')) AS `concat_path`,
`f`.`folder_level` AS `folder_level`,`fd`.`path_prefix` AS `path1`,`fd2`.`path_prefix` AS `path2`,`fd3`.`path_prefix` AS `path3`,`fd4`.`path_prefix` AS `path4` from 
folders `f` join `folders_details` `fd` ON (`fd`.`folder_id` = `f`.`id`) 
left join `folders` `f2` ON (`f`.`parent_folder_id` = `f2`.`id`)
left join `folders_details` `fd2` ON (`fd2`.`folder_id` = `f2`.`id` and `fd`.`langue_id` = `fd2`.`langue_id`)
left join `folders` `f3` ON (`f2`.`parent_folder_id` = `f3`.`id`)
left join `folders_details` `fd3` ON (`fd3`.`folder_id` = `f3`.`id` and `fd`.`langue_id` = `fd3`.`langue_id`)
left join `folders` `f4` ON (`f3`.`parent_folder_id` = `f4`.`id`)  
left join `folders_details` `fd4` ON (`fd4`.`folder_id` = `f4`.`id` and `fd`.`langue_id` = `fd4`.`langue_id`);

ALTER TABLE folders_tbl 
ADD COLUMN dl_page_type varchar(200) NOT NULL DEFAULT '',
ADD COLUMN dl_sub_level_1 varchar(200) NOT NULL DEFAULT '',
ADD COLUMN dl_sub_level_2 varchar(200) NOT NULL DEFAULT '';

DROP VIEW if exists folders;                                        
CREATE VIEW folders AS SELECT * FROM folders_tbl WHERE is_deleted=0;

DROP VIEW if exists pages_folders;                                        
CREATE VIEW pages_folders AS SELECT * FROM folders WHERE type='pages';

DROP VIEW if exists stores_folders;                                        
CREATE VIEW stores_folders AS SELECT * FROM folders WHERE type='stores';

DROP VIEW if exists structured_contents_folders;                                        
CREATE VIEW structured_contents_folders AS SELECT * FROM folders WHERE type='contents';


-------------------------Ahsan End 20 Feb 2023 --------------------- 

rename table pages_tags to pages_tags_v4;
CREATE TABLE `pages_tags` (
  `page_id` int(11) unsigned NOT NULL comment 'for freemarker and structured page this is parent page id whereas for react its id from table pages',
  `page_type` enum('freemarker','react','structured') not null default 'freemarker',
  `tag_id` varchar(100) NOT NULL,
  PRIMARY KEY (`page_id`,`page_type`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into pages_tags (page_id, page_type, tag_id) select distinct p2.parent_page_id, p2.`type`, p1.tag_id from pages_tags_v4 p1 join pages p2 on p2.id = p1.page_id;