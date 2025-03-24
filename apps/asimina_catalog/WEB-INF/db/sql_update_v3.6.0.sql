update dev_commons.config set val = '3.6.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.6.0.1' where code = 'CSS_JS_VERSION';
----------Start 2/8/2022 Ahsan--------------
create table dev_commons.reload_translations(
 	id	 VARCHAR(100) NOT NULL,
	updated_dt  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
	PRIMARY KEY  (id)
)ENGINE = MyISAM DEFAULT CHARSET = utf8;

insert into dev_commons.config (CODE,val) values ('PORTAL_APP','dev_portal'),('PROD_PORTAL_APP','dev_prodportal');

----------End 2/8/2022 Ahsan--------------
-- only in dev_catalog --
alter table dev_catalog.deliveryfees_tbl add delivery_type varchar(75);
drop view dev_catalog.deliveryfees;
create view dev_catalog.deliveryfees as select * from dev_catalog.deliveryfees_tbl where is_deleted = 0;

-- only in dev_prod_catalog --
alter table dev_prod_catalog.deliveryfees add delivery_type varchar(75);



--- IMPORTANT : This query will only be executed in dev_catalog
create table dev_catalog.products_tbl_uuid as select * from products_tbl;
update dev_catalog.products_tbl set product_uuid = uuid();
---------------------------------------------------------------
alter table dev_catalog.products_tbl add unique key uniq_uuid (product_uuid);
alter table dev_prod_catalog.products add unique key uniq_uuid (product_uuid);
