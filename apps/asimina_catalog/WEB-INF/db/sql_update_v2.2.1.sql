-- START 07-05-2020 --
insert into page (name, url, parent, rang, icon, parent_icon) values ('Clients Log','/dev_menu/pages/prodclientslog.jsp','System','611','chevron-right','settings');
update page set rang = 612 where name = 'Search Forms' and parent = 'System';
-- END 07-05-2020 --

-- START 30-05-2020 --
insert into dev_commons.config (code, val, comments) values ('CSS_JS_VERSION','2.2.1.0','First three numbers are the app version number. Forth number is the iterations of css/js updates in that particular version. App version x.y.z will have css/js version as x.y.z.w');

insert into page_sub_urls values ('/dev_catalog/admin/catalogs/catalogs.jsp','/dev_catalog/admin/catalogs/product.jsp');

insert into dev_commons.config (code, val) values ('ENABLE_CATAPULTE',0);
delete from config where code = 'ENABLE_CATAPULTE';

-- END 30-05-2020 --


-- START 01-06-2020 --

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_empty_cart_url`  varchar(255) NULL DEFAULT NULL AFTER `lang_5_no_price_display_label`,
ADD COLUMN `lang_2_empty_cart_url`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_empty_cart_url`,
ADD COLUMN `lang_3_empty_cart_url`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_empty_cart_url`,
ADD COLUMN `lang_4_empty_cart_url`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_empty_cart_url`,
ADD COLUMN `lang_5_empty_cart_url`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_empty_cart_url`;

-- END 01-06-2020 --


-- START 02-06-2020 --
insert into dev_commons.config (code, val, comments) values ('CATAPULTE_DB','dev_catapulte','');
-- END 02-06-2020 --

-- START 03-06-2020 --
DELETE FROM `all_payment_methods` WHERE (`method`='payment_method_1');
DELETE FROM `all_payment_methods` WHERE (`method`='payment_method_2');
DELETE FROM `all_payment_methods` WHERE (`method`='payment_method_3');
INSERT INTO `all_payment_methods` (`method`, `displayName`) VALUES ('orange_money_obf', 'Orange Money OBF');
TRUNCATE payment_methods;
-- END 03-06-2020 --

-- START 10-06-2020 --
ALTER TABLE `fraud_rules`
DROP PRIMARY KEY,
ADD PRIMARY KEY (`column`, `days`, `site_id`);
-- END 10-06-2020 --

-- START 15-07-2020 --
update dev_commons.config set code = 'mail.smtp.host' where code = 'MAIL.SMTP.HOST';
update dev_commons.config set code = 'mail.smtp.port' where code = 'MAIL.SMTP.PORT';
-- END 15-07-2020 --
