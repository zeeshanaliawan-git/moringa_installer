update dev_commons.config set val = '3.3.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.3.0.1' where code = 'CSS_JS_VERSION';

alter table page add menu_badge varchar(25);
update page set menu_badge = 'BETA' where name in ('Menus (new)','Menu js');

insert into page (name, url, rang, icon, menu_badge) values ('Trash','/dev_catalog/admin/catalogs/trash.jsp',1000, 'trash','BETA');
----------------------------------------------------------start 29/3/2022 Ahsan----------------------------------------------------------

INSERT INTO dev_commons.config (code,val) VALUES('EXPERT_SYSTEM_DB','dev_expert_system');

						------- For dev Catalog -------	
ALTER TABLE dev_catalog.products RENAME TO products_tbl;
ALTER TABLE dev_catalog.products_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.products AS SELECT * FROM products_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.catalogs RENAME TO catalogs_tbl;
ALTER TABLE dev_catalog.catalogs_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.catalogs AS SELECT * FROM catalogs_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.products_folders RENAME TO products_folders_tbl;
ALTER TABLE dev_catalog.products_folders_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.products_folders AS SELECT * FROM products_folders_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.additionalfees RENAME TO additionalfees_tbl;
ALTER TABLE dev_catalog.additionalfees_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.additionalfees AS SELECT * FROM additionalfees_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.cart_promotion RENAME TO cart_promotion_tbl;
ALTER TABLE dev_catalog.cart_promotion_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.cart_promotion AS SELECT * FROM cart_promotion_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.promotions RENAME TO promotions_tbl;
ALTER TABLE dev_catalog.promotions_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.promotions AS SELECT * FROM promotions_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.comewiths RENAME TO comewiths_tbl;
ALTER TABLE dev_catalog.comewiths_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.comewiths AS SELECT * FROM comewiths_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.subsidies RENAME TO subsidies_tbl;
ALTER TABLE dev_catalog.subsidies_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.subsidies AS SELECT * FROM subsidies_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.deliveryfees RENAME TO deliveryfees_tbl;
ALTER TABLE dev_catalog.deliveryfees_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.deliveryfees AS SELECT * FROM deliveryfees_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.deliverymins RENAME TO deliverymins_tbl;
ALTER TABLE dev_catalog.deliverymins_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.deliverymins AS SELECT * FROM deliverymins_tbl WHERE is_deleted =0;

ALTER TABLE dev_catalog.quantitylimits RENAME TO dev_catalog.quantitylimits_tbl;
ALTER TABLE dev_catalog.quantitylimits_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_catalog.quantitylimits AS SELECT * FROM quantitylimits_tbl WHERE is_deleted =0;


---- in prod_catalog ----
ALTER TABLE dev_prod_catalog.products_folders ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.catalogs ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.products ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.additionalfees ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.cart_promotion ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.promotions ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.comewiths ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.subsidies ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.deliveryfees ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.deliverymins ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_prod_catalog.quantitylimits ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;


-----------------------------------------------End 4/4/2022 Ahsan----------------------------------------------------------