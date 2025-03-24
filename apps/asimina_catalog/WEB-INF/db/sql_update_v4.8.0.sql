update dev_commons.config set val = '4.8.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.8.0.1' where code = 'CSS_JS_VERSION';

-- Added Holiday Name in dev_common databes.
ALTER TABLE dev_commons.local_holidays 
ADD holiday_name VARCHAR(255) DEFAULT NULL;

-- Added cartType (card2wallet) dev_catalog databes.
ALTER TABLE fraud_rules MODIFY cart_type ENUM('topup', 'normal', 'card2wallet');

-- Added cart_type to unique.
ALTER TABLE `fraud_rules`
DROP PRIMARY KEY,
ADD PRIMARY KEY (`column`, `days`, `site_id`, `cart_type`);


------------- Start Ahsan 30 May 2024 -------------

INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon, menu_badge) 
VALUES ('Product parameters', '/dev_catalog/admin/catalogs/v2/products/product_parameters.jsp', 'System', '603', '0', 'chevron-right', 'settings', 'BETA');


        ------------------------ Also in prod catalog db ------------------------
insert into config (code,val) values ('max_category_level','5');

CREATE TABLE attributes_v2(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(), 
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'text',
	site_id INT(11) NOT NULL,
	created_ts timestamp NOT NULL DEFAULT current_timestamp(),
    created_by int(11) DEFAULT NULL,
    updated_by int(11) DEFAULT NULL,
    updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    UNIQUE KEY `uk_name_site` (`name`,`site_id`)
)ENGINE=MYISAM DEFAULT CHARSET=utf8;

CREATE TABLE attributes_values_v2(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    label VARCHAR(100) NOT NULL,
    value VARCHAR(100) NOT NULL,
	attr_id INT(11) NOT NULL
)ENGINE=MYISAM DEFAULT CHARSET=utf8;


CREATE TABLE categories_v2(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(), 
    name VARCHAR(150) NOT NULL,
    level int(11) NOT NULL DEFAULT 0,
    parent_id int(11) DEFAULT 0,
	site_id INT(11) NOT NULL,
	created_ts timestamp NOT NULL DEFAULT current_timestamp(),
    created_by int(11) DEFAULT NULL,
    updated_by int(11) DEFAULT NULL,
    updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    UNIQUE KEY `uk_name_site` (`name`,`site_id`,`parent_id`)
)ENGINE=MYISAM DEFAULT CHARSET=utf8;

