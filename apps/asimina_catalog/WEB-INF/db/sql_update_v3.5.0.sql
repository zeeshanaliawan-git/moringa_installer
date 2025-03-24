update dev_commons.config set val = '3.5.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.5.0.1' where code = 'CSS_JS_VERSION';

-------------Start 21 June 2022 Ahsan--------------------
ALTER TABLE catalogs_tbl DROP INDEX site_id_name;
ALTER TABLE catalogs_tbl ADD CONSTRAINT site_id_name UNIQUE (`is_deleted`,`site_id`,`name`);

ALTER TABLE products_folders_tbl DROP INDEX uk_products_folders;
ALTER TABLE products_folders_tbl ADD CONSTRAINT uk_products_folders UNIQUE (`is_deleted`,`site_id`,`catalog_id`,`name`,`parent_folder_id`);

ALTER TABLE shop_parameters ADD COLUMN incomplete_cart_email_id_prod INT(11), ADD COLUMN incomplete_cart_email_id_test INT(11);

CREATE TABLE dev_commons.engines_status(
	engine_name VARCHAR(100) NOT NULL,
	start_date datetime,
	end_date datetime,
	PRIMARY KEY (`engine_name`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO dev_commons.config (CODE,val) VALUES('OBSERVER_ENGINES','Catalog,Pages,Forms,Shop,Portal');

INSERT INTO page (NAME,url,parent,rang,icon,parent_icon,menu_badge) 
VALUES ('Engines Activity','/dev_catalog/admin/catalogs/engineActivity.jsp','System',614,'chevron-right','settings','BETA');

INSERT INTO dev_commons.config (CODE,val) 
VALUES ('MAIL_FROM','noreply@testportail.app'),('MAIL_REPLY','noreply@testportail.app');

update dev_commons.config c, dev_forms.config f set c.val = f.val where c.code = f.code and c.code = 'MAIL_FROM';
update dev_commons.config c, dev_forms.config f set c.val = f.val where c.code = f.code and c.code = 'MAIL_REPLY';

-------------End 27 June 2022 Ahsan--------------------

update products set discount_prices = null , service_schedule = null;

insert into dev_commons.config (code, val, comments) values  ('allow_iframe_domains','','comma separate list of domains for which are allowed to include cached page as iframe');


----- Change for Topup API done by ABJ ----- 
alter table dev_catalog.all_payment_methods add column test_redirect_url varchar(255);
alter table dev_catalog.all_payment_methods add column prod_redirect_url varchar(255); 
----- End change -----

insert into config (code, val) values ('OBSERVER_SEND_EMAILS_TO','umair@codehoppers.com,ahsan.abbas@codehoppers.com');
insert into config (code, val) values ('OBSERVER_ENGINE_TIME_MINS','10');