-- by umair
alter table post_work change status status int(1) not null default 0;

insert into actions (name, className) values ('publishorder','PublishOrdering');
insert into page (name, url, parent, rang) values ('Sitemap','/dev_catalog/admin/preprodsitemap.jsp','Preprod',41);
insert into page (name, url, parent, rang) values ('Sitemap','/dev_catalog/admin/prodsitemap.jsp','Production',41);
insert into page (name, url, parent, rang) values ('Redirects','/dev_catalog/admin/preprodredirections.jsp','Preprod',42);
insert into page (name, url, parent, rang) values ('Redirects','/dev_catalog/admin/prodredirections.jsp','Production',42);
insert into page (name, url, parent, rang) values ('Sitemap Audit','/dev_catalog/admin/preprodsitemapaudit.jsp','Preprod',43);
insert into page (name, url, parent, rang) values ('Sitemap Audit','/dev_catalog/admin/prodsitemapaudit.jsp','Production',43);


delete from page where name = 'devices';
delete from page where name = 'tarifs';
delete from page where name = 'Device ordering';
insert into page (name, url, parent, rang) values ('Ck-Editor','/dev_catalog/admin/gotockeditor.jsp', '',44);

alter table catalogs add hub_page_orientation varchar(50);

alter table prices add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices add b2b_price varchar(10) DEFAULT NULL;
alter table prices add b2b_promo_price varchar(10) DEFAULT NULL;
alter table prices add b2b_currency varchar(10) DEFAULT NULL;
alter table prices add b2b_currency_frequency varchar(10) DEFAULT NULL;

alter table prices_lang_1 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices_lang_1 add b2b_currency varchar(20) DEFAULT NULL;
alter table prices_lang_1 add b2b_currency_frequency varchar(20) DEFAULT NULL;

alter table prices_lang_2 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices_lang_2 add b2b_currency varchar(20) DEFAULT NULL;
alter table prices_lang_2 add b2b_currency_frequency varchar(20) DEFAULT NULL;

alter table prices_lang_3 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices_lang_3 add b2b_currency varchar(20) DEFAULT NULL;
alter table prices_lang_3 add b2b_currency_frequency varchar(20) DEFAULT NULL;

alter table prices_lang_4 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices_lang_4 add b2b_currency varchar(20) DEFAULT NULL;
alter table prices_lang_4 add b2b_currency_frequency varchar(20) DEFAULT NULL;

alter table prices_lang_5 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table prices_lang_5 add b2b_currency varchar(20) DEFAULT NULL;
alter table prices_lang_5 add b2b_currency_frequency varchar(20) DEFAULT NULL;

alter table tarifs add b2b_price varchar(10) DEFAULT NULL;
alter table tarifs add b2b_promo_price varchar(10) DEFAULT NULL;
alter table tarifs add lang_1_b2b_pricesent varchar(255) DEFAULT NULL;
alter table tarifs add lang_2_b2b_pricesent varchar(255) DEFAULT NULL;
alter table tarifs add lang_3_b2b_pricesent varchar(255) DEFAULT NULL;
alter table tarifs add lang_4_b2b_pricesent varchar(255) DEFAULT NULL;
alter table tarifs add lang_5_b2b_pricesent varchar(255) DEFAULT NULL;
alter table tarifs add lang_1_b2b_currency varchar(15) DEFAULT NULL;
alter table tarifs add lang_2_b2b_currency varchar(15) DEFAULT NULL;
alter table tarifs add lang_3_b2b_currency varchar(15) DEFAULT NULL;
alter table tarifs add lang_4_b2b_currency varchar(15) DEFAULT NULL;
alter table tarifs add lang_5_b2b_currency varchar(15) DEFAULT NULL;
alter table tarifs add lang_1_b2b_currencyfreq varchar(15) DEFAULT NULL;
alter table tarifs add lang_2_b2b_currencyfreq varchar(15) DEFAULT NULL;
alter table tarifs add lang_3_b2b_currencyfreq varchar(15) DEFAULT NULL;
alter table tarifs add lang_4_b2b_currencyfreq varchar(15) DEFAULT NULL;
alter table tarifs add lang_5_b2b_currencyfreq varchar(15) DEFAULT NULL;

alter table terminaux add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux add b2b_price varchar(20) DEFAULT NULL;
alter table terminaux add b2b_promo_price varchar(20) DEFAULT NULL;
alter table terminaux add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux add b2b_currency_frequency varchar(75) DEFAULT NULL;

alter table terminaux_lang_1 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux_lang_1 add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux_lang_1 add b2b_currency_frequency varchar(75) DEFAULT NULL;

alter table terminaux_lang_2 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux_lang_2 add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux_lang_2 add b2b_currency_frequency varchar(75) DEFAULT NULL;

alter table terminaux_lang_3 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux_lang_3 add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux_lang_3 add b2b_currency_frequency varchar(75) DEFAULT NULL;

alter table terminaux_lang_4 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux_lang_4 add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux_lang_4 add b2b_currency_frequency varchar(75) DEFAULT NULL;

alter table terminaux_lang_5 add b2b_price_sent varchar(20) DEFAULT NULL;
alter table terminaux_lang_5 add b2b_currency varchar(15) DEFAULT NULL;
alter table terminaux_lang_5 add b2b_currency_frequency varchar(75) DEFAULT NULL;


-- by Ali Adnan

-- for attributes and prices

