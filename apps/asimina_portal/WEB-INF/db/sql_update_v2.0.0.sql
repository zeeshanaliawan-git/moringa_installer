alter table site_menus add search_completion_url varchar(500);
alter table site_menus add search_completion_prod_url varchar(500);

alter table post_work change status status int(1) not null default 0;

alter table site_menus add header_html_1 text;
alter table site_menus add footer_html_1 text;

alter table cached_pages add is_404_page tinyint(1) NOT NULL DEFAULT '0';
alter table folders drop key `name`;
alter table folders change name name text;
alter table folders add hex_name varchar(255);
alter table folders add name2 text;
update folders set hex_name = hex(sha(name));
alter table folders add unique key `name` (hex_name);

alter table menu_items change open_as open_as enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url') default null;

CREATE TABLE `purge_pages` (
  `page_path` varchar(500) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table site_menus change find_a_store_open_as find_a_store_open_as enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url') DEFAULT NULL;
alter table site_menus change contact_us_open_as contact_us_open_as enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url') DEFAULT NULL;
alter table site_menus add menu_uuid varchar(50) not null;
update site_menus set menu_uuid = UUID();
alter table site_menus add unique key `menu_uuid` (`menu_uuid`);

CREATE TABLE `sitemap_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(75) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` text,
  `success` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `crawler_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  menu_id int(11) not null,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  start_time datetime,
  end_time datetime,
  `status` int(1) not null default 0,
  `action` varchar(15) not null,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;




CREATE TABLE `generic_forms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_name` text,
  `form_data` mediumtext,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `email_tries` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


alter table site_menus add search_params varchar(255) DEFAULT NULL;
alter table site_menus add search_prod_params varchar(255) DEFAULT NULL;
alter table site_menus add logo_file varchar(255) DEFAULT NULL;
alter table site_menus add favicon varchar(255) DEFAULT NULL;

alter table site_menus add domain varchar(100) ;

alter table sites add domain varchar(100) ;

alter table site_menus add javascript_filename varchar(100);


alter table site_menus add tmp_header_html text;
alter table site_menus add tmp_footer_html text;

insert into config (code, val) values ('separate_folder_caching',1);

alter table cached_pages add crawled_attempts int default 0;

alter table cached_pages add is_url_active tinyint(1) not null default 1;

alter table redirects add menu_type enum('b2c','b2b') default 'b2c';
alter table redirects change menu_type menu_type varchar(10) not null;

alter table site_menus add business_type varchar(5) not null;

-- on needed in portal not in prod_portal
create view business_types as select * from dev_catalog.business_types;

alter table cached_pages add last_time_url_active tinyint(1) not null default 0;

-- END of v1.2.5 ---------------------------------------------------------

alter table site_menus add search_api enum('internal','external') ;


alter table site_menus add enable_cart tinyint(0) not null default 0;

drop table generic_forms;

alter table clients add is_super_user tinyint(1) not null default 0;

alter table menu_items change url url varchar(255) ;
alter table additional_menu_items change url url varchar(255);
alter table site_menus change updated_by updated_by int(10) ;

alter table clients add first_time_pass varchar(15);
alter table clients add first_pass_sent tinyint(1) not null default 0;

 CREATE TABLE `client_programs` (
  `id_client` int(11) NOT NULL,
  `program_name` varchar(255) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_client`,`program_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


alter table site_menus add 404_url varchar(255);
alter table site_menus add prod_404_url varchar(255);


-- smart banner --
alter table site_menus add use_smart_banner tinyint(1) not null default 0;

ALTER TABLE `clients`
ADD COLUMN `mobile_number`  varchar(25) NULL AFTER `surname`;

insert into clients (email, name, pass, is_verified, is_super_user) values ('su@asimina.com','Super Admin', MD5('superuser123$'), 1, 1);

alter table clients add client_uuid varchar(75) default null;
alter table clients add unique key `client_uuid` (client_uuid);


ALTER TABLE `clients`
ADD COLUMN `profil`  varchar(50) NULL AFTER `client_uuid`;


-- 4 Jan 2018 (Abdul Rehman)---
-- this table only in preprod portal ---
CREATE TABLE `co_form_fields` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `co_form_id` int(11) DEFAULT NULL,
  `co_field_name` varchar(255) DEFAULT NULL,
  `co_field_display_name` varchar(255) DEFAULT NULL,
  `co_field_type` varchar(15) DEFAULT NULL,
  `co_field_length` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `co_form_fields` VALUES (1, 1, 'name', 'Firstname', 'text', '12');
INSERT INTO `co_form_fields` VALUES (2, 1, 'surnames', 'Lastname', 'text', '12');
INSERT INTO `co_form_fields` VALUES (3, 1, 'contactPhoneNumber1', 'Phone No.', 'tel', '12');
INSERT INTO `co_form_fields` VALUES (4, 1, 'email', 'Email', 'email', '12');
INSERT INTO `co_form_fields` VALUES (5, 1, 'batowncity', 'City', 'text', '12');
INSERT INTO `co_form_fields` VALUES (6, 1, 'bapostalCode', 'Postal Code', 'text', '12');
INSERT INTO `co_form_fields` VALUES (7, 1, 'identityType', 'Identity Type', 'text', '12');
INSERT INTO `co_form_fields` VALUES (8, 1, 'identityId', 'Identity Id', 'select', '');
INSERT INTO `co_form_fields` VALUES (9, 1, 'Civilite', 'Civilite', 'select', '');
INSERT INTO `co_form_fields` VALUES (10, 1, 'baline1', 'Address 1', 'text', '12');
INSERT INTO `co_form_fields` VALUES (11, 1, 'baline2', 'Address 2', 'text', '12');

CREATE TABLE `co_form_settings` (
  `co_form_id` int(11) DEFAULT NULL,
  `site_id` varchar(255) DEFAULT NULL,
  `menu_id` varchar(255) DEFAULT NULL,
  `co_field_json` text,
  `co_msg_receipt` varchar(255) DEFAULT NULL,
  `co_order_ref_label` varchar(255) DEFAULT NULL,
  `co_order_date_label` varchar(255) DEFAULT NULL,
  `co_total_amount_label` varchar(255) DEFAULT NULL,
  `co_show_order_detail` varchar(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 4 Jan 2018 (Abdul Rehman)---


-- START 24-01-2018 --
insert into config (code, val) values ('app_version','1.2.5');
-- END 24-01-2018 --


-- START 01-02-2018 --

-- NOTE :: This table is only required in _portal not in _prod_portal

CREATE TABLE `custom_css` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) NOT NULL,
  `element_id` varchar(100) NOT NULL,
  `tag` varchar(255) NOT NULL,
  `css` text,
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table config add primary key (code);

-- END 01-02-2018 --

-- START 02-04-2018 --

alter table cached_pages add file_path varchar(255);


-- END 02-04-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 14-MAR-2018 ----------------------------------

-- START 23-04-2018 --
CREATE TABLE `crawler_paths` (
  `menu_id` int(11) NOT NULL,
  `parent_page_url` varchar(255) NOT NULL,
  `page_url` varchar(255) NOT NULL,
  `is_menu_link` tinyint(1) not null default 0,
  `is_homepage_link` tinyint(1) not null default 0,
  `is_404` tinyint(1) not null default 0,
  `page_level` int(10) not null,
  index (`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 23-04-2018 --




-- START 24-04-2018 --

alter table cached_pages drop file_path;

CREATE TABLE `cached_pages_path` (
  `id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  primary key(`id`),
  index (`file_path`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- END 24-04-2018 --

-- START 03-05-2018 --

alter table crawler_paths add parent_page_id int(11) not null after menu_id;
alter table crawler_paths add page_id int(11) not null after parent_page_id;
alter table crawler_paths drop parent_page_url;
alter table crawler_paths drop page_url;
-- END 03-05-2018 --

-- START 21-05-2018 --

alter table cached_pages add refresh_minutes int not null  default 0;

-- END 21-05-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 22-MAY-2018 ----------------------------------


-- START 30-05-2018 --

update config set val = '1.3' where code = 'app_version';

-- END 30-05-2018 --


---------------------------------------- TEMPLATE UPDATED TILL HERE 30-MAY-2018 ----------------------------------

-- START 25-06-2018 --

alter table stat_log change menu_id menu_uuid varchar(50);

alter table sites add default_menu_id int(10) default null;

alter table site_menus drop domain ;

alter table config change val val text;

//change this config according to each server, domain..... this config will be a semi-colon separated list of urls to be ignored at time of encoding to avoid looping
insert into config  values ('ignore_urls_for_encode','http://178.32.6.108');

-- END 25-06-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 25-JUN-2018 ----------------------------------


-- START 09-08-2018 --
drop view login;
create view login as select * from dev_catalog.login;
-- END 09-08-2018 --


---------------------------------------- TEMPLATE UPDATED TILL HERE 17-AUG-2018 ----------------------------------

-- START 03-09-2018 --
alter table site_menus add logo_url varchar(255);
-- END 03-09-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 03-SEP-2018 ----------------------------------


-- START 11-09-2018 --
create table faq_stats
(
url varchar(255) not null,
menu_uuid varchar(36) not null,
title varchar(255) default null,
ourl varchar(255) default null,
count_yes int default 0,
count_no int default 0,
update_on timestamp not null default current_timestamp,
primary key(url, menu_uuid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table site_menus add deleted tinyint(1) not null default 0;

-- END 11-09-2018 --


-- START 10-10-2018 --
alter table sites add version int(10) not null default 0;
alter table site_menus add version int(10) not null default 0;
-- END 10-10-2018 --

-- START 18-10-2018 --
update config set val = '1.4' where code = 'app_version';
-- END 18-10-2018 --

--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- senegal updated till here on 19 OCT 2018 ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

-- START 24-10-2018 --

-- these are configuratinos for orange money
-- need to be manually updated accordingly to the merchant's OM account
-- if orange_money is to be used as payment_option
INSERT INTO `config` (code,val) VALUES ('orange_scrt', 'R1dOMVJqTGoydFJYVFk4SmlHcWRIbGV0VTRWT25PdTI6Nzd3Tjg2YzhtS1Rhb2R3Rg==');
INSERT INTO `config` (code,val) VALUES ('orange_merchant_key', '1850c3ba');
INSERT INTO `config` (code,val) VALUES ('orange_merchant_reference', 'Asimina Merchant Dev');
INSERT INTO `config` (code,val) VALUES ('orange_access_expire_ts', '');
INSERT INTO `config` (code,val) VALUES ('orange_access_token', '');
INSERT INTO `config` (code,val) VALUES ('orange_currency', 'OUV');
INSERT INTO `config` (code,val) VALUES ('orange_lang', 'en');
INSERT INTO `config` (code,val) VALUES ('orange_api_token', 'https://api.orange.com/oauth/v2/token');
INSERT INTO `config` (code,val) VALUES ('orange_api_webpayment', 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment');
INSERT INTO `config` (code,val) VALUES ('orange_api_transactionstatus', 'https://api.orange.com/orange-money-webpay/dev/v1/transactionstatus');
-- END 24-10-2018 --

-- START 20-11-2018 --
-- these are configuratinos for paypal
-- need to be manually updated accordingly to the merchant's OM account
-- if paypal is to be used as payment_option
INSERT INTO `config` (code,val) VALUES ('paypal_env', 'sandbox');
INSERT INTO `config` (code,val) VALUES ('paypal_scrt', 'dummyEJqptdAX8FIPfC5VxdAhFLuaA0Avv');
INSERT INTO `config` (code,val) VALUES ('paypal_client_key', 'dummyAUXcWMsSnEDnwe');
INSERT INTO `config` (code,val) VALUES ('paypal_merchant_reference', 'Asimina Merchant Dev');
INSERT INTO `config` (code,val) VALUES ('paypal_access_expire_ts', '');
INSERT INTO `config` (code,val) VALUES ('paypal_access_token', '');
INSERT INTO `config` (code,val) VALUES ('paypal_currency', 'USD');
INSERT INTO `config` (code,val) VALUES ('paypal_api_url', 'https://api.sandbox.paypal.com/');
INSERT INTO `config` (code,val) VALUES ('paypal_locale', 'US');
-- END 20-11-2018 --

-- START 26-12-2018 --
alter table site_menus add smartbanner_position enum ('top','bottom') default 'top';
alter table site_menus add smartbanner_days_hidden int(10) not null default 15;
alter table site_menus add smartbanner_days_reminder int(10) not null default 30;
-- END 26-12-2018 --


-- START 18-01-2019 --
delete from config where code = 'app_version';
-- END 18-01-2019 --


-- START 30-01-2019 --
create table co_form_settings_bkup as select * from co_form_settings;
delete from co_form_settings;
alter table co_form_settings drop co_form_id;
alter table co_form_settings drop menu_id;
alter table co_form_settings add primary key (site_id);
--- NOTE :: This query might give primary key error so just ignore it -----
insert into co_form_settings (site_id, co_field_json, co_msg_receipt, co_order_ref_label, co_order_date_label, co_total_amount_label, co_show_order_detail) select site_id, co_field_json, co_msg_receipt, co_order_ref_label, co_order_date_label, co_total_amount_label, co_show_order_detail from co_form_settings_bkup;
-- END 30-01-2019 --


-- START 11-03-2019 --
alter table menu_items add display_in_header tinyint(1) not null default 1;
-- END 11-03-2019 --


-- START 26-03-2019 --
--- NOTE: following statements has db name as we want this particular insert in _portal and separate one for _prodportal as they have different values
insert into dev_portal.config (code, val) values ('PASS_LANG_URLS','http://127.0.0.1/dev_catalog/;http://127.0.0.1/dev_forms/');
insert into dev_prod_portal.config (code, val) values ('PASS_LANG_URLS','http://127.0.0.1/dev_prodcatalog/;http://127.0.0.1/dev_forms/');

NOTE::: After creating this table fix the menu_type column in original redirects table
create table redirects_bkup select * from redirects;

alter table site_menus drop business_type;
drop view business_types;

insert into config (code, val) values ('LOGGER_LEVEL','info');

--NOTE:Countries with multiple active servers will have stat_log table in separate db and a view in _portal and _prodportal
create table stat_log_bkup as select * from stat_log;
truncate stat_log;
alter table stat_log add has_internet tinyint(1) not null default 1;
--this field will be used for combining stat_logs from multiple active servers otherwise it has no significance
alter table stat_log add server_num int(10) not null default 1 comment 'For multiple active servers its value will be filled accordingly at time of syncing otherwise its always 1 by default';
alter table stat_log drop PRIMARY KEY;
alter table stat_log add PRIMARY KEY (`date_l`,`ip`,`session_j`,`server_num`);
alter table stat_log change ip ip varchar(50) comment 'Countries with multiple servers might have multiple ips coming in due to load balancer';

alter table sites add enable_ecommerce tinyint(1) not null default 0;

alter table clients add forgot_password tinyint(1) not null default 0;
alter table clients add forgot_pass_token varchar(36) default null;
alter table clients add forgot_pass_token_expiry datetime default null;
alter table clients add forgot_pass_muid varchar(36) default null;

alter table sites add datalayer_domain varchar(255);
alter table sites add datalayer_brand varchar(255);
alter table sites add datalayer_market varchar(255);

alter table cached_pages add ptitle varchar(255);
alter table cached_pages add breadcrumb varchar(255);

-- END 26-03-2019 --

-- START 12-06-2019 --
alter table cached_pages add res_file_extension varchar(15);
alter table menu_items add is_right_align tinyint(1) default 0 comment 'This field will only be effective for header level 1 menu items. For languages rtl like arabic or urdu right_align means it will be left align actually';
-- END 12-06-2019 --


-- START 12-07-2019 --
create table auth_tokens
(
id varchar(36) not null,
validator varchar(64) not null,
client_uuid varchar(36) not null,
expiry datetime not null,
primary key(id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table sites add enable_cache tinyint(1) default 0 not null;
update sites set enable_cache  = 1;

delete from config where code = 'cache';
delete from config where code = 'separate_folder_caching';

alter table menu_items add link_label varchar(255) default null comment 'This label will only be shown if a link is added to level -20 item or its immediate child so we will add special links for it in new ui';

alter table site_menus add small_logo_file varchar(255);
-- END 12-07-2019 --

-- START 02-08-2019 --
alter table cached_pages drop breadcrumb;
alter table cached_pages_path add breadcrumb varchar(255);
alter table cached_pages_path add breadcrumb_changed tinyint(1) not null default 0; 

INSERT INTO `coordinates` VALUES (61,73,120,80,'breadcrumbs','ADMIN','publish'),(11,11,738,500,'breadcrumbs','ADMIN',NULL),(486,75,120,80,'breadcrumbs','ADMIN','published'),(280,274,120,80,'breadcrumbs','ADMIN','cancel'),(732,538,300,500,'breadcrumbs','PROD_CACHE_MGMT',NULL),(1151,540,300,500,'breadcrumbs','PROD_PUBLISH',NULL);
INSERT INTO `has_action` VALUES ('breadcrumbs','publish',5,'publish:breadcrumbs');
INSERT INTO `phases` VALUES ('breadcrumbs','cancel',291,371,NULL,NULL,'','','','','',NULL,'',1,1,'cancel','ADMIN','R','O'),('breadcrumbs','publish',96,64,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('breadcrumbs','published',314,89,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O');
INSERT INTO `rules` VALUES ('breadcrumbs','publish',0,'breadcrumbs','published',0,'publish:breadcrumbs',0,5,0,'And','0','Cancelled');


-- END 02-08-2019 --

-- START 09-08-2019 -- 
CREATE TABLE `cart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` varchar(50) DEFAULT NULL,
  `session_id` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cart_id` int(11) NOT NULL,
  `variant_id` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table sites add facebook_app_id varchar(50);
alter table sites add twitter_account varchar(50);

-- END 09-08-2019 --

-- START 04-10-2019 --

alter table menu_items add menu_icon varchar(75);
alter table menu_items change menu_photo menu_photo varchar(75);
-- END 04-10-2019 --


-- START 07-10-2019 --
alter table dev_portal.config add comments text;

insert into dev_portal.config (code, val, comments) values ('BASE_DIR','/home/ronaldo/tomcat/webapps/dev_portal/', 'This is used in dev_portal so do not update for dev_menu');
insert into dev_portal.config (code, val, comments) values ('BASE_DIR_MENU_DESIGNER','/home/ronaldo/tomcat/webapps/dev_menu/', 'This is used in dev_menu');
insert into dev_portal.config (code, val) values ('DOWNLOAD_PAGES_FOLDER','sites/');
insert into dev_portal.config (code, val) values ('MENU_IMAGES_FOLDER','/home/ronaldo/tomcat/webapps/dev_portal/menu_resources/uploads/');
insert into dev_portal.config (code, val) values ('MENU_IMAGES_PATH','/menu_resources/uploads/');
insert into dev_portal.config (code, val) values ('EXTERNAL_LINK','/dev_portal/');
insert into dev_portal.config (code, val) values ('PROD_EXTERNAL_LINK','/dev_prodportal/');
insert into dev_portal.config (code, val) values ('PROD_DB','dev_prod_portal');
insert into dev_portal.config (code, val) values ('IS_PRODUCTION_ENV','0');
insert into dev_portal.config (code, val) values ('MORINGA_MENU_EXTERNAL_LINK','/dev_menu/');
insert into dev_portal.config (code, val) values ('URL_GENERATOR','/dev_catalog/admin/urlgenerator.jsp');
insert into dev_portal.config (code, val) values ('SEMAPHORE','D002');
insert into dev_portal.config (code, val) values ('SITE_MAP_EXTERNAL_LINK','/dev_portal/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_DOWNLOAD_FOLDER','/home/ronaldo/tomcat/webapps/dev_portal/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_REDIRECT_LINK','/dev_portal/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_PROD_EXTERNAL_LINK','/dev_prodportal/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_PROD_DOWNLOAD_FOLDER','/home/ronaldo/tomcat/webapps/dev_prodportal/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_PROD_REDIRECT_LINK','/sites/');
insert into dev_portal.config (code, val) values ('SITE_MAP_RENAME_SCRIPT_PATH','/home/ronaldo/tomcat/webapps/dev_menu/pages/sitemap/');
insert into dev_portal.config (code, val) values ('CRAWLER_SCRIPT','/home/ronaldo/pjt/dev_engines/portal/preprodcrawler.sh');
insert into dev_portal.config (code, val) values ('CUSTOM_CSS_TEMPLATE_PATH','/home/ronaldo/tomcat/webapps/dev_menu/pages/customcss/');
insert into dev_portal.config (code, val) values ('CSS_CUSTOMIZER_SCRIPT','/home/ronaldo/tomcat/webapps/dev_menu/pages/customcss/customizecss.sh');
insert into dev_portal.config (code, val) values ('PREPROD_CSS_FINAL_PATH','/home/ronaldo/tomcat/webapps/dev_portal/menu_resources/css/');
insert into dev_portal.config (code, val) values ('PROD_CSS_FINAL_PATH','/home/ronaldo/tomcat/webapps/dev_prodportal/menu_resources/css/');
insert into dev_portal.config (code, val) values ('DB_NAME','dev_portal');
insert into dev_portal.config (code, val) values ('DB_USER','root');
insert into dev_portal.config (code, val) values ('DB_PASS','Arobaz2014');
insert into dev_portal.config (code, val) values ('CATALOG_ROOT','/dev_catalog');
insert into dev_portal.config (code, val) values ('CATALOG_DB','dev_catalog');
insert into dev_portal.config (code, val) values ('GOTO_MENU_APP_URL','/dev_catalog/admin/gotomenuapp.jsp');
insert into dev_portal.config (code, val) values ('DYNAMIC_PAGES','');
insert into dev_portal.config (code, val) values ('CATALOG_LINK','/dev_catalog/');
insert into dev_portal.config (code, val) values ('SEND_REDIRECT_LINK','/dev_portal/sites/');
insert into dev_portal.config (code, val) values ('LOCAL_LINK','http://127.0.0.1/dev_portal/');
insert into dev_portal.config (code, val) values ('VALID_404_URLS','');
insert into dev_portal.config (code, val) values ('basic_auth_realm','dev-test-site');
insert into dev_portal.config (code, val) values ('NO_PROCESS_JS','/dev_catalog/js/o_share_bar.js;/dev_forms/js/html_form_template.js;/dev_forms/js/triggers.js;/dev_catalog/js/nocache/;/dev_catalog/js/fullcalendar.min.js;/dev_catalog/js/newui/;');
insert into dev_portal.config (code, val) values ('NO_CACHE_JS','/dev_portal/js/contactus.js');
insert into dev_portal.config (code, val) values ('PORTAL_CONTEXTPATH','/dev_portal/');
insert into dev_portal.config (code, val) values ('CART_COOKIE','dev_catalogCartItems');
insert into dev_portal.config (code, val) values ('PRODUCTS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/products/');
insert into dev_portal.config (code, val) values ('PRODUCTS_IMG_PATH','/dev_catalog/uploads/products/');
insert into dev_portal.config (code, val) values ('SHOP_DB','dev_shop');
insert into dev_portal.config (code, val) values ('PORTAL_LINK','/dev_portal');
insert into dev_portal.config (code, val) values ('PUBLISHER_BASE_DIR','/home/ronaldo/tomcat/webapps/dev_portal/');
insert into dev_portal.config (code, val) values ('PUBLISHER_DOWNLOAD_PAGES_FOLDER','publishsites/');
insert into dev_portal.config (code, val) values ('PUBLISHER_SEND_REDIRECT_LINK','/dev_portal/publishsites/');
insert into dev_portal.config (code, val) values ('PORTAL_SEARCH_SHELL_SCRIPT','/home/ronaldo/tomcat/webapps/dev_portal/script/');
insert into dev_portal.config (code, val) values ('CALL_BACK_API_SHELL_SCRIPT','/home/ronaldo/tomcat/webapps/dev_portal/APICallBack/');
insert into dev_portal.config (code, val) values ('CART_EXTERNAL_LINK','/dev_portal/cart/');
insert into dev_portal.config (code, val) values ('GENERIC_FORM_DEFAULT_PROCESS','genericforms');
insert into dev_portal.config (code, val) values ('GENERIC_FORM_DEFAULT_PHASE','formsubmitted');
insert into dev_portal.config (code, val) values ('SHOP_SEMAPHORE','D005');
insert into dev_portal.config (code, val) values ('SITEMAP_SEND_REDIRECT_LINK','/dev_portal/sites/');
insert into dev_portal.config (code, val) values ('SMART_BANNER_ICON_URL','/dev_prodportal/img/smartbanner/');
insert into dev_portal.config (code, val) values ('SUPER_USER_REG_FORM_URL','');
insert into dev_portal.config (code, val) values ('SEND_SESSION_PARAMS','http://127.0.0.1/dev_expert_system/');
insert into dev_portal.config (code, val, comments) values ('PROXY_PREFIX','','When in production we have urls like /particuliars /business which are then routed to /2/sites/particuliar /2/sites/business ... so in that case the redirections added must be checked along with proxy prefix');
insert into dev_portal.config(code,val) values ('COMMONS_DB','dev_commons');

alter table dev_prod_portal.config add comments text;

insert into dev_prod_portal.config(code,val) values ('BASE_DIR','/home/ronaldo/tomcat/webapps/dev_prodportal/');
insert into dev_prod_portal.config(code,val) values ('DOWNLOAD_PAGES_FOLDER','sites/');
insert into dev_prod_portal.config(code,val) values ('MENU_IMAGES_FOLDER','/home/ronaldo/tomcat/webapps/dev_prodportal/menu_resources/uploads/');
insert into dev_prod_portal.config(code,val) values ('MENU_IMAGES_PATH','/menu_resources/uploads/');
insert into dev_prod_portal.config(code,val) values ('EXTERNAL_LINK','/dev_prodportal/');
insert into dev_prod_portal.config(code,val) values ('IS_PRODUCTION_ENV','1');
insert into dev_prod_portal.config(code,val) values ('DYNAMIC_PAGES','');
insert into dev_prod_portal.config(code,val) values ('CATALOG_LINK','/dev_prodcatalog/');
insert into dev_prod_portal.config(code,val) values ('SEND_REDIRECT_LINK','/dev_prodportal/sites/');
insert into dev_prod_portal.config(code,val) values ('LOCAL_LINK','http://127.0.0.1/dev_prodportal/');
insert into dev_prod_portal.config(code,val) values ('VALID_404_URLS','');
insert into dev_prod_portal.config(code,val) values ('basic_auth_realm','dev-prod-site');
insert into dev_prod_portal.config(code,val) values ('NO_PROCESS_JS','/dev_prodcatalog/js/o_share_bar.js;/dev_forms/js/html_form_template.js;/dev_forms/js/triggers.js;/dev_prodcatalog/js/nocache/;/dev_prodcatalog/js/fullcalendar.min.js;/dev_prodcatalog/js/newui/;');
insert into dev_prod_portal.config(code,val) values ('NOCACHE_JS','/dev_prodportal/js/contactus.js');
insert into dev_prod_portal.config(code,val) values ('PORTAL_CONTEXTPATH','/dev_prodportal/');
insert into dev_prod_portal.config(code,val) values ('CART_COOKIE','dev_prodcatalogCartItems');
insert into dev_prod_portal.config(code,val) values ('PRODUCTS_IMG_PATH','/dev_prodcatalog/uploads/products/');
insert into dev_prod_portal.config(code,val) values ('CATALOG_DB','dev_prod_catalog');
insert into dev_prod_portal.config(code,val) values ('SHOP_DB','dev_prod_shop');
insert into dev_prod_portal.config(code,val) values ('PORTAL_LINK','/dev_prodportal');
insert into dev_prod_portal.config(code,val) values ('PUBLISHER_BASE_DIR','/home/ronaldo/tomcat/webapps/dev_prodportal/');
insert into dev_prod_portal.config(code,val) values ('PUBLISHER_DOWNLOAD_PAGES_FOLDER','publishsites/');
insert into dev_prod_portal.config(code,val) values ('PUBLISHER_SEND_REDIRECT_LINK','/dev_prodportal/publishsites/');
insert into dev_prod_portal.config(code,val) values ('PORTAL_SEARCH_SHELL_SCRIPT','/home/ronaldo/tomcat/webapps/dev_prodportal/script/');
insert into dev_prod_portal.config(code,val) values ('CALL_BACK_API_SHELL_SCRIPT','/home/ronaldo/tomcat/webapps/dev_prodportal/APICallBack/');
insert into dev_prod_portal.config(code,val) values ('CART_EXTERNAL_LINK','/dev_prodportal/cart/');
insert into dev_prod_portal.config(code,val) values ('GENERIC_FORM_DEFAULT_PROCESS','genericforms');
insert into dev_prod_portal.config(code,val) values ('GENERIC_FORM_DEFAULT_PHASE','formsubmitted');
insert into dev_prod_portal.config(code,val) values ('SHOP_SEMAPHORE','D006');
insert into dev_prod_portal.config(code,val) values ('SITEMAP_SEND_REDIRECT_LINK','/dev_prodportal/sites/');
insert into dev_prod_portal.config(code,val) values ('SMART_BANNER_ICON_URL','/dev_prodportal/img/smartbanner/');
insert into dev_prod_portal.config(code,val) values ('SUPER_USER_REG_FORM_URL','');
insert into dev_prod_portal.config(code,val) values ('SEND_SESSION_PARAMS','http://127.0.0.1/dev_expert_system/');
insert into dev_prod_portal.config(code,val,comments) values ('PROXY_PREFIX','','When in production we have urls like /particuliars /business which are then routed to /2/sites/particuliar /2/sites/business ... so in that case the redirections added must be checked along with proxy prefix');
insert into dev_prod_portal.config(code,val) values ('COMMONS_DB','dev_commons');

-- END 07-10-2019 --

-- START 05-11-2019 --
alter table site_menus add hide_header tinyint(1) not null default 0;
alter table site_menus add hide_footer tinyint(1) not null default 0;

create view dev_prod_portal.person_sites as select * from dev_portal.person_sites;

alter table cached_pages_path change breadcrumb breadcrumb varchar(2000);
-- END 05-11-2019 --

-- START 15-11-2019 --
ALTER TABLE `clients` ADD COLUMN `homepage_profil`  int NULL;

CREATE TABLE `profil_homepage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profil` varchar(50) NOT NULL,
  `homepage` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 15-11-2019


-- START 20-11-2019 --
alter table crawler_paths add react_page_id varchar(10);
alter table crawler_paths add is_user_homepage tinyint(1) not null default 0;

alter table profil_homepage add menu_id int(10);

drop table profil_homepage;
CREATE TABLE `client_profils` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profil` varchar(50) NOT NULL,
  `homepage` varchar(500) DEFAULT NULL,
  `menu_id` int(10),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `clients` change `homepage_profil` `client_profil_id`  int NULL;


-- END 20-11-2019 --


-- START 25-11-2019 --

insert into config (code, val) values ('DOCUMENTATION_TAR_FILE_SCRIPT_PATH','/home/ronaldo/tomcat/webapps/dev_menu/pages/sitemap/createtar.sh');

-- END 25-11-2019 --


-- START 05-12-2019 --

alter table sites add  site_auth_login_page text ;

alter table sites add site_auth_enabled tinyint(1) not null default 0;

update config set code = 'NO_CACHE_JS' where code = 'NOCACHE_JS';
update config set val = '' where code = 'NO_CACHE_JS';

alter table crawler_paths drop key `menu_id`;

alter table crawler_paths add constraint `uniq_key` unique (menu_id, parent_page_id, page_id, is_menu_link, is_homepage_link);

alter table cached_pages_path change breadcrumb breadcrumb text;

-- END 05-12-2019 --


