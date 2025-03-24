-- START 27-03-2020 -- 

ALTER TABLE `cart_items`
ADD COLUMN `comewith_excluded`  varchar(100) NULL AFTER `quantity`;

-- END 27-03-2020 -- 

-- START 31-03-2020 -- 
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('UPLOADS_FOLDER', 'uploads/', NULL);
-- END 31-03-2020 -- 


-- START 02-04-2020 -- 

ALTER TABLE `cart`
ADD COLUMN `identityId`  varchar(25) NULL DEFAULT NULL,
ADD COLUMN `name`  varchar(50) NULL DEFAULT NULL,
ADD COLUMN `surnames`  varchar(100) NULL DEFAULT NULL,
ADD COLUMN `contactPhoneNumber1`  varchar(15) NOT NULL,
ADD COLUMN `email`  varchar(64) NULL DEFAULT NULL,
ADD COLUMN `identityType`  varchar(25) NULL DEFAULT NULL,
ADD COLUMN `baline1`  varchar(128) NULL DEFAULT NULL,
ADD COLUMN `baline2`  varchar(128) NULL DEFAULT NULL,
ADD COLUMN `batowncity`  varchar(64) NULL DEFAULT NULL,
ADD COLUMN `bapostalCode`  varchar(5) NULL DEFAULT NULL,
ADD COLUMN `salutation`  char(4) NULL DEFAULT '',
ADD COLUMN `identityPhoto`  varchar(50) NULL,
ADD COLUMN `newPhoneNumber`  varchar(15) NULL;

-- END 02-04-2020 -- 


-- START 04-04-2020 --
alter table site_menus add production_path varchar(255);
alter table cached_pages_path add file_url varchar(500);
alter table cached_pages_path add published_url varchar(500);
alter table cached_pages_path add published_menu_path varchar(500);

alter table cached_pages_path add content_type varchar(25);
alter table cached_pages_path add content_id varchar(50);

-- NOTE ::: BEFORE EXECUTING THIS SCRIPT GET THE VALUE OF SEND_REDIRECT_LINK FROM CONFIG TABLE AND USE THAT 
update cached_pages_path c join cached_pages cp on cp.id = c.id set c.file_url = concat((select val from config where code = 'SEND_REDIRECT_LINK'), c.file_path);
update cached_pages_path c join cached_pages cp on cp.id = c.id set c.published_url = concat(c.file_url, cp.filename);
-- For orange country this is sitename .. check with Umair before running this
update cached_pages_path c join cached_pages cp on cp.id = c.id join site_menus m on m.id = cp.menu_id join sites s on s.id = m.site_id set c.published_menu_path = concat("/", lower(s.name), "/");
-- For other installations .. check with umair
update cached_pages_path c join cached_pages cp on cp.id = c.id join site_menus m on m.id = cp.menu_id join sites s on s.id = m.site_id set c.published_menu_path = concat(substring_index(c.file_url, '/', 4),'/');



alter table crawler_audit change action action varchar(50) not null;
-- only for _portal
update config set val = '/home/ronaldo/pjt/dev_engines/portal/preprodcrawler.sh' where code = 'CRAWLER_SCRIPT';

insert into config (code, val, comments) values ('IGNORE_RELATIVE_URLS','/dev_ckeditor/sites/;/dev_pages/pages/', 'This is used by process.jsp to know which relative url must go through the process.jsp');

alter table site_menus add published_home_url varchar(255);
alter table site_menus add published_404_url varchar(255);

alter table cached_pages add sub_level_1 varchar(255);
alter table cached_pages add sub_level_2 varchar(255);

alter table cached_pages change pagetype pagetype varchar(255);
alter table cached_pages change menuclicked menuclicked varchar(255);

-- Only required in _portal : After running following command make sure there are no french characters in any of site name which will go in production_path .. in that case update column manually
update site_menus m join sites s on s.id = m.site_id set production_path = concat (replace(lower(s.name)," ","-"), "/", m.id , "/", m.lang, "/");
-- END 04-04-2020 --