CREATE TABLE IF NOT EXISTS catalog_attributes (
  cat_attrib_id int(11) unsigned NOT NULL AUTO_INCREMENT,
  catalog_id int(11) NOT NULL,
  name varchar(255) NOT NULL,
  visible_to enum('all','logged_customer','logged_supplier','backoffice') NOT NULL DEFAULT 'all',
  sort_order int(11) NOT NULL DEFAULT '0',
  type enum('selection','specs') NOT NULL DEFAULT 'selection',
  detail_only  tinyint(1) NOT NULL DEFAULT 0 COMMENT '1= show on detail page only',
  PRIMARY KEY (cat_attrib_id),
  UNIQUE KEY uk_catalog_attrib_name_type (catalog_id,name,type)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS product_attribute_values (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  product_id int(11) NOT NULL,
  cat_attrib_id int(11) NOT NULL,
  attribute_value varchar(255) NOT NULL,
  image varchar(1000) NOT NULL DEFAULT '',
  price_diff varchar(20) NOT NULL DEFAULT '+0.0',
  is_default tinyint(1) NOT NULL DEFAULT '1',
  sort_order int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS product_images (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  product_id int(11) NOT NULL,
  image_file_name varchar(100) NOT NULL,
  image_label varchar(100) NOT NULL,
  sort_order int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS catalog_business_types_bk_v10
SELECT * FROM catalog_business_types;

ALTER TABLE catalog_business_types
MODIFY COLUMN business_type  varchar(25) NOT NULL AFTER catalog_id,
ADD PRIMARY KEY (catalog_id, business_type);



-- Updates to catalogs

CREATE TABLE IF NOT EXISTS catalogs_bk_v10
SELECT * FROM catalogs;

ALTER TABLE catalogs
ADD COLUMN product_types_custom  text NULL COMMENT 'list of json object having label, value' AFTER lang_5_details_heading;




-- Updates to products
CREATE TABLE IF NOT EXISTS products_bk_v10
SELECT * FROM products;

ALTER TABLE products
MODIFY COLUMN price text;

ALTER TABLE products
ADD COLUMN migrated_id  varchar(500) NULL COMMENT 'original id from migrated table' AFTER catalog_id;



ALTER TABLE products
ADD COLUMN product_type  enum('product','service','subscription_online','subscription_offline') NOT NULL DEFAULT 'product' AFTER image_actual_name;

ALTER TABLE products
ADD COLUMN product_type_custom  varchar(500) NULL COMMENT '' AFTER product_type;

ALTER TABLE products
ADD COLUMN brand_name  varchar(100) NULL AFTER product_type_custom,

-- for combination prices
ADD COLUMN combo_prices  text NULL AFTER price,

-- for discount deals , promo prices , etc
ADD COLUMN discount_prices text NULL COMMENT 'discount (fixed or percentage)' AFTER combo_prices,

-- for bundle e.g. >=5 , >=10 , lot prices
ADD COLUMN bundle_prices  text NULL AFTER discount_prices,

ADD COLUMN installment_options  text NULL AFTER bundle_prices,

ADD COLUMN stock  int(10) NULL AFTER installment_options,

ADD COLUMN payment_online  tinyint(1) NULL DEFAULT 0 AFTER stock,
ADD COLUMN payment_cash_on_delivery  tinyint(1) NULL DEFAULT 0 AFTER payment_online,

ADD COLUMN service_duration  int(10) NULL COMMENT 'in minutes , multiple of 15' AFTER payment_cash_on_delivery,
ADD COLUMN service_start_time  int(10) NULL COMMENT 'minutes since midnight'  AFTER service_duration,
ADD COLUMN service_end_time  int(10) NULL COMMENT 'minutes since midnight' AFTER service_start_time,
ADD COLUMN service_available_days  varchar(50) NULL AFTER service_end_time,

ADD COLUMN subscription_require_email  tinyint(1) NULL DEFAULT 0 AFTER service_available_days,
ADD COLUMN subscription_require_phone  tinyint(1) NULL DEFAULT 0 AFTER subscription_require_email,

ADD COLUMN subscription_recurring enum('no','daily','weekly','monthly','yearly') NOT NULL DEFAULT 'no' AFTER subscription_require_phone,


-- for feedback controls

ADD COLUMN allow_ratings  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users' AFTER lang_5_currency_freq,
ADD COLUMN allow_comments  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users' AFTER allow_ratings,
ADD COLUMN allow_complaints  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users' AFTER allow_comments,
ADD COLUMN allow_questions  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users' AFTER allow_complaints;


-- update product prices to new json format
UPDATE products
SET price = CONCAT('[{"price":"',CAST(TRIM(price) AS DECIMAL(10,2)),'","bType":"all"}]')
WHERE TRIM(price) REGEXP '^[0-9]+\\.?[0-9]*$';



--- added by umair --------------
update catalogs set is_special = 0 where name <> 'faqs';
alter table language add direction varchar(5) DEFAULT NULL;

CREATE TABLE product_relationship (
  id int(11) NOT NULL AUTO_INCREMENT,
  product_id int(11) NOT NULL,
  related_product_id int(11) NOT NULL,
  relationship_type enum('mandatory','suggested') NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_product_relation (product_id,related_product_id,relationship_type)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Ali Adnan updates 28-Oct-2016
ALTER TABLE products
ADD COLUMN price_sent text NULL AFTER price,
ADD COLUMN currency text NULL AFTER price_sent,
ADD COLUMN currency_frequency text NULL AFTER currency;


-- Umair updates 31-Oct-2016
alter table catalogs add view_name varchar(50) default null;
update catalogs set view_name = 'tarifview' where name = 'Tarifs';


-- Ali Adnan updates 1-Nov-2016
UPDATE products SET price_sent =  CONCAT('[{"priceSent":"',IFNULL(lang_1_pricesent,''),'","bType":"all"}]');

UPDATE products SET currency =  CONCAT('[{"currency":"',IFNULL(lang_1_currency,''),'","bType":"all"}]');

UPDATE products SET currency_frequency =  CONCAT('[{"currencyFrequency":"',IFNULL(lang_1_currency_freq,''),'","bType":"all"}]');

alter table products add product_uuid varchar(50) not null AFTER id;
update products set product_uuid = UUID();

alter table catalog_attributes change name name varchar(255) not null ;

alter table product_attribute_values change attribute_value attribute_value varchar(255) NOT NULL ;

alter table tarif_categories add product_id int(11) unsigned not null;


-- Asad ------------ 10-Nov-2016
INSERT INTO `page` (`name`, `url`, `parent`, `rang`) VALUES ('Shop Parameters', '/dev_catalog/admin/catalogs/shop_parameters.jsp', 'Preprod', '13');

CREATE TABLE `shop_parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lang_1_price_formatter` varchar(25) DEFAULT NULL,
  `lang_2_price_formatter` varchar(25) DEFAULT NULL,
  `lang_3_price_formatter` varchar(25) DEFAULT NULL,
  `lang_4_price_formatter` varchar(25) DEFAULT NULL,
  `lang_5_price_formatter` varchar(25) DEFAULT NULL,
  `lang_1_currency` varchar(25) DEFAULT NULL,
  `lang_2_currency` varchar(25) DEFAULT NULL,
  `lang_3_currency` varchar(25) DEFAULT NULL,
  `lang_4_currency` varchar(25) DEFAULT NULL,
  `lang_5_currency` varchar(25) DEFAULT NULL,
  `lang_1_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_2_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_3_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_4_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_5_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_1_show_decimals` varchar(1) DEFAULT NULL,
  `lang_2_show_decimals` varchar(1) DEFAULT NULL,
  `lang_3_show_decimals` varchar(1) DEFAULT NULL,
  `lang_4_show_decimals` varchar(1) DEFAULT NULL,
  `lang_5_show_decimals` varchar(1) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Ali Adnan 24 Nov 2016

-- END of v1.2.5 ---------------------------------------------------------

CREATE TABLE `business_types` (
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `universes` (
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS product_stocks(
  product_id int(11) NOT NULL,
  attribute_values varchar(300) NOT NULL,
  stock int(11) NOT NULL DEFAULT '0',
  created_ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by int(11) NOT NULL,
  PRIMARY KEY (product_id,attribute_values)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Ali Adnan 21 Dec 2016

ALTER TABLE products
ADD COLUMN show_quickbuy tinyint(1) NOT NULL DEFAULT '0' AFTER show_basket;
UPDATE products SET show_quickbuy = show_basket;

ALTER TABLE products
ADD COLUMN service_max_slots int(10) DEFAULT 1 COMMENT 'max consecutive no of slots per service booking' AFTER service_duration;

-- for linked products

CREATE TABLE product_link (
  id int(11) NOT NULL AUTO_INCREMENT,
  stock int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


ALTER TABLE products
ADD COLUMN link_id int(11) NULL DEFAULT NULL COMMENT 'product_link fk , for linked products' AFTER catalog_id;


-- Asad 20-01-2017

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_terms`  text NULL DEFAULT NULL AFTER `updated_on`,
ADD COLUMN `lang_2_terms`  text NULL DEFAULT NULL AFTER `lang_1_terms`,
ADD COLUMN `lang_3_terms`  text NULL DEFAULT NULL AFTER `lang_2_terms`,
ADD COLUMN `lang_4_terms`  text NULL DEFAULT NULL AFTER `lang_3_terms`,
ADD COLUMN `lang_5_terms`  text NULL DEFAULT NULL AFTER `lang_4_terms`,
ADD COLUMN `checkout_login`  varchar(1) NULL DEFAULT NULL AFTER `lang_5_terms`;

-- Ali Adnan 2017-03-21
ALTER TABLE products
MODIFY COLUMN product_type varchar(100) NOT NULL DEFAULT 'product' AFTER image_actual_name;

-- Ali Adnan 2017-03-28
ALTER TABLE catalog_attributes
ADD COLUMN migration_name  varchar(500) NOT NULL DEFAULT '' COMMENT 'used by device data migration';

-- Ali Adnan 2017-05-04
ALTER TABLE products
ADD COLUMN service_available_start_time varchar(20) NOT NULL DEFAULT '00,15,30,45' COMMENT 'allowed starting time' AFTER service_end_time;

-- Ali Adnan 2017-06-17
ALTER TABLE product_stocks
ADD COLUMN resources  text NOT NULL COMMENT 'resource names for services comma seperated' AFTER stock;

ALTER TABLE product_link
ADD COLUMN resources  text NOT NULL COMMENT 'resource names for services commma seperated ' AFTER stock,
ADD COLUMN created_ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN created_by int(11) NOT NULL DEFAULT 0;

UPDATE product_link SET created_ts = NOW() , created_by = 0;

ALTER TABLE product_link
MODIFY COLUMN created_by int(11) NOT NULL;

-- Abdul Rehman 2017-06-06
CREATE TABLE `calendar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` DATE NOT NULL,
  `type` VARCHAR(50) NOT NULL COMMENT '1-Public Holiday, 2-Exclusion' ,
  `product_id` VARCHAR(10) DEFAULT NULL,
  `catalog_id` VARCHAR(10) DEFAULT NULL,
  `minus_stock` VARCHAR(5) DEFAULT NULL,
  `start_time` TIME DEFAULT NULL,
  `end_time` TIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab) VALUES ('Calendar','/dev_catalog/admin/catalogs/preprodCustomCalendar.jsp','Preprod','41','0'), ('Calendar','/dev_catalog/admin/catalogs/prodCustomCalendar.jsp','Production','42','0');

-- Ali Adnan 2017-06-17
ALTER TABLE products
ADD COLUMN service_schedule text COMMENT 'per day schedule in json format' AFTER service_available_days;


-- Ali Adnan 2017-06-20
ALTER TABLE products
ADD COLUMN service_gap int(11) DEFAULT '0' COMMENT 'in minutes' AFTER service_duration;

ALTER TABLE calendar ADD COLUMN resources VARCHAR(50) DEFAULT '' AFTER minus_stock;

CREATE TABLE `resources` (
  `name` varchar(255) NOT NULL,
  `phone_no` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `rtype` enum ('primary','secondary') NOT NULL,
  PRIMARY KEY (`name`, rtype)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


insert into page (name, url, parent, rang) values ('Resources','/dev_catalog/admin/resources.jsp','Preprod',43);
insert into page (name, url, parent, rang) values ('Resources','/dev_catalog/admin/prodresources.jsp','Production',43);


-- Ali Adnan 2017-07-04
ALTER TABLE products
ADD COLUMN service_resources text COMMENT 'comma-separated list of secondary resources' AFTER service_schedule;


-- only in preprod catalog ---
create table backups ( file_prefix varchar(20) not null, started_on timestamp not null default current_timestamp ) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into page (name, url, parent, rang) values ('Backup','/dev_catalog/admin/backup.jsp','Gestion',45);


-- SMART BANNER CHANGES 11/10/2017

alter table shop_parameters add lang_1_sb_title varchar(255);
alter table shop_parameters add lang_2_sb_title varchar(255);
alter table shop_parameters add lang_3_sb_title varchar(255);
alter table shop_parameters add lang_4_sb_title varchar(255);
alter table shop_parameters add lang_5_sb_title varchar(255);

alter table shop_parameters add lang_1_sb_author varchar(255);
alter table shop_parameters add lang_2_sb_author varchar(255);
alter table shop_parameters add lang_3_sb_author varchar(255);
alter table shop_parameters add lang_4_sb_author varchar(255);
alter table shop_parameters add lang_5_sb_author varchar(255);

alter table shop_parameters add lang_1_sb_price varchar(75);
alter table shop_parameters add lang_2_sb_price varchar(75);
alter table shop_parameters add lang_3_sb_price varchar(75);
alter table shop_parameters add lang_4_sb_price varchar(75);
alter table shop_parameters add lang_5_sb_price varchar(75);

alter table shop_parameters add lang_1_sb_button_label varchar(75);
alter table shop_parameters add lang_2_sb_button_label varchar(75);
alter table shop_parameters add lang_3_sb_button_label varchar(75);
alter table shop_parameters add lang_4_sb_button_label varchar(75);
alter table shop_parameters add lang_5_sb_button_label varchar(75);

alter table shop_parameters add sb_platform_ios tinyint(1) default 0;
alter table shop_parameters add sb_platform_android tinyint(1) default 0;

alter table shop_parameters add lang_1_sb_ios_price_suffix varchar(75);
alter table shop_parameters add lang_2_sb_ios_price_suffix varchar(75);
alter table shop_parameters add lang_3_sb_ios_price_suffix varchar(75);
alter table shop_parameters add lang_4_sb_ios_price_suffix varchar(75);
alter table shop_parameters add lang_5_sb_ios_price_suffix varchar(75);

alter table shop_parameters add sb_ios_icon varchar(255);

alter table shop_parameters add lang_1_sb_ios_button_url varchar(255);
alter table shop_parameters add lang_2_sb_ios_button_url varchar(255);
alter table shop_parameters add lang_3_sb_ios_button_url varchar(255);
alter table shop_parameters add lang_4_sb_ios_button_url varchar(255);
alter table shop_parameters add lang_5_sb_ios_button_url varchar(255);

alter table shop_parameters add lang_1_sb_android_price_suffix varchar(75);
alter table shop_parameters add lang_2_sb_android_price_suffix varchar(75);
alter table shop_parameters add lang_3_sb_android_price_suffix varchar(75);
alter table shop_parameters add lang_4_sb_android_price_suffix varchar(75);
alter table shop_parameters add lang_5_sb_android_price_suffix varchar(75);

alter table shop_parameters add sb_android_icon varchar(255);

alter table shop_parameters add lang_1_sb_android_button_url varchar(255);
alter table shop_parameters add lang_2_sb_android_button_url varchar(255);
alter table shop_parameters add lang_3_sb_android_button_url varchar(255);
alter table shop_parameters add lang_4_sb_android_button_url varchar(255);
alter table shop_parameters add lang_5_sb_android_button_url varchar(255);

-- end of smart banner --


insert into page (name, url, parent, rang, new_tab) values ('Test Shop','/dev_shop/customCalendar.jsp','Shop',51, 1);
insert into page (name, url, parent, rang, new_tab) values ('Prod Shop','/dev_prodshop/customCalendar.jsp','Shop',52, 1);

alter table login change name name varchar(255);

-- Ali Adnan 8 Nov 2017

ALTER TABLE products
ADD COLUMN primary_resource  varchar(500) NOT NULL DEFAULT '' AFTER payment_cash_on_delivery,
ADD COLUMN secondary_resource  varchar(500) NOT NULL DEFAULT '' AFTER primary_resource;


-- START 13-11-2017 --
insert into page (name, url, parent, rang, new_tab) values ('Product Relationship','/dev_catalog/admin/catalogs/productrelation.jsp','Preprod',53, 0);

-- END 13-11-2017 --


-- START 27-11-2017 --
ALTER TABLE `product_relationship`
ADD COLUMN `parent_price`  tinyint NOT NULL DEFAULT 1 AFTER `relationship_type`;
-- END 27-11-2017 --

-- START 29-11-2017 -- Asad
CREATE TABLE `product_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user` varchar(50) DEFAULT NULL,
  `comment` text ,
  `is_guest` tinyint(4) DEFAULT '0',
  `tm` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 29-11-2017 --

-- START 30-11-2017 -- Asad
ALTER TABLE `products`
MODIFY COLUMN `allow_comments`  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users' AFTER `allow_ratings`;

-- END 30-11-2017 --

-- START 12-12-2017 --
alter table catalogs add lang_1_meta_keywords        text;
alter table catalogs add lang_2_meta_keywords        text;
alter table catalogs add lang_3_meta_keywords        text;
alter table catalogs add lang_4_meta_keywords        text;
alter table catalogs add lang_5_meta_keywords        text;
alter table catalogs add lang_1_meta_description     text;
alter table catalogs add lang_2_meta_description     text;
alter table catalogs add lang_3_meta_description     text;
alter table catalogs add lang_4_meta_description     text;
alter table catalogs add lang_5_meta_description     text;

alter table familie add lang_1_meta_keywords        text;
alter table familie add lang_2_meta_keywords        text;
alter table familie add lang_3_meta_keywords        text;
alter table familie add lang_4_meta_keywords        text;
alter table familie add lang_5_meta_keywords        text;
alter table familie add lang_1_meta_description     text;
alter table familie add lang_2_meta_description     text;
alter table familie add lang_3_meta_description     text;
alter table familie add lang_4_meta_description     text;
alter table familie add lang_5_meta_description     text;

-- END 12-12-2017 --

-- START 24-01-2018 --
insert into config (code, val) values ('app_version','1.2.5');

ALTER TABLE catalogs
ADD COLUMN invoice_nature varchar(100) NOT NULL DEFAULT '';

ALTER TABLE products
ADD COLUMN invoice_nature varchar(100) NOT NULL DEFAULT '';

-- END 24-01-2018 --


-- START 29-01-2018 -- Asad
ALTER TABLE `products`
ADD COLUMN `rating_score`  int NULL AFTER `product_uuid`,
ADD COLUMN `rating_count`  int NULL AFTER `rating_score`;
-- END 29-01-2018 --

-- START 09-02-2018 -- Asad
ALTER TABLE `catalog_attributes`
ADD COLUMN `is_searchable`  tinyint(1) NOT NULL DEFAULT 0 AFTER `migration_name`;
-- END 09-02-2018 --


-- START 09-03-2018 --
-- Ali Adnan
ALTER TABLE shop_parameters
ADD COLUMN catapulte_id_prod int(11) NOT NULL DEFAULT '0' AFTER id,
ADD COLUMN catapulte_id_test int(11) NOT NULL DEFAULT '0' AFTER catapulte_id_prod;

alter table config add primary key (code);

-- END 09-03-2018 --



-- START 20-03-2018 --

CREATE TABLE `product_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) NOT NULL,
  `user` varchar(50) DEFAULT NULL,
  `answer` text,
  `tm` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `product_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user` varchar(50) DEFAULT NULL,
  `question` text,
  `is_guest` tinyint(4) DEFAULT '0',
  `tm` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `email_sent` tinyint(4) DEFAULT '0',
  `question_uuid` varchar(50) DEFAULT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `product_question_clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `question_uuid` varchar(50) NOT NULL,
  `client_uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_client` (`client_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `products`
MODIFY COLUMN `allow_questions`  tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users' AFTER `allow_complaints`;

-- END 20-03-2018 --

-- START 30-03-2018 --

ALTER TABLE `shop_parameters`
ADD COLUMN `installment_duration_units`  varchar(255) NULL AFTER `lang_5_sb_android_button_url`;


ALTER TABLE catalogs ADD COLUMN topban_product_list char(1) DEFAULT '0' AFTER lang_1_top_banner_path ;
ALTER TABLE catalogs ADD COLUMN topban_product_detail char(1) DEFAULT '0' AFTER topban_product_list  ;
ALTER TABLE catalogs ADD COLUMN topban_hub char(1) DEFAULT '0' AFTER topban_product_detail ;

ALTER TABLE catalogs ADD COLUMN bottomban_product_list char(1) DEFAULT '0' AFTER lang_1_bottom_banner_path ;
ALTER TABLE catalogs ADD COLUMN bottomban_product_detail char(1) DEFAULT '0' AFTER bottomban_product_list ;
ALTER TABLE catalogs ADD COLUMN bottomban_hub char(1) DEFAULT '0' AFTER bottomban_product_detail ;

-- START 30-03-2018 --



-- START 12-04-2018 --

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_terms_error`  varchar(255) NULL DEFAULT NULL AFTER `installment_duration_units`,
ADD COLUMN `lang_2_terms_error`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_terms_error`,
ADD COLUMN `lang_3_terms_error`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_terms_error`,
ADD COLUMN `lang_4_terms_error`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_terms_error`,
ADD COLUMN `lang_5_terms_error`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_terms_error`,
ADD COLUMN `lang_1_cart_message`  varchar(255) NULL DEFAULT NULL AFTER `lang_5_terms_error`,
ADD COLUMN `lang_2_cart_message`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_cart_message`,
ADD COLUMN `lang_3_cart_message`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_cart_message`,
ADD COLUMN `lang_4_cart_message`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_cart_message`,
ADD COLUMN `lang_5_cart_message`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_cart_message`;


CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `helpText` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `payment_methods` VALUES ('1', 'credit_card', 'Carte bancaire', '2', '1', '');
INSERT INTO `payment_methods` VALUES ('2', 'cash_on_pickup', 'Paiement en agence', '7', '1', '');
INSERT INTO `payment_methods` VALUES ('3', 'cash_on_delivery', 'Paiement au retrait', '4', '0', '');
INSERT INTO `payment_methods` VALUES ('4', 'orange_money', 'Orange Money', '2', '0', '');
INSERT INTO `payment_methods` VALUES ('5', 'paypal', 'Paypal', '2', '0', '');


CREATE TABLE `delivery_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `helpText` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `delivery_methods` VALUES ('1', 'home_delivery', 'Livraison à domicile', '5', '1', 'sous 2 - 5 jours ouvres chez vous');
INSERT INTO `delivery_methods` VALUES ('2', 'pick_up_in_store', 'Livraison en agence', '4', '1', 'Vous serez recontacter par un conseiller client pour définir l\'agence de livraison');
INSERT INTO `delivery_methods` VALUES ('3', 'pick_up_in_package_point', 'Livraison point relais', '3', '0', '');

-- END 12-04-2018 --



-- START 18-04-2018 --

INSERT INTO `payment_methods` VALUES ('6', 'payment_method_1', '', '0', '0', '');
INSERT INTO `payment_methods` VALUES ('7', 'payment_method_2', '', '0', '0', '');
INSERT INTO `payment_methods` VALUES ('8', 'payment_method_3', '', '0', '0', '');

ALTER TABLE `payment_methods`
ADD COLUMN `orderSeq`  int NULL AFTER `helpText`;

ALTER TABLE `delivery_methods`
ADD COLUMN `orderSeq`  int NULL AFTER `helpText`;

-- END 18-04-2018

-- START 18-05-2018
-- ALi Adnan, Landing Pages
CREATE TABLE landing_pages (
  id int(11) NOT NULL AUTO_INCREMENT,
  page_name varchar(100) NOT NULL,
  orientation varchar(50) NOT NULL DEFAULT '',
  created_by int(11) NOT NULL,
  created_on datetime NOT NULL,
  updated_by int(11) DEFAULT NULL,
  updated_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE landing_pages_items (
  id int(11) NOT NULL AUTO_INCREMENT,
  landing_page_id int(11) NOT NULL,
  sort_order int(11) NOT NULL,
  lang_1_url varchar(500) NOT NULL DEFAULT '',
  lang_2_url varchar(500) NOT NULL DEFAULT '',
  lang_3_url varchar(500) NOT NULL DEFAULT '',
  lang_4_url varchar(500) NOT NULL DEFAULT '',
  lang_5_url varchar(500) NOT NULL DEFAULT '',
  lang_1_title varchar(250) NOT NULL DEFAULT '',
  lang_2_title varchar(250) NOT NULL DEFAULT '',
  lang_3_title varchar(250) NOT NULL DEFAULT '',
  lang_4_title varchar(250) NOT NULL DEFAULT '',
  lang_5_title varchar(250) NOT NULL DEFAULT '',
  lang_1_description varchar(500) NOT NULL DEFAULT '',
  lang_2_description varchar(500) NOT NULL DEFAULT '',
  lang_3_description varchar(500) NOT NULL DEFAULT '',
  lang_4_description varchar(500) NOT NULL DEFAULT '',
  lang_5_description varchar(500) NOT NULL DEFAULT '',
  lang_1_image varchar(500) NOT NULL DEFAULT '',
  lang_2_image varchar(500) NOT NULL DEFAULT '',
  lang_3_image varchar(500) NOT NULL DEFAULT '',
  lang_4_image varchar(500) NOT NULL DEFAULT '',
  lang_5_image varchar(500) NOT NULL DEFAULT '',
  created_by int(11) NOT NULL,
  created_on datetime NOT NULL,
  updated_by int(11) DEFAULT NULL,
  updated_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


insert into page (name, url, parent, rang, new_tab) values ('Landing Pages','/dev_catalog/admin/landingpages.jsp','Preprod',21, 0);
insert into page (name, url, parent, rang, new_tab) values ('Landing Pages','/dev_catalog/admin/landingpages.jsp?isProd=1','Production',21, 0);

-- END 18-05-2018



-- START 21-05-2018
-- ONLY in _catalog

INSERT INTO `coordinates` VALUES (46,195,120,80,'landingpages','ADMIN','publish'),(9,11,584,500,'landingpages','ADMIN',NULL),(342,115,120,80,'landingpages','ADMIN','published'),(42,285,120,80,'landingpages','ADMIN','delete'),(346,284,120,80,'landingpages','ADMIN','deleted'),(179,408,120,80,'landingpages','ADMIN','cancel'),(620,10,300,500,'landingpages','PROD_SITE_ACCESS',NULL),(924,18,300,500,'landingpages','PROD_CACHE_MGMT',NULL);

INSERT INTO `has_action` VALUES ('landingpages','delete',25,'remove:landingpage'),('landingpages','publish',26,'publish:landingpage');

INSERT INTO `phases` VALUES ('landingpages','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('landingpages','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('landingpages','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('landingpages','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('landingpages','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O');

INSERT INTO `rules` VALUES ('landingpages','delete',0,'landingpages','deleted',0,'remove:landingpage',0,25,0,'And','0','Cancelled'),('landingpages','publish',0,'landingpages','published',0,'publish:landingpage',0,26,0,'And','0','Cancelled');

-- END ONLY in _catalog


-- END 21-05-2018

---------------------------------------- TEMPLATE UPDATED TILL HERE 22-MAY-2018 ----------------------------------

-- START 22-05-2018 --

ALTER TABLE `delivery_methods`
ADD COLUMN `subText`  text NULL AFTER `orderSeq`;

ALTER TABLE `payment_methods`
ADD COLUMN `subText`  text NULL AFTER `orderSeq`;

CREATE TABLE `stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(50) DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `custom_id` int(11) DEFAULT NULL,
  `address` text,
  `city` varchar(50) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country_code` varchar(20) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `monday` varchar(20) DEFAULT NULL,
  `tuesday` varchar(20) DEFAULT NULL,
  `wednesday` varchar(20) DEFAULT NULL,
  `thursday` varchar(20) DEFAULT NULL,
  `friday` varchar(20) DEFAULT NULL,
  `saturday` varchar(20) DEFAULT NULL,
  `sunday` varchar(20) DEFAULT NULL,
  `latitude` varchar(20) DEFAULT NULL,
  `longitude` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- END 22-05-2018 --


---------------------------------------- TEMPLATE UPDATED TILL HERE 24-MAY-2018 ----------------------------------


-- START 30-05-2018 --

update config set val = '1.3' where code = 'app_version';

-- END 30-05-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 30-MAY-2018 ----------------------------------

-- START 04-06-2018 --

ALTER TABLE `catalogs`
ADD COLUMN `manufacturers`  text NULL AFTER `invoice_nature`;

-- END 04-06-2018 --

-- START 08-06-2018 --

CREATE TABLE `product_skus` (
  `product_id` int(11) NOT NULL,
  `attribute_values` varchar(300) NOT NULL,
  `sku` varchar(100) NOT NULL DEFAULT '0',
  `created_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_values`),
  UNIQUE KEY `uk_sku` (`sku`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 08-06-2018 --

-- START 19-07-2018 --

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_order_tracking`  text NULL DEFAULT NULL AFTER `lang_5_cart_message`,
ADD COLUMN `lang_2_order_tracking`  text NULL DEFAULT NULL AFTER `lang_1_order_tracking`,
ADD COLUMN `lang_3_order_tracking`  text NULL DEFAULT NULL AFTER `lang_2_order_tracking`,
ADD COLUMN `lang_4_order_tracking`  text NULL DEFAULT NULL AFTER `lang_3_order_tracking`,
ADD COLUMN `lang_5_order_tracking`  text NULL DEFAULT NULL AFTER `lang_4_order_tracking`;

-- END 19-07-2018 --

-- START 31-07-2018

-- only for _catalog , not for PROD
CREATE TABLE `usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_agent` text,
  `details` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

delete from page where name = 'Configs';

-- END 31-07-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 07-AUG-2018 ----------------------------------

-- START 09-08-2018

alter table products add app_id varchar(36) default null;

alter table login add sso_id varchar(36) default null;
-- END 09-08-2018


---------------------------------------- TEMPLATE UPDATED TILL HERE 17-AUG-2018 ----------------------------------

-- START 17-08-2018
CREATE TABLE `fraud_rules` (
  `column` varchar(50) NOT NULL,
  `days` int(11) NOT NULL,
  `limit` int(11) NOT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`column`,`days`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 17-08-2018

-- START 27-08-2018

CREATE TABLE `fraud_rules_log` (
  `column` varchar(50) NOT NULL,
  `days` int(11) NOT NULL,
  `limit` int(11) NOT NULL,
  `tm` timestamp NULL DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 27-08-2018

-- START 30-08-2018

ALTER TABLE `shop_parameters`
ADD COLUMN `service_params`  varchar(1) NULL DEFAULT NULL COMMENT '1 = Show; 0 = Hide;' AFTER `lang_5_order_tracking`;

insert into page (name, url, parent, rang) values ('FAQ Stats','/dev_catalog/admin/faqstats.jsp','Preprod',61);
insert into page (name, url, parent, rang) values ('FAQ Stats','/dev_catalog/admin/prodfaqstats.jsp','Production',62);


-- END 30-08-2018

-- START 18-10-2018 --
update config set val = '1.4' where code = 'app_version';
-- END 18-10-2018 --

--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- senegal updated till here on 19 OCT 2018 ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


-- START 24-10-2018 ----

--This will only be in _catalog not _prodcatalog

CREATE TABLE login_tries (
  `ip` varchar(15) NOT NULL,
  `tm` timestamp not null default current_timestamp,
  `attempt` int(10) not null default 1,
  primary key (ip)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 24-10-2018 ----

-- START 6-11-2018 ----

INSERT INTO config VALUES ('is_orange_app', '0');

-- END 6-11-2018 ----


-- START 14-11-2018 ----
alter table products add action_button_desktop varchar(75);
alter table products add action_button_desktop_url varchar(255);

alter table products add action_button_mobile varchar(75);
alter table products add action_button_mobile_url varchar(255);
-- END 14-11-2018 ----

-- START 26-11-2018 ----
ALTER TABLE catalogs
ADD COLUMN price_tax_included tinyint(1) NOT NULL DEFAULT '0';
-- END 26-11-2018 ----

-- START 08-01-2019 --
ALTER TABLE `products`
ADD COLUMN `color`  varchar(7) NULL AFTER `action_button_mobile_url`;

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_stock_alert_button`  varchar(255) NULL DEFAULT NULL AFTER `service_params`,
ADD COLUMN `lang_2_stock_alert_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_stock_alert_button`,
ADD COLUMN `lang_3_stock_alert_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_stock_alert_button`,
ADD COLUMN `lang_4_stock_alert_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_stock_alert_button`,
ADD COLUMN `lang_5_stock_alert_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_stock_alert_button`,
ADD COLUMN `lang_1_stock_alert_text`  varchar(255) NULL DEFAULT NULL AFTER `lang_5_stock_alert_button`,
ADD COLUMN `lang_2_stock_alert_text`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_stock_alert_text`,
ADD COLUMN `lang_3_stock_alert_text`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_stock_alert_text`,
ADD COLUMN `lang_4_stock_alert_text`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_stock_alert_text`,
ADD COLUMN `lang_5_stock_alert_text`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_stock_alert_text`,
ADD COLUMN `lang_1_coming_soon_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_5_stock_alert_text`,
ADD COLUMN `lang_2_coming_soon_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_1_coming_soon_button`,
ADD COLUMN `lang_3_coming_soon_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_2_coming_soon_button`,
ADD COLUMN `lang_4_coming_soon_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_3_coming_soon_button`,
ADD COLUMN `lang_5_coming_soon_button`  varchar(255) NULL DEFAULT NULL AFTER `lang_4_coming_soon_button`;
-- END 08-01-2019 --


-- START 18-01-2019 --
delete from config where code = 'is_orange_app';
delete from config where code = 'app_version';

alter table shop_parameters change checkout_login checkout_login tinyint(1) not null default 0;
update page set rang =rang + 1 where rang > 22;
insert into page (name, url, parent, rang) values ('Portal Parameters','/dev_catalog/admin/catalogs/portal_parameters.jsp','Preprod',23);

-- END 18-01-2019 --

-- START 07-02-2019 --
ALTER TABLE `products`
ADD COLUMN `pack_details`  text NULL AFTER `color`;
-- END 07-02-2019 --

-- START 11-02-2019 --
INSERT INTO `page` (`name`, `url`, `parent`, `rang`, `new_tab`) VALUES ('Catalog Products SKU', '/dev_catalog/admin/catalogs/product_sku_list.jsp', 'Preprod', '14', '0');
INSERT INTO `page` (`name`, `url`, `parent`, `rang`, `new_tab`) VALUES ('Configurations', '/dev_catalog/admin/configurations.jsp', 'Gestion', '47', '0');
-- END 11-02-2019 --


-- START 06-03-2019 --
alter table catalogs add catalog_type varchar(30) not null default 'product' ;
alter table products add import_source varchar(50) default null;

---- following table is only required in _catalog as its used in admin screens only

CREATE TABLE `catalog_types` (
  `name` varchar(50) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `product_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert  into catalog_types values ('Accessories','accessory', 'product');
insert  into catalog_types values ('Devices','device', 'product');
insert  into catalog_types values ('Offers Prepaid','offer_prepaid','offer_prepaid');
insert  into catalog_types values ('Offers Postpaid','offer_postpaid','offer_postpaid');
insert  into catalog_types values ('Products','product','product');
insert  into catalog_types values ('Packs Prepaid','pack_prepaid','pack_prepaid');
insert  into catalog_types values ('Packs Postpaid','pack_postpaid','pack_postpaid');
insert  into catalog_types values ('Services','service','service');
insert  into catalog_types values ('Services Night','service_night','service_night');
insert  into catalog_types values ('Services Day','service_day','service_day');
insert  into catalog_types values ('Subscriptions Offline','subscription_offline','subscription_offline');
insert  into catalog_types values ('Subscriptions Online','subscription_online','subscription_online');
insert  into catalog_types values ('Subscriptions App','subscription_webapp','subscription_webapp');
insert  into catalog_types values ('Tarifs','tarif','product');

alter table catalogs add site_id int(11) not null default 0;

update page set url = '/dev_catalog/admin/shop_parameters.jsp' where name = 'Shop Parameters';
update page set url = '/dev_catalog/admin/portal_parameters.jsp' where name = 'Portal Parameters';

update page set url = '/dev_catalog/admin/catalogs/prodfamilies.jsp' where name = 'Famillie' and parent = 'Production';
update page set url = '/dev_catalog/admin/catalogs/families.jsp' where name = 'Famillie' and parent = 'Preprod';

update page set url = '/dev_catalog/admin/gotosite.jsp', name='Site' where name = 'Sites';
delete from page where name = 'Catalog Products';

update page set url = '/dev_catalog/admin/landingpage/pages.jsp?isProd=1' where name = 'Landing Pages' and parent = 'Production';
update page set url = '/dev_catalog/admin/landingpage/pages.jsp' where name = 'Landing Pages' and parent = 'Preprod';

alter table landing_pages add site_id int(11) not null default 0;

update page set url = '/dev_catalog/admin/landingpage/pages.jsp' where name = 'Landing Pages' and parent = 'Preprod';

update page set name = 'Stocks' where name ='Catalog Products Stocks';
update page set name = 'SKUs' where name ='Catalog Products SKU';

update page set url = '/dev_catalog/admin/prodCustomCalendar.jsp' where name = 'Calendar' and parent = 'Production';
update page set url = '/dev_catalog/admin/preprodCustomCalendar.jsp' where name = 'Calendar' and parent = 'Preprod';

drop table catalog_business_types;
drop table business_types;
drop table universes;

alter table catalogs add tax_percentage varchar(10) default null;
alter table catalogs add show_amount_tax_included tinyint(1) not null default 1 ;

alter table products drop business_type;
alter table products drop universe;

-- un-used tables removed
drop table accessories              ;
drop table accessories_lang_1       ;
drop table accessories_lang_2       ;
drop table accessories_lang_3       ;
drop table accessories_lang_4       ;
drop table accessories_lang_5       ;
drop table details_term             ;
drop table details_term_old         ;
drop table forfaits                 ;
drop table info_terminaux_pays      ;
drop table language_bkup            ;
drop table langue_msg_copy          ;
drop table liste_constructeur       ;
drop table prices                   ;
drop table prices_lang_1            ;
drop table prices_lang_2            ;
drop table prices_lang_3            ;
drop table prices_lang_4            ;
drop table prices_lang_5            ;
drop table products_test            ;
drop table questions                ;
drop table recup_img                ;
drop table shop_config              ;
drop table shop_parameters_bkup     ;
drop table tacs                     ;
drop table tarifs                   ;
drop table tarifs_30oct             ;
drop table terminaux                ;
drop table terminaux_lang_1         ;
drop table terminaux_lang_2         ;
drop table terminaux_lang_3         ;
drop table terminaux_lang_4         ;
drop table terminaux_lang_5         ;
drop table terminaux_prices         ;
drop table terminaux_prices_lang_1  ;
drop table terminaux_prices_lang_2  ;
drop table terminaux_prices_lang_3  ;
drop table terminaux_prices_lang_4  ;
drop table terminaux_prices_lang_5  ;
drop table test                     ;
drop table test_page                ;
drop table answer_images;
drop table answers;
drop table pays;

alter table page add icon varchar(25);
alter table page add parent_icon varchar(25);

drop view dev_portal.page;
create view dev_portal.page as select * from dev_catalog.page;

drop view dev_ckeditor.page;
create view dev_ckeditor.page as select * from dev_catalog.page;

drop view dev_pages.page;
create view dev_pages.page as select * from dev_catalog.page;

drop view dev_forms.page;
create view dev_forms.page as select * from dev_catalog.page;

-- for migration of prices after removing business type
update products set price = replace(price,'"bType":"all",','') ;
update products set price_sent = '' where price_sent = '[]';
update products set price_sent =  replace(price_sent, '","bType":"all"}]','');
update products set price_sent =  replace(price_sent, '[{"priceSent":"','');
update products set currency_frequency = '' where currency_frequency = '[]';
update products set currency_frequency =  replace(currency_frequency, '","bType":"all"}]','');
update products set currency_frequency =  replace(currency_frequency, '[{"currencyFrequency":"','');

-- only in _catalog
CREATE TABLE person_sites (
  person_id int(11) not null,
  site_id int(11) not null,
  PRIMARY KEY (person_id, site_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- END 06-03-2019 --

-- START 09-04-2019--

alter table profil add assign_site tinyint(1) not null default 0 ;

drop view dev_portal.profil;
create view dev_portal.profil as select * from dev_catalog.profil;

drop view dev_prod_portal.profil;
create view dev_prod_portal.profil as select * from dev_catalog.profil;

drop view dev_ckeditor.profil;
create view dev_ckeditor.profil as select * from dev_catalog.profil;

drop view dev_forms.profil;
create view dev_forms.profil as select * from dev_catalog.profil;

drop view dev_pages.profil;
create view dev_pages.profil as select * from dev_catalog.profil;

create view dev_portal.person_sites as select * from dev_catalog.person_sites;

create view dev_ckeditor.person_sites as select * from dev_catalog.person_sites;

create view dev_forms.person_sites as select * from dev_catalog.person_sites;

create view dev_pages.person_sites as select * from dev_catalog.person_sites;

create table del_product_attribute_values as select * from product_attribute_values;

alter table product_attribute_values drop column image;
alter table product_attribute_values drop column price_diff;

alter table shop_parameters add site_id int(11) not null AFTER id;
update shop_parameters set site_id = 1 ;
alter table shop_parameters drop id;
alter table shop_parameters add primary key (site_id);

alter table payment_methods add site_id int(11) not null  AFTER id;
alter table delivery_methods add site_id int(11) not null  AFTER id;
alter table fraud_rules add site_id int(11) not null ;

-- this is only required in _catalog
CREATE TABLE `all_delivery_methods` (
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `helpText` text,
  PRIMARY KEY (`method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- following inserts are only required in _catalog
INSERT INTO `all_delivery_methods` VALUES ('home_delivery', 'Livraison à domicile', '');
INSERT INTO `all_delivery_methods` VALUES ('pick_up_in_store', 'Livraison en agence', '');
INSERT INTO `all_delivery_methods` VALUES ('pick_up_in_package_point', 'Livraison point relais', '');

-- this is only required in _catalog
CREATE TABLE `all_payment_methods` (
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `helpText` text,
  `subText` text,
  PRIMARY KEY (`method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- following inserts are only required in _catalog
INSERT INTO `all_payment_methods` VALUES ('credit_card', 'Carte bancaire', '', '');
INSERT INTO `all_payment_methods` VALUES ('cash_on_pickup', 'Paiement en agence', '', '');
INSERT INTO `all_payment_methods` VALUES ('cash_on_delivery', 'Paiement au retrait', '', '');
INSERT INTO `all_payment_methods` VALUES ('orange_money', 'Orange Money', '', '');
INSERT INTO `all_payment_methods` VALUES ('paypal', 'Paypal', '', '');
INSERT INTO `all_payment_methods` VALUES ('payment_method_1', '', '', '');
INSERT INTO `all_payment_methods` VALUES ('payment_method_2', '', '', '');
INSERT INTO `all_payment_methods` VALUES ('payment_method_3', '', '', '');



alter table payment_methods add unique key (site_id, method);
alter table delivery_methods add unique key (site_id, method);

alter table fraud_rules_log add site_id int(11) not null;

delete from dev_commons.config where code = 'ENABLE_ECOMMERCE';
-- END 09-04-2019--



-- START 09-04-2019--

CREATE TABLE `cart_promotion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` TEXT,
  `visible_to` varchar(10) NOT NULL,
  `start_date` DATETIME DEFAULT NULL,
  `end_date` DATETIME DEFAULT NULL,
  `auto_generate_cc` char(1) NOT NULL DEFAULT '',
  `uses_per_coupon` int(10) DEFAULT NULL,
  `uses_per_customer` int(10) DEFAULT NULL,
  `coupon_quantity` int(10) DEFAULT NULL,
  `cc_length` int(10) DEFAULT NULL,
  `cc_prefix` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `cart_promotion_coupon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cp_id` int(11) NOT NULL,
  `coupon_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `cart_promotion_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cp_id` int(11) NOT NULL,
  `rule_field` char(1) DEFAULT '',
  `rule_type` varchar(25) DEFAULT NULL,
  `verify_condition` VARCHAR(255) DEFAULT NULL,
  `rule_condition` VARCHAR(255) DEFAULT NULL,
  `rule_condition_value` VARCHAR(255) DEFAULT NULL,
  `price_diff_applied` VARCHAR(50) DEFAULT NULL,
  `amount` varchar(50) DEFAULT NULL,
  `element_on` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Cart rules','/dev_catalog/admin/catalogs/commercialoffers/cartrules/promotions.jsp','Commercial rules','16','0', 'cui-chevron-right', 'cui-basket-loaded');

-- END 09-04-2019--


-- START 15-04-2019 --
alter table catalogs
 drop INDEX `name`,
 drop INDEX `name_2`,
 ADD UNIQUE KEY `site_id_name` (`site_id`,`name`);

-- END 15-04-2019 --


-- START 16-04-2019 --

CREATE TABLE `product_variants` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `product_id` int(11) NOT NULL comment 'we need product_id as it will make easy to delete and also there will be variants which will not be created make on product attribute values',
	`sku` varchar(100) not null,
	`is_active` tinyint not null default 1,
    `is_default` tinyint not null default 0,
	`price` decimal(10,2) not null,
	`frequency` varchar(20) NULL comment 'this comes from commons.constants product_variant_frequency',
	`commitment` varchar(20) NULL comment 'this comes from commons.constats for parent_key depending upon the frequency selected',
	`stock` int(11) unsigned not null default 0,
	`created_by` int(11) NOT NULL,
	`created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by` int(11) DEFAULT NULL,
    `updated_on` datetime DEFAULT NULL,
	PRIMARY KEY (`id`),
    UNIQUE(`sku`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `product_variant_details` (
	`product_variant_id` int(11) unsigned NOT NULL,
	`langue_id` int(1) not null comment 'language for which the resource was added',
	`name` varchar(255) DEFAULT NULL,
	`main_features` varchar(4000) DEFAULT NULL,
	PRIMARY KEY (`product_variant_id`,`langue_id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `product_variant_ref` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`cat_attrib_id` int(11) unsigned not null,
	`product_attribute_value_id` int(11) UNSIGNED not null,
	`product_variant_id` int(11) UNSIGNED not null,
	PRIMARY KEY (`id`),
	UNIQUE (`cat_attrib_id`,`product_attribute_value_id`,`product_variant_id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `product_variant_resources` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`product_variant_id` int(11) UNSIGNED not null,
	`type` enum('image','video') NOT NULL DEFAULT 'image',
	`langue_id` int(1) not null comment 'language for which the resource was added',
	`path` varchar(500) not null comment 'url ot disk file name',
	`actual_file_name` varchar(500) null comment 'name of the file that was actually uploaded',
	`label` varchar(100),
	`sort_order` TINYINT unsigned not null DEFAULT 1,
	PRIMARY KEY (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;


create table `dev_commons`.`constants` (
	`group` varchar(100) not null,
	`parent_key` varchar(100) not null default '',
	`key` varchar(100) not null,
	`value` varchar(100),
	`sort_order` SMALLINT UNSIGNED not null default 1,
	PRIMARY KEY (`group`,`parent_key`,`key`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table product_attribute_values ADD CONSTRAINT product_id_cat_attrib_id_attribute_value UNIQUE(`product_id`,`cat_attrib_id`,`attribute_value`);

insert into `dev_commons`.`constants` values('product_variant_frequency','','day','Day',100);
insert into `dev_commons`.`constants` values('product_variant_frequency','','week','Week',200);
insert into `dev_commons`.`constants` values('product_variant_frequency','','month','Month',300);
insert into `dev_commons`.`constants` values('product_variant_frequency','','biannual','Bi-Annual',400);
insert into `dev_commons`.`constants` values('product_variant_frequency','','year','Year',500);

insert into `dev_commons`.`constants` values('product_variant_commitment','month','0','without commitment',100);
insert into `dev_commons`.`constants` values('product_variant_commitment','month','12','12 months',200);
insert into `dev_commons`.`constants` values('product_variant_commitment','month','24','24 months',300);

-- END 16-04-2019 --


-- START 30-04-2019 --

CREATE TABLE `additionalfees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `additional_fee` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` DATETIME DEFAULT NULL,
  `end_date` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `additionalfee_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `add_fee_id` int(11) NOT NULL,
  `rule_apply` varchar(50) DEFAULT NULL,
  `rule_apply_value` varchar(50) DEFAULT NULL,
  `element_type` VARCHAR(50) DEFAULT NULL,
  `element_type_value` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Additional fees','/dev_catalog/admin/catalogs/commercialoffers/additionalfees/additionalfees.jsp','Commercial rules','17','0', 'cui-chevron-right', 'cui-basket-loaded');

-- END 30-04-2019--

-- START 08-05-2019 --

CREATE TABLE tags (
  id      varchar(100) NOT NULL ,
  site_id   int(11) UNSIGNED NOT NULL DEFAULT 0 ,
  label     varchar(100) NOT NULL ,
  created_by  int(11) NOT NULL ,
  created_on  datetime NOT NULL ,
  PRIMARY KEY (id, site_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

CREATE TABLE catalog_tags (
  catalog_id  int(11) NOT NULL ,
  tag_id    varchar(100) NOT NULL ,
  created_by  int(11) NOT NULL ,
  created_on  datetime NOT NULL ,
  PRIMARY KEY (catalog_id, tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

CREATE TABLE product_tags (
  product_id  int(11) NOT NULL ,
  tag_id    varchar(100) NOT NULL ,
  created_by  int(11) NOT NULL ,
  created_on  datetime NOT NULL ,
  PRIMARY KEY (product_id, tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;


INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Tags','/dev_catalog/admin/catalogs/tags.jsp','Gestion','48','0', 'cui-tags', 'cui-list');
-- END 08-05-2019--

-- START 14-05-2019
alter table products add column sticker varchar(100) after is_new;

insert into `dev_commons`.`constants` values('product_stickers','','new','New',100);
insert into `dev_commons`.`constants` values('product_stickers','','web','Web exclusive',200);
insert into `dev_commons`.`constants` values('product_stickers','','orange','Orange exclusive',300);

alter table share_bar add column og_active TINYINT not null default 1 after og_image;
alter table share_bar add column twitter_active TINYINT not null default 1 after og_active;
alter table share_bar add column email_active TINYINT not null default 1 after twitter_active;
alter table share_bar add column sms_active TINYINT not null default 1 after email_active;

alter table share_bar change og_image lang_1_og_image varchar(255);
alter table share_bar add column lang_1_og_original_image_name varchar(255) after lang_1_og_image;
alter table share_bar add column lang_1_og_image_label varchar(255) after lang_1_og_original_image_name;
alter table share_bar add column lang_2_og_image varchar(255) after lang_1_og_image_label;
alter table share_bar add column lang_2_og_original_image_name varchar(255) after lang_2_og_image;
alter table share_bar add column lang_2_og_image_label varchar(255) after lang_2_og_original_image_name;
alter table share_bar add column lang_3_og_image varchar(255) after lang_2_og_image_label;
alter table share_bar add column lang_3_og_original_image_name varchar(255) after lang_3_og_image;
alter table share_bar add column lang_3_og_image_label varchar(255) after lang_3_og_original_image_name;
alter table share_bar add column lang_4_og_image varchar(255) after lang_3_og_image_label;
alter table share_bar add column lang_4_og_original_image_name varchar(255) after lang_4_og_image;
alter table share_bar add column lang_4_og_image_label varchar(255) after lang_4_og_original_image_name;
alter table share_bar add column lang_5_og_image varchar(255) after lang_4_og_image_label;
alter table share_bar add column lang_5_og_original_image_name varchar(255) after lang_5_og_image;
alter table share_bar add column lang_5_og_image_label varchar(255) after lang_5_og_original_image_name;

alter table product_images add column langue_id int(1) COMMENT 'for previous compatibility this is nullable field language for which the resource was added';
alter table product_images add column `actual_file_name` varchar(500) DEFAULT NULL COMMENT 'name of the file that was actually uploaded';

-- END 14-05-2019

-- START 17-05-2019 --

CREATE TABLE `promotions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `start_date` DATETIME DEFAULT NULL,
  `end_date` DATETIME DEFAULT NULL,
  `flash_sale` varchar(10) NOT NULL,
  `flash_sale_quantity` int(11) DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `discount_type` varchar(10) NOT NULL,
  `discount_value` varchar(10) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `description` text,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `promotions_rules` (
  `promotion_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Promotions','/dev_catalog/admin/catalogs/commercialoffers/promotions/promotions.jsp','Commercial rules','14','0', 'cui-chevron-right', 'cui-basket-loaded');


-- Ali Adnan

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('RSS Feeds','/dev_pages/admin/rssFeeds.jsp','Contents','64','0', 'cui-rss', 'cui-layers');

alter table shop_parameters add datalayer_domain varchar(255);
alter table shop_parameters add datalayer_brand varchar(255);
alter table shop_parameters add datalayer_market varchar(255);


-- END 17-05-2019 --


-- Start 24-05-2019 ---

CREATE TABLE `product_descriptions` (
  `product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `seo` varchar(500) DEFAULT NULL,
	`summary` varchar(500) DEFAULT NULL,
  `main_features` varchar(4000) DEFAULT NULL,
	`essentials_alignment` varchar(100) not null comment 'comes from constants in dev_common',
  PRIMARY KEY (`product_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `product_essential_blocks`(
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
	`block_text` varchar(4000) not null,
    `file_name` varchar(500) null,
	`actual_file_name` varchar(500) null,
    image_label varchar(100) null,
	primary key(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table product_tabs_del as select * from product_tabs;

drop table product_tabs;

CREATE TABLE `product_tabs`(
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
	`name` varchar(500) null,
	`content` varchar(500) null,
    `order_seq` tinyint unsigned not null default 1,
	primary key(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into product_tabs (product_id,langue_id,name,content)
select product_id,1,lang_1_tab_name,lang_1_tab_text from product_tabs_del;

insert into product_tabs (product_id,langue_id,name,content)
select product_id,2,lang_2_tab_name,lang_2_tab_text from product_tabs_del;

insert into product_tabs (product_id,langue_id,name,content)
select product_id,3,lang_3_tab_name,lang_3_tab_text from product_tabs_del;

insert into product_tabs (product_id,langue_id,name,content)
select product_id,4,lang_4_tab_name,lang_4_tab_text from product_tabs_del;

insert into product_tabs (product_id,langue_id,name,content)
select product_id,5,lang_5_tab_name,lang_5_tab_text from product_tabs_del;

drop table product_tabs_del;

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Breadcrumbs','/dev_catalog/admin/prodbreadcrumbs.jsp','Production','70','0', 'cui-chevron-right', 'cui-list');

insert into `dev_commons`.`constants` values('product_essentials_alignment','','zig_zag_right','Zig Zag - image start at right',100);
insert into `dev_commons`.`constants` values('product_essentials_alignment','','zig_zag_left','Zig Zag - image start at left',200);
insert into `dev_commons`.`constants` values('product_essentials_alignment','','aligned_right','Aligned - image at right',300);
insert into `dev_commons`.`constants` values('product_essentials_alignment','','aligned_left','Aligned - image at left',400);

-- End 24-05-2019 ---


-- ABJ start 14-06-2019 ----
alter table catalog_attributes add column value_type enum('text','color') not null default 'text';

alter table product_attribute_values add column small_text varchar(100) not null default '';
alter table product_attribute_values add column color varchar(50);
-- ABJ end 14-06-2019 ----

-- AA start 20-06-2019 ----
INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('Export Data','/dev_pages/admin/export.jsp','Contents','200','0', 'fas fa-file-export', 'cui-layers');
-- AA end 20-06-2019 ----

-- start 27-06-2019 ----

CREATE TABLE `comewiths` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `comewith` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` DATETIME DEFAULT NULL,
  `end_date` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `comewith_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cw_id` int(11) NOT NULL,
  `cw_opt` varchar(50) DEFAULT NULL,
  `cw_type` varchar(50) DEFAULT NULL,
  `cw_element_type` VARCHAR(50) DEFAULT NULL,
  `cw_element_type_value` VARCHAR(50) DEFAULT NULL,
  `cw_element_asscte` VARCHAR(50) DEFAULT NULL,
  `cw_element_asscte_value` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES
('Come-with','/dev_catalog/admin/catalogs/commercialoffers/comewith/comewiths.jsp','Commercial rules','18','0', 'cui-chevron-right', 'cui-basket-loaded');

-- end 27-06-2019 ----
-- AA start 28-06-2019 ----
INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon)
VALUES ('Import Data','/dev_pages/admin/import.jsp','Contents','201','0', 'fas fa-file-import', 'cui-layers');
-- AA end 28-06-2019 ----

-- AA start 22-07-2019 ----

ALTER TABLE product_descriptions
ADD COLUMN video_url varchar(1500) NOT NULL DEFAULT '' AFTER main_features;

CREATE TABLE catalog_attribute_values (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  cat_attrib_id   int(11) NOT NULL,
  attribute_value varchar(255) NOT NULL,
  small_text      varchar(100) NOT NULL DEFAULT '',
  color           varchar(50) NOT NULL DEFAULT '',
  sort_order      int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY uk_cat_attribute_value (cat_attrib_id,attribute_value)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE product_variant_ref
ADD COLUMN catalog_attribute_value_id  int(11) UNSIGNED NOT NULL DEFAULT 0 AFTER cat_attrib_id,
DROP INDEX cat_attrib_id;

INSERT IGNORE INTO catalog_attribute_values(id, cat_attrib_id, attribute_value, small_text, color, sort_order)
SELECT pav.id, pav.cat_attrib_id, pav.attribute_value, pav.small_text, pav.color, pav.sort_order
FROM product_attribute_values pav
JOIN catalog_attributes ca ON ca.cat_attrib_id = pav.cat_attrib_id AND ca.type = 'selection'
ORDER BY pav.id;

UPDATE product_variant_ref pvr
JOIN product_attribute_values pav ON pav.id = pvr.product_attribute_value_id
JOIN catalog_attribute_values cav ON cav.cat_attrib_id = pav.cat_attrib_id AND cav.attribute_value = pav.attribute_value
SET pvr.catalog_attribute_value_id = cav.id;

DELETE FROM product_variant_ref
WHERE catalog_attribute_value_id = 0;

ALTER TABLE product_variant_ref
DROP COLUMN product_attribute_value_id,
ADD UNIQUE INDEX uk_product_variant_ref (product_variant_id, cat_attrib_id, catalog_attribute_value_id) ;

ALTER TABLE catalog_attributes
ADD COLUMN is_fixed tinyint(1) NOT NULL DEFAULT '0' COMMENT 'cannot update or delete this attribute';

-- AA end 22-07-2019 ----

-- START 26-07-2019 -----
alter table login add last_site_id int(11) ;
-- END 26-07-2019 -------

-- AA START 31-07-2019 -----
DELETE FROM dev_commons.constants WHERE `group` = 'product_variant_frequency';
DELETE FROM dev_commons.constants WHERE `group` = 'product_variant_commitment';

INSERT INTO dev_commons.constants VALUES
('product_variant_frequency', '', 'month', 'Month', '100'),
('product_variant_commitment', 'month', '0', 'without commitment', '100'),
('product_variant_commitment', 'month', '3', '3 months', '200'),
('product_variant_commitment', 'month', '6', '6 months', '300'),
('product_variant_commitment', 'month', '12', '12 months', '400'),
('product_variant_commitment', 'month', '24', '24 months', '500');

DELETE FROM page WHERE url LIKE '%product_stock_list.jsp%';

-- AA END 31-07-2019 -------

-- AA START 07-08-2019 -----
ALTER TABLE product_variant_ref
MODIFY COLUMN product_variant_id  int(11) UNSIGNED NOT NULL AFTER id;


ALTER TABLE product_variants
ADD COLUMN uuid varchar(100) DEFAULT NULL AFTER product_id;

UPDATE product_variants SET uuid = UUID();

ALTER TABLE product_variants
MODIFY COLUMN uuid varchar(100) NOT NULL;

ALTER TABLE product_variants
ADD UNIQUE INDEX uk_product_variants_uuid (uuid) ;
-- AA END 07-08-2019 -------

-- START 20-08-2019 -------
truncate page;

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Dashboard', '/dev_catalog/admin/gestion.jsp', '', '0', '0', 'home', '');

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('FAQ stats', '/dev_menu/pages/prodfaqstats.jsp', 'Activity', '100', '0', 'chevron-right', 'activity');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Pending actions', '/dev_catalog/admin/listpublish.jsp', 'Activity', '101', '0', 'chevron-right', 'activity');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Stats', '/dev_menu/pages/prodstats.jsp', 'Activity', '102', '0', 'chevron-right', 'activity');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Track changes', '/dev_catalog/admin/lastchanges.jsp', 'Activity', '103', '0', 'chevron-right', 'activity');

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Commercial', '/dev_catalog/admin/catalogs/catalogs.jsp', 'Catalogs', '200', '0', 'chevron-right', 'folder');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Families', '/dev_catalog/admin/catalogs/families.jsp', 'Catalogs', '201', '0', 'chevron-right', 'folder');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Knowledge', '', 'Catalogs', '202', '0', 'chevron-right', 'folder');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Products relationship', '/dev_catalog/admin/catalogs/productrelation.jsp', 'Catalogs', '203', '0', 'chevron-right', 'folder');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Tags', '/dev_catalog/admin/catalogs/tags.jsp', 'Catalogs', '204', '0', 'chevron-right', 'folder');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('RSS feeds', '/dev_pages/admin/rssFeeds.jsp', 'Catalogs', '205', '0', 'chevron-right', 'folder');

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Blocks', '/dev_pages/admin/blocs.jsp', 'Content', '300', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Ckeditor', '/dev_ckeditor/pages/htmlPageMain.jsp', 'Content', '301', '1', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Data import', '/dev_pages/admin/import.jsp', 'Content', '302', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Data export', '/dev_pages/admin/export.jsp', 'Content', '303', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Forms', '/dev_forms/admin/process.jsp', 'Content', '304', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Media library', '/dev_pages/admin/imageBrowser.jsp', 'Content', '305', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Landing pages', '/dev_catalog/admin/landingpage/pages.jsp', 'Content', '306', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Pages', '/dev_pages/admin/pages.jsp', 'Content', '307', '0', 'chevron-right', 'file');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Translations', '/dev_catalog/admin/libmsgs.jsp', 'Content', '308', '0', 'chevron-right', 'file');


insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Additional fees', '/dev_catalog/admin/catalogs/commercialoffers/additionalfees/additionalfees.jsp', 'Marketing', '400', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Cart rules', '/dev_catalog/admin/catalogs/commercialoffers/cartrules/promotions.jsp', 'Marketing', '401', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Come-withs', '/dev_catalog/admin/catalogs/commercialoffers/comewith/comewiths.jsp', 'Marketing', '402', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Promotions', '/dev_catalog/admin/catalogs/commercialoffers/promotions/promotions.jsp', 'Marketing', '403', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('SKUs', '/dev_catalog/admin/catalogs/product_sku_list.jsp', 'Marketing', '404', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Stocks test', '/dev_catalog/admin/catalogs/productStocks.jsp', 'Marketing', '405', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Stocks prod', '/dev_catalog/admin/catalogs/prodproductStocks.jsp', 'Marketing', '406', '0', 'chevron-right', 'shopping-cart');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Subsidies', '', 'Marketing', '407', '0', 'chevron-right', 'shopping-cart');

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Breadcrumbs', '/dev_menu/pages/sitemap/prodbreadcrumbs.jsp', 'Navigation', '500', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Menus', '/dev_menu/pages/site.jsp', 'Navigation', '501', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Sitemap', '/dev_menu/pages/sitemap/prodsitemap.jsp', 'Navigation', '502', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Sitemap audit', '/dev_menu/pages/sitemap/prodaudit.jsp', 'Navigation', '503', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('URL generator test', '/dev_catalog/admin/preprodurlgenerator.jsp', 'Navigation', '504', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('URL generator prod', '/dev_catalog/admin/produrlgenerator.jsp', 'Navigation', '505', '0', 'chevron-right', 'navigation');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('URL redirections', '/dev_menu/pages/sitemap/prodredirections.jsp', 'Navigation', '506', '0', 'chevron-right', 'navigation');


insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Backup', '/dev_catalog/admin/backup.jsp', 'System', '600', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Cache', '/dev_menu/pages/prodcachemanagement.jsp', 'System', '601', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Checkout parameters', '/dev_menu/pages/checkoutform.jsp', 'System', '602', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Portal parameters', '/dev_catalog/admin/portal_parameters.jsp', 'System', '603', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Profiles', '/dev_catalog/admin/manageProfil.jsp', 'System', '604', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Shop Parameters', '/dev_catalog/admin/shop_parameters.jsp', 'System', '605', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Site Parameters', '/dev_menu/pages/siteparameters.jsp', 'System', '606', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Users', '/dev_catalog/admin/userManagement.jsp', 'System', '607', '0', 'chevron-right', 'settings');

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Calendar test', '/dev_catalog/admin/preprodCustomCalendar.jsp', 'Tools', '700', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Calendar prod', '/dev_catalog/admin/prodCustomCalendar.jsp', 'Tools', '701', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Dandelion test', '/dev_shop/ibo.jsp', 'Tools', '702', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Dandelion prod', '/dev_prodshop/ibo.jsp', 'Tools', '703', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Data server', 'http://178.32.6.108/phonesdata/', 'Tools', '704', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Expert System', '/dev_catalog/admin/gotoexpertsystem.jsp', 'Tools', '705', '1', 'chevron-right', 'grid');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Resources', '/dev_catalog/admin/resources.jsp', 'Tools', '706', '0', 'chevron-right', 'grid');


insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Block templates', '/dev_pages/admin/blocTemplates.jsp', 'Templates', '800', '0', 'chevron-right', 'layout');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Files', '/dev_pages/admin/files.jsp', 'Templates', '801', '0', 'chevron-right', 'layout');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Libraries', '/dev_pages/admin/libraries.jsp', 'Templates', '802', '0', 'chevron-right', 'layout');

update dev_commons.config set val = '1.5' where code = 'app_version';

-- END 20-08-2019 ---------

-- START 22-08-2019 --
ALTER TABLE `product_tabs` MODIFY COLUMN `content`  text NULL DEFAULT NULL ;

ALTER TABLE `product_variant_details` MODIFY COLUMN `main_features`  text NULL DEFAULT NULL ;

ALTER TABLE `product_descriptions` MODIFY COLUMN `summary`  text NULL DEFAULT NULL ,
MODIFY COLUMN `main_features`  text NULL DEFAULT NULL ;


--- This table is only required in _catalog and has all possible values of catalog types
CREATE TABLE `catalog_types_all` (
  `name` varchar(50) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `product_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

delete from catalog_types_all;
insert  into catalog_types_all values ('Accessories','accessory', 'product');
insert  into catalog_types_all values ('Devices','device', 'product');
insert  into catalog_types_all values ('Offers','offer', 'offer_prepaid,offer_postpaid');
insert  into catalog_types_all values ('Products','product', 'product');
insert  into catalog_types_all values ('Services','service', 'service');
insert  into catalog_types_all values ('Services Night','service_night', 'service_night');
insert  into catalog_types_all values ('Services Day','service_day', 'service_day');
insert  into catalog_types_all values ('Subscriptions Offline','subscription_offline', 'subscription_offline');
insert  into catalog_types_all values ('Subscriptions Online','subscription_online', 'subscription_online');
insert  into catalog_types_all values ('Subscriptions App','subscription_webapp', 'subscription_webapp');


delete from catalog_types;
insert  into catalog_types values ('Accessories','accessory', 'product');
insert  into catalog_types values ('Devices','device', 'product');
insert  into catalog_types values ('Offers','offer', 'offer_prepaid,offer_postpaid');
insert  into catalog_types values ('Products','product', 'product');
insert  into catalog_types values ('Services','service', 'service');
insert  into catalog_types values ('Services Night','service_night', 'service_night');
insert  into catalog_types values ('Services Day','service_day', 'service_day');
insert  into catalog_types values ('Subscriptions Offline','subscription_offline', 'subscription_offline');
insert  into catalog_types values ('Subscriptions Online','subscription_online', 'subscription_online');
insert  into catalog_types values ('Subscriptions App','subscription_webapp', 'subscription_webapp');

CREATE TABLE `eligibility_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(50) DEFAULT NULL,
  `tm` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `email_sent` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 22-08-2019 --

-- START 05-09-2019 --
ALTER TABLE catalog_attributes
MODIFY COLUMN value_type enum('text','color','select') NOT NULL DEFAULT 'text';
-- END 05-09-2019 --


-- START 11-09-2019 --
-- only in _catalog
insert into config (code, val) values ('BACKUP_APP_NAME','dev');
insert into config (code, val) values ('BACKUP_PATH','/home/ronaldo/backups/test/');
insert into config (code, val) values ('BACKUP_LOG_PATH','/home/ronaldo/backups/test/');
insert into config (code, val) values ('BACKUP_APPS_PATH','/home/ronaldo/tomcat/webapps/');
insert into config (code, val) values ('BACKUP_SCRIPT','/home/ronaldo/tomcat/webapps/dev_catalog/admin/backupscript.sh');

insert into dev_commons.config (code, val) values ('FAQS_EXTERNAL_PATH','');
insert into dev_commons.config (code, val) values ('SHOW_SMART_BANNER_OPTION','1');

-- END 11-09-2019 --

-- START 13-09-2019 --
alter table catalogs add version int(10) not null default 1;
alter table products add version int(10) not null default 1;
-- END 13-09-2019 --

-- START 16-09-2019 --
ALTER TABLE catalogs
ADD COLUMN essentials_alignment_lang_1 varchar(100) NOT NULL DEFAULT '' COMMENT 'comes from constants in dev_common' AFTER show_amount_tax_included,
ADD COLUMN essentials_alignment_lang_2 varchar(100) NOT NULL DEFAULT '' AFTER essentials_alignment_lang_1,
ADD COLUMN essentials_alignment_lang_3 varchar(100) NOT NULL DEFAULT '' AFTER essentials_alignment_lang_2,
ADD COLUMN essentials_alignment_lang_4 varchar(100) NOT NULL DEFAULT '' AFTER essentials_alignment_lang_3,
ADD COLUMN essentials_alignment_lang_5 varchar(100) NOT NULL DEFAULT '' AFTER essentials_alignment_lang_4;

CREATE TABLE catalog_essential_blocks (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  catalog_id int(11) unsigned NOT NULL,
  langue_id int(1) NOT NULL COMMENT 'language for which the resource was added',
  block_text varchar(4000) NOT NULL,
  file_name varchar(500) DEFAULT NULL,
  actual_file_name varchar(500) CHARACTER SET latin1 DEFAULT NULL,
  image_label varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `products`
CHANGE COLUMN `action_button_desktop` `lang_1_action_button_desktop`  varchar(75) NULL DEFAULT NULL,
CHANGE COLUMN `action_button_desktop_url` `lang_1_action_button_desktop_url`  varchar(255) NULL DEFAULT NULL,
CHANGE COLUMN `action_button_mobile` `lang_1_action_button_mobile`  varchar(75) NULL DEFAULT NULL,
CHANGE COLUMN `action_button_mobile_url` `lang_1_action_button_mobile_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_2_action_button_desktop`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_3_action_button_desktop`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_4_action_button_desktop`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_5_action_button_desktop`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_2_action_button_desktop_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_3_action_button_desktop_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_4_action_button_desktop_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_5_action_button_desktop_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_2_action_button_mobile`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_3_action_button_mobile`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_4_action_button_mobile`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_5_action_button_mobile`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_2_action_button_mobile_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_3_action_button_mobile_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_4_action_button_mobile_url`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_5_action_button_mobile_url`  varchar(255) NULL DEFAULT NULL;



-- END 16-09-2019 --


-- START 25-09-2019 --

ALTER TABLE `product_variant_details`
ADD COLUMN action_button_desktop varchar(75) NULL DEFAULT NULL,
ADD COLUMN action_button_desktop_url varchar(255) NULL DEFAULT NULL,
ADD COLUMN action_button_mobile varchar(75) NULL DEFAULT NULL,
ADD COLUMN action_button_mobile_url varchar(255) NULL DEFAULT NULL;

ALTER TABLE products
DROP COLUMN `lang_1_action_button_desktop`,
DROP COLUMN `lang_2_action_button_desktop`,
DROP COLUMN `lang_3_action_button_desktop`,
DROP COLUMN `lang_4_action_button_desktop`,
DROP COLUMN `lang_5_action_button_desktop`,
DROP COLUMN `lang_1_action_button_desktop_url`,
DROP COLUMN `lang_2_action_button_desktop_url`,
DROP COLUMN `lang_3_action_button_desktop_url`,
DROP COLUMN `lang_4_action_button_desktop_url`,
DROP COLUMN `lang_5_action_button_desktop_url`,
DROP COLUMN `lang_1_action_button_mobile`,
DROP COLUMN `lang_2_action_button_mobile`,
DROP COLUMN `lang_3_action_button_mobile`,
DROP COLUMN `lang_4_action_button_mobile`,
DROP COLUMN `lang_5_action_button_mobile`,
DROP COLUMN `lang_1_action_button_mobile_url`,
DROP COLUMN `lang_2_action_button_mobile_url`,
DROP COLUMN `lang_3_action_button_mobile_url`,
DROP COLUMN `lang_4_action_button_mobile_url`,
DROP COLUMN `lang_5_action_button_mobile_url`;

-- END 25-09-2019 --


-- START 07-10-2019 --

alter table dev_catalog.config add comments text;
alter table dev_commons.config add comments text;
alter table dev_prod_catalog.config add comments text;

insert into dev_catalog.config (code, val) values ('PROD_DB','dev_prod_catalog');
insert into dev_catalog.config (code, val) values ('DB_NAME','dev_catalog');
insert into dev_catalog.config (code, val) values ('MENU_DESIGNER_URL','/dev_menu/');
insert into dev_catalog.config (code, val) values ('PORTAL_URL','/dev_portal/');
insert into dev_catalog.config (code, val) values ('PROD_PORTAL_URL','/dev_prodportal/');
insert into dev_catalog.config (code, val) values ('PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/sharebar/products/');
insert into dev_catalog.config (code, val) values ('PRODUCT_SHAREBAR_IMAGES_PATH','/dev_catalog/uploads/sharebar/products/');
insert into dev_catalog.config (code, val) values ('PRODUCTS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/products/');
insert into dev_catalog.config (code, val) values ('PRODUCTS_IMG_PATH','/dev_catalog/uploads/products/');
insert into dev_catalog.config (code, val) values ('PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/essentials/');
insert into dev_catalog.config (code, val) values ('PRODUCT_ESSENTIALS_IMG_PATH','/dev_catalog/uploads/essentials/');
insert into dev_catalog.config (code, val) values ('CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/catalogs/essentials/');
insert into dev_catalog.config (code, val) values ('CATALOG_ESSENTIALS_IMG_PATH','/dev_catalog/uploads/catalogs/essentials/');
insert into dev_catalog.config (code, val) values ('PROD_PRODUCTS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/products/');
insert into dev_catalog.config (code, val) values ('PROD_PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/sharebar/products/');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_PRODUCTS_PREPROD','http://127.0.0.1/dev_catalog/listproducts.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_PRODUCTS_PROD','http://127.0.0.1/dev_prodcatalog/listproducts.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_PRODUCT_ITEM_PREPROD','http://127.0.0.1/dev_catalog/product.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_PRODUCT_ITEM_PROD','http://127.0.0.1/dev_prodcatalog/product.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_LANDINGPAGE_PREPROD','http://127.0.0.1/dev_catalog/landingpage.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_LANDINGPAGE_PROD','http://127.0.0.1/dev_prodcatalog/landingpage.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_FORMS_MAIN_PAGE','http://127.0.0.1/dev_forms/forms.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_BLOG_MAIN_PAGE','http://127.0.0.1/dev_ckeditor/blogFrontPage.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_BLOG_ARTICLE_PAGE','http://127.0.0.1/dev_ckeditor/blogViewer.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_HUB_PREPROD','http://127.0.0.1/dev_catalog/hub.jsp');
insert into dev_catalog.config (code, val) values ('INTERNAL_LINK_HUB_PROD','http://127.0.0.1/dev_prodcatalog/hub.jsp');
insert into dev_catalog.config (code, val) values ('IS_PROD_ENVIRONMENT','0');
insert into dev_catalog.config (code, val) values ('SEMAPHORE','D001');
insert into dev_catalog.config (code, val) values ('SHOP_DB','dev_shop');
insert into dev_catalog.config (code, val) values ('PORTAL_DB','dev_portal');
insert into dev_catalog.config (code, val) values ('PORTAL_PROD_DB','dev_prod_portal');
insert into dev_catalog.config (code, val) values ('FAMILIE_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/familie/');
insert into dev_catalog.config (code, val) values ('FAMILIE_IMAGES_PATH','/dev_catalog/uploads/familie/');
insert into dev_catalog.config (code, val) values ('PROD_FAMILIE_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/familie/');
insert into dev_catalog.config (code, val) values ('LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_catalog/uploads/landingpage/');
insert into dev_catalog.config (code, val) values ('LANDINGPAGE_IMAGES_PATH','/dev_catalog/uploads/landingpage/');
insert into dev_catalog.config (code, val) values ('PROD_LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/landingpage/');
insert into dev_catalog.config (code, val) values ('CATALOG_EXTERNAL_URL','/dev_catalog/');
insert into dev_catalog.config (code, val) values ('CKEDITOR_DB','dev_ckeditor');
insert into dev_catalog.config (code, val) values ('CKEDITOR_DOWNLOAD_PAGES_FOLDER','sites/');
insert into dev_catalog.config (code, val) values ('CKEDITOR_URL','http://127.0.0.1/dev_ckeditor/');
insert into dev_catalog.config (code, val) values ('CKEDITOR_APP_URL','/dev_ckeditor/');
insert into dev_catalog.config (code, val) values ('EXPERT_SYSTEM_APP_URL','/dev_expert_system/');
insert into dev_catalog.config (code, val) values ('CART_COOKIE','dev_catalogCartItems');
insert into dev_catalog.config (code, val) values ('CART_URL','/dev_portal/');
insert into dev_catalog.config (code, val) values ('EXTERNAL_CATALOG_LINK','/dev_catalog/');
insert into dev_catalog.config (code, val) values ('CATAPULTE_DB','dev_catapulte');
insert into dev_catalog.config (code, val) values ('SMART_BANNER_ICON_URL','/dev_prodportal/img/smartbanner/');
insert into dev_catalog.config (code, val) values ('SMART_BANNER_ICON_PATH','/home/ronaldo/tomcat/webapps/dev_prodportal/img/smartbanner/');
insert into dev_catalog.config (code, val) values ('ENABLE_CATAPULTE','1');
insert into dev_catalog.config (code, val) values ('PROD_PRODUCTS_IMG_PATH','/dev_prodcatalog/uploads/products/');
insert into dev_catalog.config (code, val) values ('SHOP_PROD_DB','dev_prod_shop');
insert into dev_catalog.config(code,val) values ('COMMONS_DB','dev_commons');


insert into dev_commons.config (code, val) values ('TOMCAT_PATH','/home/ronaldo/tomcat/');
insert into dev_commons.config (code, val) values ('PAGES_DB','dev_pages');
insert into dev_commons.config (code, val) values ('PAGES_PUBLISH_FOLDER','pages/');
insert into dev_commons.config (code, val) values ('PAGES_URL','http://127.0.0.1/dev_pages/');
insert into dev_commons.config (code, val) values ('PAGES_APP_URL','/dev_pages/');
insert into dev_commons.config (code, val) values ('EXTERNAL_FORMS_LINK','/dev_forms/');
insert into dev_commons.config (code, val) values ('FORMS_DB','dev_forms');
insert into dev_commons.config (code, val) values ('POST_WORK_SPLIT_ITEMS','1');
insert into dev_commons.config (code, val) values ('GESTION_URL','/dev_catalog/admin/gestion.jsp');
insert into dev_commons.config (code, val) values ('SSO_DB','dev_sso');
insert into dev_commons.config (code, val) values ('SSO_APP_VERIFY_URL','http://127.0.0.1/dev_sso/verify.jsp');
insert into dev_commons.config (code, val) values ('SESSION_TIMEOUT_MINS','600');


insert into dev_prod_catalog.config (code, val) values ('PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/sharebar/products/');
insert into dev_prod_catalog.config (code, val) values ('PRODUCT_SHAREBAR_IMAGES_PATH','/dev_prodcatalog/uploads/sharebar/products/');
insert into dev_prod_catalog.config (code, val) values ('PRODUCTS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/products/');
insert into dev_prod_catalog.config (code, val) values ('PRODUCTS_IMG_PATH','/dev_prodcatalog/uploads/products/');
insert into dev_prod_catalog.config (code, val) values ('IS_PROD_ENVIRONMENT','1');
insert into dev_prod_catalog.config (code, val) values ('FAMILIE_IMAGES_PATH','/dev_prodcatalog/uploads/familie/');
insert into dev_prod_catalog.config (code, val) values ('CART_COOKIE','dev_prodcatalogCartItems');
insert into dev_prod_catalog.config (code, val) values ('PORTAL_URL','/dev_prodportal/');
insert into dev_prod_catalog.config (code, val) values ('CART_URL','/dev_prodportal/');
insert into dev_prod_catalog.config (code, val) values ('EXTERNAL_CATALOG_LINK','/dev_prodcatalog/');
insert into dev_prod_catalog.config (code, val) values ('SHOP_DB','dev_prod_shop');
insert into dev_prod_catalog.config (code, val) values ('LANDINGPAGE_IMAGES_PATH','/dev_prodcatalog/uploads/landingpage/');
insert into dev_prod_catalog.config (code, val) values ('PORTAL_DB','dev_prod_portal');
insert into dev_prod_catalog.config (code, val) values ('CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/catalogs/essentials/');
insert into dev_prod_catalog.config (code, val) values ('PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/essentials/');
insert into dev_prod_catalog.config(code,val) values ('COMMONS_DB','dev_commons');



delete from dev_commons.config where code = 'FACEBOOK_APP_ID';
delete from dev_commons.config where code = 'TWITTER_ACCOUNT';

update dev_commons.config  set val = '2.0' where code = 'APP_VERSION';



alter table page add requires_ecommerce tinyint(1) not null default 0;

drop view dev_portal.page;
create view dev_portal.page as select * from dev_catalog.page;

drop view dev_pages.page;
create view dev_pages.page as select * from dev_catalog.page;

drop view dev_forms.page;
create view dev_forms.page as select * from dev_catalog.page;

drop view dev_ckeditor.page;
create view dev_ckeditor.page as select * from dev_catalog.page;

update page set requires_ecommerce = 1 where name  in ('Shop Parameters','Checkout parameters','Dandelion test','Dandelion prod','Cart rules','Stocks test','Stocks prod');

update page set new_tab = 0 where name = 'ckeditor';

-- END 07-10-2019 --

-- START 10-10-2019 --

ALTER TABLE `shop_parameters`
ADD COLUMN `lang_1_no_price_display_label`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_2_no_price_display_label`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_3_no_price_display_label`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_4_no_price_display_label`  varchar(75) NULL DEFAULT NULL,
ADD COLUMN `lang_5_no_price_display_label`  varchar(75) NULL DEFAULT NULL;

ALTER TABLE product_variants
ADD COLUMN is_show_price tinyint(1) NOT NULL DEFAULT '1' AFTER is_default;

-- END 10-10-2019 --

-- START 15-10-2019 --
UPDATE catalog_attributes
SET visible_to = 'all'
WHERE visible_to NOT IN ('all','logged_customer');

ALTER TABLE catalog_attributes
MODIFY COLUMN visible_to  enum('all','logged_customer') NOT NULL DEFAULT 'all' AFTER name;
-- END 15-10-2019 --

-- START 18-10-2019 --
ALTER TABLE `catalogs`
ADD COLUMN `lang_1_description`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_2_description`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_3_description`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_4_description`  varchar(255) NULL DEFAULT NULL,
ADD COLUMN `lang_5_description`  varchar(255) NULL DEFAULT NULL;
-- END 18-10-2019 --

-- START 28-10-2019 --

ALTER TABLE products DROP COLUMN sticker;
ALTER TABLE product_variants ADD COLUMN sticker varchar(100) DEFAULT NULL;

INSERT INTO dev_commons.constants VALUES('product_stickers','','none','No sticker','50');

insert into profil (profil, description, assign_site) values ('SITE_ACCESS','Sites access',1);

-- END 28-10-2019 --


-- START 28-10-2019 --
#Orange countries have bigger text in summary columns
alter table product_descriptions change summary summary text;

alter table profil change assign_site assign_site tinyint(1) not null default 1;
update profil set assign_site = 1;
update profil set assign_site = 0 where profil in ('ADMIN','TEST_SITE_ACCESS','PROD_SITE_ACCESS','PROD_CACHE_MGMT','PROD_PUBLISH','SUPER_ADMIN');
-- END 28-10-2019 --


-- START 14-11-2019 --
#Merge comwith and comewith_rules table
ALTER TABLE comewiths DROP COLUMN comewith;
ALTER TABLE comewiths ADD COLUMN name VARCHAR(255) DEFAULT NULL AFTER updated_on;
ALTER TABLE comewiths ADD COLUMN comewith VARCHAR(50) DEFAULT NULL;
ALTER TABLE comewiths ADD COLUMN type VARCHAR(10) DEFAULT NULL;
ALTER TABLE comewiths ADD COLUMN element_type VARCHAR(50) DEFAULT NULL;
ALTER TABLE comewiths ADD COLUMN element_type_value VARCHAR(255) DEFAULT NULL;
ALTER TABLE comewiths ADD COLUMN linked_prod VARCHAR(50) DEFAULT NULL;
ALTER TABLE comewiths ADD COLUMN linked_prod_val VARCHAR(255) DEFAULT NULL;
DROP TABLE comewith_rules;
-- END 14-11-2019 --

-- START 19-11-2019 --
ALTER TABLE additionalfees CHANGE description lang_1_description TEXT;
ALTER TABLE additionalfees ADD COLUMN lang_2_description TEXT AFTER lang_1_description;
ALTER TABLE additionalfees ADD COLUMN lang_3_description TEXT AFTER lang_2_description;
ALTER TABLE additionalfees ADD COLUMN lang_4_description TEXT AFTER lang_3_description;
ALTER TABLE additionalfees ADD COLUMN lang_5_description TEXT AFTER lang_4_description;

ALTER TABLE comewiths CHANGE description lang_1_description TEXT;
ALTER TABLE comewiths ADD COLUMN lang_2_description TEXT AFTER lang_1_description;
ALTER TABLE comewiths ADD COLUMN lang_3_description TEXT AFTER lang_2_description;
ALTER TABLE comewiths ADD COLUMN lang_4_description TEXT AFTER lang_3_description;
ALTER TABLE comewiths ADD COLUMN lang_5_description TEXT AFTER lang_4_description;

ALTER TABLE promotions CHANGE description lang_1_description TEXT;
ALTER TABLE promotions ADD COLUMN lang_2_description TEXT AFTER lang_1_description;
ALTER TABLE promotions ADD COLUMN lang_3_description TEXT AFTER lang_2_description;
ALTER TABLE promotions ADD COLUMN lang_4_description TEXT AFTER lang_3_description;
ALTER TABLE promotions ADD COLUMN lang_5_description TEXT AFTER lang_4_description;

insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Client Profils', '/dev_menu/pages/prodprofilhomepage.jsp', 'System', '608', '0', 'chevron-right', 'settings');
insert into page (name, url, parent, rang, new_tab, icon, parent_icon) values ('Clients', '/dev_menu/pages/prodclientprofilhomepage.jsp', 'System', '609', '0', 'chevron-right', 'settings');

ALTER TABLE `promotions`
ADD COLUMN `lang_1_title`  varchar(500) NULL DEFAULT NULL,
ADD COLUMN `lang_2_title`  varchar(500) NULL DEFAULT NULL,
ADD COLUMN `lang_3_title`  varchar(500) NULL DEFAULT NULL,
ADD COLUMN `lang_4_title`  varchar(500) NULL DEFAULT NULL,
ADD COLUMN `lang_5_title`  varchar(500) NULL DEFAULT NULL;

insert into dev_commons.config (code, val) values ('PAGES_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_pages/uploads/');
alter table product_descriptions change main_features main_features text;

-- END 19-11-2019 --

update  catalog_attributes set migration_name = name where  name="GENERALFEATURES DIMENSIONS UNIT";
update  catalog_attributes set migration_name = name where  name="GENERALFEATURES DIMENSIONS VALUE";
update  catalog_attributes set migration_name = name where  name="GENERALFEATURES WEIGHT VALUE";
update  catalog_attributes set migration_name = name where  name="GENERALFEATURES WEIGHT UNIT";
update  catalog_attributes set migration_name = name where  name="GENERALFEATURES SIMCARDFORMAT";
update  catalog_attributes set migration_name = name where  name="HARDWARE EXTERNALMEMORY";
update  catalog_attributes set migration_name = name where  name="GENERALFEATURES DAS";
update  catalog_attributes set migration_name = name where  name="HARDWARE BATTERYCAPACITY VALUE";
update  catalog_attributes set migration_name = name where  name="HARDWARE BATTERYCAPACITY UNIT";
update  catalog_attributes set migration_name = name where  name="HARDWARE STANDBYTIME VALUE";
update  catalog_attributes set migration_name = name where  name="HARDWARE STANDBYTIME UNIT";
update  catalog_attributes set migration_name = name where  name="HARDWARE TALKTIME VALUE";
update  catalog_attributes set migration_name = name where  name="HARDWARE TALKTIME UNIT";
update  catalog_attributes set migration_name = name where  name="TECHRADIO TECHRADIO";
update  catalog_attributes set migration_name = name where  name="TECHRADIO WIFI";
update  catalog_attributes set migration_name = name where  name="TECHRADIO BLUETOOTH";
update  catalog_attributes set migration_name = name where  name="TECHRADIO NFC";
update  catalog_attributes set migration_name = name where  name="TECHRADIO GPS";
update  catalog_attributes set migration_name = name where  name="TECHRADIO TETHERING";
update  catalog_attributes set migration_name = name where  name="HARDWARE INTERNALMEMORY";
update  catalog_attributes set migration_name = name where  name="SCREEN TOUCHSCREEN";
update  catalog_attributes set migration_name = name where  name="SCREEN SCREENDIAGONAL VALUE";
update  catalog_attributes set migration_name = name where  name="SCREEN SCREENDIAGONAL UNIT";
update  catalog_attributes set migration_name = name where  name="SCREEN SCREENDIAGONAL VALUE";
update  catalog_attributes set migration_name = name where  name="SCREEN SCREENDIAGONAL UNIT";
update  catalog_attributes set migration_name = name where  name="SCREEN SCREENTECH";
update  catalog_attributes set migration_name = name where  name="SCREEN RESOLUTION VALUE";
update  catalog_attributes set migration_name = name where  name="SCREEN RESOLUTION UNIT";
update  catalog_attributes set migration_name = name where  name="CAMERA RESOLUTION VALUE";
update  catalog_attributes set migration_name = name where  name="CAMERA RESOLUTION UNIT";
update  catalog_attributes set migration_name = name where  name="CAMERA FLASH";
update  catalog_attributes set migration_name = name where  name="CAMERA ZOOM";
update  catalog_attributes set migration_name = name where  name="CAMERA AUTOFOCUS";
update  catalog_attributes set migration_name = name where  name="CAMERA STABILISATION";
update  catalog_attributes set migration_name = name where  name="CAMERA FRONTCAMRESOLUTION VALUE";
update  catalog_attributes set migration_name = name where  name="CAMERA FRONTCAMRESOLUTION UNIT";
update  catalog_attributes set migration_name = name where  name="CAMERA VIDEOSOFT";
update  catalog_attributes set migration_name = name where  name="VOICE FMRADIO";
update  catalog_attributes set migration_name = name where  name="VOICE MP3READER";
update  catalog_attributes set migration_name = name where  name="CAMERA VIDEOCAPTURE";
update  catalog_attributes set migration_name = name where  name="VOICE JACK35";
update  catalog_attributes set migration_name = name where  name="VOICE SPEAKERS";
update  catalog_attributes set migration_name = name where  name="VOICE VOICEHD";