CREATE TABLE product_types_v2(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(), 
    type_name VARCHAR(150) NOT NULL,
    template_id INT(11) NOT NULL,
    site_id INT(11) NOT NULL,
	created_ts timestamp NOT NULL DEFAULT current_timestamp(),
    created_by int(11) DEFAULT NULL,
    updated_by int(11) DEFAULT NULL,
    updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    UNIQUE KEY `uk_name_site` (`type_name`,`site_id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE product_v2_categories_and_attributes(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(), 
    reference_uuid VARCHAR(36) NOT NULL, 
    product_type_uuid VARCHAR(36) NOT NULL,
    reference_type ENUM('attribute','category') NOT NULL
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE product_v2_specifications(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(), 
    product_type_uuid VARCHAR(36) NOT NULL,
    data_entry_type ENUM('manual','icecat') NOT NULL DEFAULT 'manual', 
    data_type ENUM('free','json'),
    specification text
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

        ------------------------ up utill here ------------------------

alter table products_tbl add column product_definition_id int(11);
DROP VIEW IF EXISTS products;
CREATE VIEW products AS SELECT * FROM products_tbl WHERE is_deleted = 0;

CREATE TABLE products_definition_tbl(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(),
    save_type varchar(20) not null,
    name varchar(50) not null,
    url varchar(100) not null,
    title varchar(100) not null,
    meta_description text not null,
    product_type int(11) not null,
    site_id INT(11) NOT NULL,
    catalog_id INT(11) NOT NULL,
    folder_id INT(11),
    piblish_ts datetime DEFAULT NULL,
    piblish_by int(11) DEFAULT NULL,
    to_publish TINYINT(1) not null default 0,
    created_ts timestamp NOT NULL DEFAULT current_timestamp(),
    created_by int(11) DEFAULT NULL,
    updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    updated_by int(11) DEFAULT NULL,
    is_deleted tinyint(1) not null default 0,
    UNIQUE KEY `uk_product_key` (`name`,`site_id`,`catalog_id`,`folder_id`,`is_deleted`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP VIEW IF EXISTS products_definition;
CREATE VIEW products_definition AS SELECT * FROM products_definition_tbl WHERE is_deleted = 0;

alter table catalogs_tbl add column catalog_version varchar(10) not null default 'V1';
DROP VIEW IF EXISTS catalogs;
CREATE VIEW catalogs AS SELECT * FROM catalogs_tbl WHERE is_deleted = 0;

alter table products_tbl add column product_version varchar(10) not null default 'V1';
DROP VIEW IF EXISTS products;
CREATE VIEW products AS SELECT * FROM products_tbl WHERE is_deleted = 0;

insert into config (code,val) VALUES ('max_catalogs_folder_level','4');

ALTER TABLE products_folders_tbl MODIFY COLUMN folder_level INT(11);


INSERT INTO page (name, url, parent, rang, new_tab, icon, parent_icon, menu_badge) 
VALUES ('Products New', '/dev_catalog/admin/catalogs/v2/catalogs/catalogs.jsp', 'Content', '302', '0', 'chevron-right', 'file-text', 'BETA');

------------------------ Only in prod catalog db ------------------------
alter table products add column product_definition_id int(11);
CREATE TABLE products_definition(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(),
    save_type varchar(20) not null,
    name varchar(50) not null,
    url varchar(100) not null,
    title varchar(100) not null,
    meta_description text not null,
    product_type int(11) not null,
    site_id INT(11) NOT NULL,
    catalog_id INT(11) NOT NULL,
    folder_id INT(11),
    piblish_ts datetime DEFAULT NULL,
    piblish_by int(11) DEFAULT NULL,
    to_publish TINYINT(1) not null default 0,
    created_ts timestamp NOT NULL DEFAULT current_timestamp(),
    created_by int(11) DEFAULT NULL,
    updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    updated_by int(11) DEFAULT NULL,
    is_deleted tinyint(1) not null default 0,
    UNIQUE KEY `uk_product_key` (`name`,`site_id`,`catalog_id`,`folder_id`,`is_deleted`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table catalogs add column catalog_version varchar(10) not null default 'V1';
alter table products add column product_version varchar(10) not null default 'V1';
insert into config (code,val) VALUES ('max_catalogs_folder_level','4');
ALTER TABLE products_folders MODIFY COLUMN folder_level INT(11);
------------------------------------------------

alter table product_variants add column ean varchar(255);

------------- End Ahsan 5 July 2024 -------------

-- start dev_catalog only
alter table comewiths_tbl add price_difference double not null default 0;
drop view comewiths;
create view comewiths as select * from comewiths_tbl where is_deleted = 0;
-- end dev_catalog only

-- start dev_prod_catalog only
alter table comewiths add price_difference double not null default 0;
-- end dev_prod_catalog only


create table cart_promotion_on_elements (
cart_promo_id int(11) not null,
element_on varchar(20),
element_on_value varchar(255),
PRIMARY key (cart_promo_id, element_on, element_on_value)
)engine=myisam default CHARSET=utf8;

insert into cart_promotion_on_elements (cart_promo_id, element_on, element_on_value) select id, element_on, element_on_value from cart_promotion where coalesce(element_on_value,'') <> '' and coalesce(element_on,'') in ('product','sku');
update cart_promotion set element_on = 'list' where coalesce(element_on,'') in ('product','sku');

-- start dev_catalog only
alter table cart_promotion_tbl drop element_on_value;
drop view cart_promotion;
create view cart_promotion as select * from cart_promotion_tbl where is_deleted = 0;
-- end dev_catalog only

-- start dev_prod_catalog only
alter table cart_promotion drop element_on_value;
-- end dev_prod_catalog only
