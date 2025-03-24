-- START 01-04-2021 --

update dev_commons.config set val = '2.8.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.8.0.0' where code = 'CSS_JS_VERSION';

insert into dev_commons.config  (code, val) values ("PROD_CATALOG_DB", "dev_prod_catalog");

-- END 01-04-2021 --

-- START 12-04-2021 --

ALTER TABLE `promotions`
ADD COLUMN `frequency`  varchar(10) NULL AFTER `lang_5_title`;

-- END 12-04-2021 --

-- START 26-04-2021 --
ALTER TABLE `cart_promotion`
ADD COLUMN `element_on_value`  varchar(255) NULL DEFAULT '' AFTER `element_on`;

ALTER TABLE `comewiths`
ADD COLUMN `variant_type`  varchar(10) NULL AFTER `title`;

alter table products add select_variant_by enum('attributes','image') not null default 'attributes';

-- END 26-04-2021 --

-- START 03-05-2021 --
CREATE TABLE dev_commons.user_actions (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `item_id` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `description` varchar(500) NOT NULL,
  `site_id` varchar(50) NOT NULL,
  `user_agent` text NOT NULL,
  `activity_on` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 03-05-2021 --
