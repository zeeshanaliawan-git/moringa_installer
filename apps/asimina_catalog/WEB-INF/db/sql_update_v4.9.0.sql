update dev_commons.config set val = '4.9.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.9.0.1' where code = 'CSS_JS_VERSION';


-------------------------------------- Ahsan Start 11 July 2024 --------------------------------------
CREATE TABLE payment_n_delivery_method_excluded_items (
    id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    item_type VARCHAR(25) NOT NULL,
    item_id VARCHAR(70) NOT NULL,
    method VARCHAR(50) NOT NULL,
    method_sub_type VARCHAR(50),
    method_type ENUM('payment', 'delivery') NOT NULL,
    site_id INT(11) NOT NULL,
    UNIQUE KEY uk_item_type_method (item_type, item_id, method,method_type,method_sub_type)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE variant_tags (
    id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    variant_id int(11) NOT NULL,
    tag_id VARCHAR(100) NOT NULL,
    created_by int(11) NOT NULL,
    created_on datetime NOT NULL,
    UNIQUE KEY uk_item_type_method (variant_id,tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-------------------------------------- Ahsan End 11 July 2024 --------------------------------------

-- dev catalog
alter table dev_catalog.quantitylimits_tbl add index idx1 (site_id);
alter table dev_catalog.quantitylimits_rules add index idx1 (quantitylimit_id);

alter table dev_prod_catalog.quantitylimits add index idx1 (site_id);
alter table dev_prod_catalog.quantitylimits_rules add index idx1 (quantitylimit_id);



use dev_prod_catalog;
create table products_v49 as select * from products;

use dev_catalog;
create table products_v49 as select * from products;
update dev_catalog.products p join dev_prod_catalog.products p2 on p.id = p2.id set p.product_uuid = p2.product_uuid;

--for testing to make sure prod IDs are not changed
select p.id, p.product_uuid from dev_catalog.products p join dev_prod_catalog.products p2 on p.id = p2.id where p.product_uuid not in (select product_uuid from dev_prod_catalog.products);
select id, product_uuid from dev_prod_catalog.products where product_uuid not in (select product_uuid from dev_prod_catalog.products_v49);



create table dev_commons.webapps_auth_tokens (
id varchar(75) not null,
expiry TIMESTAMP not null,
access_id varchar(75) not null,
catalog_session_id varchar(75) not null,
primary key (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
