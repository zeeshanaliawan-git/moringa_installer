update dev_commons.config set val = '4.0.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.0.0.1' where code = 'CSS_JS_VERSION';

-------------------Ahsan start 5 March 2023 --------------------

create table tags_folders(
 id int(11) AUTO_INCREMENT,
 uuid varchar(36),
 folder_id varchar(100) not null,
 name varchar(100),
 parent_folder_id int(11) default 0,
 folder_level int(11) default 0,
 site_id int(11),
 is_deleted TINYINT default 0,
 created_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by int(11),
 updated_on DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
 updated_by int(11),
 primary key(id),
 unique key(site_id,parent_folder_id,folder_id,is_deleted)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into config (code,val) values('MAX_TAG_FOLDER_LEVEL',1);

alter table tags add column folder_id varchar(100);

-------------------Ahsan end 8 March 2023 --------------------