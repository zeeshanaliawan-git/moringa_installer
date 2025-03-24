-- START 18-06-2020 --
alter table sites add datalayer_asset_type varchar(75);
alter table sites add datalayer_orange_zone varchar(75);
-- END 18-06-2020 --

-- START 29-06-2020 --
-- engine configs so only required to run in _portal
update config set code = 'PROD_MENU_JS_PATH' where code = 'MENU_JS_PATH';
update config set code = 'PROD_MENU_PHOTO_URL' where code = 'MENU_PHOTO_URL';
update config set code = 'PROD_MENU_RESOURCES_IMG_URL' where code = 'MENU_RESOURCES_IMG_URL';
update config set code = 'PROD_MENU_RESOURCES_PATH' where code = 'MENU_RESOURCES_PATH';
update config set code = 'PROD_MENU_RESOURCES_URL' where code = 'MENU_RESOURCES_URL';
-- END 29-06-2020 --

-- START 08-07-2020 --
alter table sites add snap_pixel_code varchar(75);
-- END 08-07-2020 --

-- START 14-07-2020 --
-- first we add new option same_window which was before as empty value
alter table menu_items modify open_as enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url','same_window');

update menu_items set open_as = 'new_tab' where open_as = 'new_tab_original_url';
update menu_items set open_as = 'new_window' where open_as = 'new_window_original_url';
update menu_items set open_as = 'same_window' where open_as = 'same_window_original_url';

update menu_items set open_as = 'same_window' where coalesce(open_as,'') = '';

alter table menu_items modify open_as enum('new_tab','new_window','same_window') not null default 'same_window';

DELETE FROM `config` WHERE (`code`='VARIANT_IMAGE_UPLOAD_DIRECTORY');
INSERT INTO config (`code`, `val`, `comments`) VALUES ('VARIANT_IMAGE_UPLOAD_DIRECTORY', '/home/ronaldo/tomcat/webapps/dev_shop/variant_images/', 'for shop');

-- END 14-07-2020 --

-- START 15-07-2020 --
insert into config (code,val) values ('SMTP_DEBUG','true');

alter table sites change url url varchar(255) default null;
-- END 15-07-2020 --

-- START 21-07-2020 --

insert into dev_prod_portal.config (code, val) values ('PRODUCTS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/products/');

-- END 21-07-2020 --

-- START 07-08-2020 -- 
ALTER TABLE `sites`
ADD COLUMN `shop_location_type`  varchar(255) NULL DEFAULT '' AFTER `snap_pixel_code`,
ADD COLUMN `package_point_location_type`  varchar(255) NULL DEFAULT '' AFTER `shop_location_type`;
-- END 07-08-2020 --

-- START 04-09-2020 -- 
insert into dev_commons.config(code, val, comments) values ('INCLUDE_CUSTOM_CSS','0','Flag to enable disable inclusion of custom css at time of caching pages');
-- END 04-09-2020 -- 

-- START 16-09-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_API_MSISDN', '67685696');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USERNAME', '');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_PASSWORD', '');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_URL', 'https://testom.orange.bf:9008/payment');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USSD', '*866*4*6*');
-- END 16-09-2020 --

-- START 25-09-2020 --
delete from config where code = 'ORANGE_API_MSISDN';
delete from config where code = 'ORANGE_MONEY_API_USERNAME';
delete from config where code = 'ORANGE_MONEY_API_PASSWORD';
delete from config where code = 'ORANGE_MONEY_API_URL';
-- END 25-09-2020 --