-- START 15-04-2020 --
insert into config (code,val,comments) values ('COMMON_RESOURCES_URL','/dev_pages/uploads/','Path where all local resources are uploaded. Cache will not cache these');

CREATE TABLE crawler_errors (
  menu_id int(11) NOT NULL,
  err varchar(255),
  created_on timestamp not null default current_timestamp
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 15-04-2020 --

-- START 18-04-2020 --
drop view dev_prod_portal.langue_msg;
drop view dev_prod_portal.language;

create view dev_prod_portal.langue_msg as select * from dev_catalog.langue_msg;
create view dev_prod_portal.language as select * from dev_catalog.language;


-- END 18-04-2020 --


-- START 18-04-2020 ASAD -- 
ALTER TABLE `sites`
ADD COLUMN `geocoding_api`  varchar(100) NULL AFTER `site_auth_enabled`,
ADD COLUMN `googlemap_api`  varchar(100) NULL AFTER `geocoding_api`,
ADD COLUMN `leadformance_api`  varchar(100) NULL AFTER `googlemap_api`,
ADD COLUMN `load_map`  tinyint(1) NULL DEFAULT 0 AFTER `leadformance_api`;

ALTER TABLE `cart`
ADD COLUMN `identityId`  varchar(25) NULL DEFAULT NULL AFTER `session_id`,
ADD COLUMN `name`  varchar(50) NULL DEFAULT NULL AFTER `identityId`,
ADD COLUMN `surnames`  varchar(100) NULL DEFAULT NULL AFTER `name`,
ADD COLUMN `contactPhoneNumber1`  varchar(15) NOT NULL AFTER `surnames`,
ADD COLUMN `email`  varchar(64) NULL DEFAULT NULL AFTER `contactPhoneNumber1`,
ADD COLUMN `identityType`  varchar(25) NULL DEFAULT NULL AFTER `email`,
ADD COLUMN `baline1`  varchar(128) NULL DEFAULT NULL AFTER `identityType`,
ADD COLUMN `baline2`  varchar(128) NULL DEFAULT NULL AFTER `baline1`,
ADD COLUMN `batowncity`  varchar(64) NULL DEFAULT NULL AFTER `baline2`,
ADD COLUMN `bapostalCode`  varchar(5) NULL DEFAULT NULL AFTER `batowncity`,
ADD COLUMN `salutation`  char(4) NULL DEFAULT '' AFTER `bapostalCode`,
ADD COLUMN `identityPhoto`  varchar(50) NULL DEFAULT NULL AFTER `salutation`,
ADD COLUMN `newPhoneNumber`  varchar(15) NULL DEFAULT NULL AFTER `identityPhoto`;

-- END 18-04-2020 --

-- START 25-04-2020 --

alter table config change code code varchar(100) not null;
alter table config CONVERT TO CHARACTER SET  'utf8';

alter table config add primary key (code);

insert into config(code, val, comments) values ('WAIT_TIMEOUT','300','');
insert into config(code, val, comments) values ('DEBUG','Oui','');

insert into config(code, val, comments) values ('SHELL_DIR','/home/ronaldo/pjt/dev_engines/portal/bin','');

insert into config(code, val, comments) values ('PROD_MENU_IMAGES_FOLDER','/home/ronaldo/tomcat/webapps/dev_prodportal/menu_resources/uploads/','');

insert into config(code, val, comments) values ('COPY_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/copyfile.sh','');

insert into config(code, val, comments) values ('MENU_RESOURCES_IMG_URL','/dev_prodportal/menu_resources/img/','');
insert into config(code, val, comments) values ('MENU_PHOTO_URL','/dev_prodportal/menu_resources/uploads/','');
insert into config(code, val, comments) values ('MENU_RESOURCES_URL','/dev_prodportal/menu_resources/','');
insert into config(code, val, comments) values ('PROD_PORTAL_ENTRY_URL','/dev_prodportal','Its the url set in ____portalurl2 at time of caching');

update config set code = 'CACHE_FOLDER' where code = 'SITE_MAP_DOWNLOAD_FOLDER';
update config set code = 'CACHE_EXTERNAL_LINK' where code = 'SITE_MAP_EXTERNAL_LINK';
update config set code = 'PROD_CACHE_FOLDER' where code = 'SITE_MAP_PROD_DOWNLOAD_FOLDER';
update config set code = 'PROD_CACHE_EXTERNAL_LINK' where code = 'SITE_MAP_PROD_EXTERNAL_LINK';
update config set code = 'PROD_SEND_REDIRECT_LINK', val = '/dev_prodportal/sites/' where code = 'SITE_MAP_PROD_REDIRECT_LINK';

delete from config where code = 'SITE_MAP_REDIRECT_LINK';

insert into config(code, val, comments) values ('PREPROD_AUTH_USER','tadmin','');
insert into config(code, val, comments) values ('PREPROD_AUTH_PASSWD','123','');

insert into config(code, val, comments) values ('PROD_AUTH_USER','padmin','');
insert into config(code, val, comments) values ('PROD_AUTH_PASSWD','123','');

insert into config(code, val, comments) values ('DELETE_FILE_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/deletefile.sh','');

insert into config(code, val, comments) values ('MENU_JS_PATH','/home/ronaldo/tomcat/webapps/dev_prodportal/mjs/','');

insert into config(code, val, comments) values ('SYNC_SECOND_SERVER','0','');
insert into config(code, val, comments) values ('CACHE_SYNC_SCRIPT','','');

insert into config(code, val, comments) values ('INTERNAL_CALL_LINK','http://127.0.0.1','');

insert into config(code, val, comments) values ('DEPTH_CONSTRAINT','','Example : 5,http://www.view360client.com;3,https://www.view360client.com');

insert into config(code, val, comments) values ('PROD_SITEMAP_XML_PATH','/home/ronaldo/tomcat/webapps/dev_prodportal/generatedSitemap/','');

insert into config(code, val, comments) values ('PUBLISHER_PROD_BASE_DIR','/home/ronaldo/tomcat/webapps/dev_prodportal/','');
insert into config(code, val, comments) values ('PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER','publishsites/','');

insert into config(code, val, comments) values ('PROD_DOWNLOAD_PAGES_FOLDER','sites/','');

insert into config(code, val, comments) values ('COPY_FOLDER_CONTENTS_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/copyfoldercontents.sh','');

insert into config(code, val, comments) values ('SEPARATE_FOLDER_CACHE_REDIRECT_URL','http://127.0.0.1/dev_portal/publishsites/','');
insert into config(code, val, comments) values ('PROD_SEPARATE_FOLDER_CACHE_REDIRECT_URL','http://127.0.0.1/dev_prodportal/publishsites/','');

insert into config(code, val, comments) values ('CACHE_REDIRECT_URL','http://127.0.0.1/dev_portal/sites/','');
insert into config(code, val, comments) values ('PROD_CACHE_REDIRECT_URL','http://127.0.0.1/dev_prodportal/sites/','');

insert into config(code, val, comments) values ('RENAME_FILE_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/renamefile.sh','');

insert into config(code, val, comments) values ('DELETE_INACTIVE_HTML_FILES_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/deleteinactivefiles.sh','');

insert into config(code, val, comments) values ('AUTO_REFRESH_SYNC_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/copyautorefreshcontent.sh','');

insert into config(code, val, comments) values ('PROD_SITEMAP_CALL_LINK','/dev_prodportal/sites','');

insert into config(code, val, comments) values ('PREPROD_MENU_RESOURCES_URL','/dev_portal/menu_resources/','');
insert into config(code, val, comments) values ('MENU_RESOURCES_URL','/dev_prodportal/menu_resources/','');

insert into config(code, val, comments) values ('MENU_RESOURCES_PATH','/home/ronaldo/tomcat/webapps/dev_prodportal/menu_resources/','');

insert into config(code, val, comments) values ('PROD_CATALOG_DB','dev_prod_catalog','');

delete from config where code = 'CATALOG_LINK';

insert into config(code, val, comments) values ('CATALOG_WEBAPP_URL','/dev_catalog/','');
insert into config(code, val, comments) values ('PROD_CATALOG_WEBAPP_URL','/dev_prodcatalog/','');
insert into config(code, val, comments) values ('PAGES_WEBAPP_URL','/dev_pages/','');
insert into config(code, val, comments) values ('FORMS_WEBAPP_URL','/dev_forms/','');

insert into config(code, val, comments) values ('PROD_PUBLISHER_SEND_REDIRECT_LINK','/dev_prodportal/publishsites/','');

insert into config(code, val, comments) values ('URL_REPLACE_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/replaceurl.sh','');

insert into config(code, val, comments) values ('COMMON_RESOURCES_PATH','/home/ronaldo/tomcat/webapps/dev_pages/uploads/','');

update config set val = '/dev_prodportal/' where code = 'PROD_EXTERNAL_LINK';


insert into config (code, val, comments) values  ('SELFCARE_WAIT_TIMEOUT','300','');
insert into config (code, val, comments) values  ('SELFCARE_DEBUG','Oui','');

insert into config (code, val, comments) values  ('MAIL_FROM','admin@asimina.com','');
insert into config (code, val, comments) values  ('MAIL_FROM_DISPLAY_NAME','Asimina','');
insert into config (code, val, comments) values  ('MAIL_REPLY','noreply@asimina.com','');

insert into config (code, val, comments) values  ('PREPROD_FORGOT_PASS_URL','http://178.32.6.108/dev_portal/pages/resetpass.jsp','');
insert into config (code, val, comments) values  ('PROD_FORGOT_PASS_URL','http://178.32.6.108/dev_prodportal/pages/resetpass.jsp','');

insert into config (code, val, comments) values  ('SMS_MAIL_FROM','','');
insert into config (code, val, comments) values  ('SEND_FORGOT_PASS_SMS','0','');
insert into config (code, val, comments) values  ('SMS_GATEWAY_URL','sms.<phone_number>@syna.activmail.net','');
insert into config (code, val, comments) values  ('SMS_DEFAULT_COLUMN','mobile_number','');

insert into config (code, val, comments) values ('CACHESYNC_WAIT_TIMEOUT','300','');
insert into config (code, val, comments) values ('CACHESYNC_DEBUG','Oui','');
insert into config (code, val, comments) values ('CACHESYNC_SEMAPHORE','sync','');
insert into config (code, val, comments) values ('CACHESYNC_SCRIPT','/home/ronaldo/pjt/dev_engines/cachesync/replication','');


CREATE TABLE `cached_content` (
  `cached_page_id` int(11) NOT NULL,
  `published_url` varchar(500) DEFAULT NULL,
  `content_type` varchar(25) DEFAULT NULL,
  `content_id` varchar(50) DEFAULT NULL,
  `published_menu_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`cached_page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table site_menus add published_404_cached_id varchar(255);
alter table site_menus add published_hp_cached_id varchar(255);

-- END 25-04-2020 --

-- START 07-05-2020 --

CREATE TABLE `client_usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_agent` text,
  `details` varchar(255) DEFAULT NULL,
  `url` varchar(255) default null,
  `site_id` int(10),
   INDEX `activity_from` (`activity_from`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 07-05-2020 --

-- START 11-05-2020 --
alter table crawler_paths add is_page_link tinyint(1) not null default 0;

-- END 11-05-2020 --


-- START 15-05-2020 --

alter table site_menus change search_api search_api enum('internal','external','url');

update site_menus set search_completion_url = search_completion_prod_url;
update site_menus set search_params = search_prod_params;
update site_menus set search_bar_url = prod_search_bar_url;

alter table site_menus drop column search_completion_prod_url;
alter table site_menus drop column search_prod_params;
alter table site_menus drop column prod_search_bar_url;

-- END 15-05-2020 --