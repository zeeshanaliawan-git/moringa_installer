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


-- START 20-05-2020 --

update config set code = 'SYNC_TRIGGER_SCRIPT' where code = 'CACHE_SYNC_SCRIPT';
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('VARIANT_IMAGE_UPLOAD_DIRECTORY', '/home/ronaldo/tomcat/webapps/dev_shop/variant_images/', 'for shop');

-- END 20-05-2020 --


-- START 21-05-2020 --
-- Only required in _portal : used in selfcare engine
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('PREPROD_CART_URL', 'https://testportail.app/dev_portal/cart/cart.jsp','External url of cart');
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('PROD_CART_URL', 'https://testportail.app/dev_prodportal/cart/cart.jsp','External url of cart');
-- END 21-05-2020 --

-- START 28-05-2020 --

CREATE TABLE `files` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(300) NOT NULL,
  `file_uuid` varchar(50) NOT NULL DEFAULT '',
  `file_extension` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `cart`
ADD COLUMN `delivery_method`  varchar(25) NULL DEFAULT NULL AFTER `newPhoneNumber`,
ADD COLUMN `selected_boutique`  text NULL DEFAULT NULL AFTER `delivery_method`,
ADD COLUMN `rdv_boutique`  varchar(5) NULL DEFAULT NULL AFTER `selected_boutique`,
ADD COLUMN `rdv_date`  datetime NULL DEFAULT NULL AFTER `rdv_boutique`,
ADD COLUMN `delivery_type`  varchar(50) NULL DEFAULT NULL AFTER `rdv_date`,
ADD COLUMN `payment_method`  varchar(25) NULL DEFAULT NULL AFTER `delivery_type`,
ADD COLUMN `daline1`  varchar(128) NULL DEFAULT NULL AFTER `payment_method`,
ADD COLUMN `daline2`  varchar(128) NULL DEFAULT NULL AFTER `daline1`,
ADD COLUMN `datowncity`  varchar(64) NULL DEFAULT NULL AFTER `daline2`,
ADD COLUMN `dapostalCode`  varchar(5) NULL DEFAULT NULL AFTER `datowncity`,
ADD COLUMN `site_id`  int(10) NULL DEFAULT NULL AFTER `dapostalCode`,
ADD COLUMN `country`  varchar(64) NULL DEFAULT NULL AFTER `site_id`,
ADD COLUMN `keepEmail`  varchar(64) NULL DEFAULT NULL AFTER `country`,
ADD COLUMN `sendKeepEmail`  tinyint(1) NULL DEFAULT NULL AFTER `keepEmail`,
ADD COLUMN `keepEmailMuid`  varchar(50) NULL DEFAULT NULL AFTER `sendKeepEmail`;

-- END 28-05-2020 --



-- START 03-06-2020 --
-- Engine config only required in portal
insert into config (code, val) values ('CROSS_SITE_APPS_URL','/dev_pages/pages/;/dev_forms/;/dev_catalog/;/dev_prodcatalog/');

create table site_menus_v2_bkup as select * from site_menus;

CREATE TABLE site_menu_htmls (
  menu_id int(11) unsigned NOT NULL,
  header_html mediumtext default null,
  footer_html mediumtext default null,
  header_html_1 mediumtext default null,
  footer_html_1 mediumtext default null,
  tmp_header_html mediumtext default null,
  tmp_footer_html mediumtext default null,
  PRIMARY KEY (menu_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into site_menu_htmls (menu_id, header_html, footer_html, header_html_1, footer_html_1, tmp_header_html, tmp_footer_html) select id, header_html, footer_html, header_html_1, footer_html_1, tmp_header_html, tmp_footer_html from site_menus;

alter table site_menus drop column header_html;
alter table site_menus drop column footer_html;
alter table site_menus drop column header_html_1;
alter table site_menus drop column footer_html_1;
alter table site_menus drop column tmp_header_html;
alter table site_menus drop column tmp_footer_html;

-- END 03-06-2020 --

-- START 05-06-2020 --
ALTER TABLE `cart`
ADD COLUMN `newsletter`  tinyint(1) NULL DEFAULT 0 AFTER `keepEmailMuid`;
-- END 05-06-2020 --


-- START 07-06-2020 --
alter table clients add verification_token varchar(36);
alter table clients add verification_token_expiry datetime;
alter table clients add send_verification_email tinyint(1) not null default 0;
alter table clients add signup_menu_uuid varchar(36) not null default 0;

insert into config (code,val) values ('USER_VERIFICATION_URL','http://178.32.6.108/dev_portal/pages/verify.jsp');
insert into config (code,val) values ('PROD_USER_VERIFICATION_URL','http://178.32.6.108/dev_prodportal/pages/verify.jsp');

delete from config where code = 'CACHESYNC_WAIT_TIMEOUT';
delete from config where code = 'CACHESYNC_DEBUG';
delete from config where code = 'CACHESYNC_SEMAPHORE';
delete from config where code = 'CACHESYNC_SCRIPT';

-- END 07-06-2020 --
