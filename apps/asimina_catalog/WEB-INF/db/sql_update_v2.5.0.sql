-- START 14-10-2020 --
update dev_commons.config set val = '2.5.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.5.0.0' where code = 'CSS_JS_VERSION';
-- END 14-10-2020 --

-- START 23-10-2020 --
ALTER TABLE `shop_parameters`
ADD COLUMN `deliver_outside_dep`  tinyint(1) NULL DEFAULT 1 AFTER `lang_5_empty_cart_url`,
ADD COLUMN `lang_1_deliver_outside_dep_error`  varchar(255) NULL DEFAULT '' AFTER `deliver_outside_dep`,
ADD COLUMN `lang_2_deliver_outside_dep_error`  varchar(255) NULL DEFAULT '' AFTER `lang_1_deliver_outside_dep_error`,
ADD COLUMN `lang_3_deliver_outside_dep_error`  varchar(255) NULL DEFAULT '' AFTER `lang_2_deliver_outside_dep_error`,
ADD COLUMN `lang_4_deliver_outside_dep_error`  varchar(255) NULL DEFAULT '' AFTER `lang_3_deliver_outside_dep_error`,
ADD COLUMN `lang_5_deliver_outside_dep_error`  varchar(255) NULL DEFAULT '' AFTER `lang_4_deliver_outside_dep_error`;

CREATE TABLE `deliveryfees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `dep_type` varchar(10) NOT NULL,
  `dep_value` varchar(64) NOT NULL,
  `fee` varchar(10) DEFAULT NULL,
  `applicable_per_item` tinyint(1) DEFAULT 0,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `deliveryfees_rules` (
  `deliveryfee_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL,
  PRIMARY KEY (`deliveryfee_id`,`applied_to_type`,`applied_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `deliverymins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `dep_type` varchar(10) NOT NULL,
  `dep_value` varchar(64) NOT NULL,
  `minimum_total` varchar(10) DEFAULT NULL,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ONLY in _catalog
INSERT INTO page(name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce) VALUES
("Delivery Fees", "/dev_catalog/admin/catalogs/commercialoffers/delivery/deliveryfees.jsp", "Marketing", "408", "0", "chevron-right", "shopping-cart", "1");
INSERT INTO page(name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce) VALUES
("Delivery Minimums", "/dev_catalog/admin/catalogs/commercialoffers/delivery/deliverymins.jsp", "Marketing", "409", "0", "chevron-right", "shopping-cart", "1");

INSERT INTO `coordinates` VALUES
(10,10,584,500,'deliveryfees','ADMIN',NULL),
(48,195,120,80,'deliveryfees','ADMIN','publish'),
(343,114,120,80,'deliveryfees','ADMIN','published'),
(43,284,120,80,'deliveryfees','ADMIN','delete'),
(347,283,120,80,'deliveryfees','ADMIN','deleted'),
(180,407,120,80,'deliveryfees','ADMIN','cancel'),
(620,10,300,500,'deliveryfees','PROD_SITE_ACCESS',NULL),
(924,18,300,500,'deliveryfees','PROD_CACHE_MGMT',NULL),
(50,62,120,80,'deliveryfees','ADMIN','publish_ordering');

INSERT INTO `has_action` VALUES
('deliveryfees','delete',43,'remove:deliveryfee'),
('deliveryfees','publish',44,'publish:deliveryfee'),
('deliveryfees','publish_ordering',45,'publishorder:deliveryfee');

INSERT INTO `phases` VALUES ('deliveryfees','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('deliveryfees','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('deliveryfees','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('deliveryfees','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('deliveryfees','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('deliveryfees','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O');

INSERT INTO `rules` VALUES ('deliveryfees','delete',0,'deliveryfees','deleted',0,'remove:deliveryfee',0,43,0,'And','0','Cancelled'),('deliveryfees','publish',0,'deliveryfees','published',0,'publish:deliveryfee',0,44,0,'And','0','Cancelled'),('deliveryfees','publish_ordering',0,'deliveryfees','published',0,'publishorder:deliveryfee',0,45,0,'And','0','Cancelled');

INSERT INTO `coordinates` VALUES
(10,10,584,500,'deliverymins','ADMIN',NULL),
(48,195,120,80,'deliverymins','ADMIN','publish'),
(343,114,120,80,'deliverymins','ADMIN','published'),
(43,284,120,80,'deliverymins','ADMIN','delete'),
(347,283,120,80,'deliverymins','ADMIN','deleted'),
(180,407,120,80,'deliverymins','ADMIN','cancel'),
(620,10,300,500,'deliverymins','PROD_SITE_ACCESS',NULL),
(924,18,300,500,'deliverymins','PROD_CACHE_MGMT',NULL),
(50,62,120,80,'deliverymins','ADMIN','publish_ordering');

INSERT INTO `has_action` VALUES
('deliverymins','delete',46,'remove:deliverymin'),
('deliverymins','publish',47,'publish:deliverymin'),
('deliverymins','publish_ordering',48,'publishorder:deliverymin');

INSERT INTO `phases` VALUES ('deliverymins','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('deliverymins','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('deliverymins','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('deliverymins','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('deliverymins','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('deliverymins','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O');

INSERT INTO `rules` VALUES ('deliverymins','delete',0,'deliverymins','deleted',0,'remove:deliverymin',0,46,0,'And','0','Cancelled'),('deliverymins','publish',0,'deliverymins','published',0,'publish:deliverymin',0,47,0,'And','0','Cancelled'),('deliverymins','publish_ordering',0,'deliverymins','published',0,'publishorder:deliverymin',0,48,0,'And','0','Cancelled');
-- END ONLY in _catalog
-- END 23-10-2020 --

-- START 11-11-2020 --
alter table login add puid varchar(36) not null;
update login set puid = uuid();
alter table login add unique key (puid);

-- END 11-11-2020 --

-- START 13-11-2020
ALTER TABLE catalogs
ADD COLUMN catalog_uuid varchar(36) DEFAULT UUID() after name;

ALTER TABLE catalogs
ADD UNIQUE KEY site_id_uuid (site_id,catalog_uuid);

-- Run following after running above on both catalog and prod_catalog DBs
UPDATE dev_prod_catalog.catalogs c1, dev_catalog.catalogs c2
SET c1.catalog_uuid = c2.catalog_uuid
WHERE c1.id = c2.id;

-- END 13-11-2020

-- START 16-11-2020
-- NOTE: run in commons db (dev_commons)

DROP VIEW IF EXISTS dev_commons.content_urls;

CREATE VIEW dev_commons.content_urls AS

select p.site_id, 'page' COLLATE utf8mb4_general_ci as content_type, p.id as content_id, p.name as name, l.langue_id, p.langue_code,
lcase(REPLACE(p.html_file_path,concat(p.site_id,'/',p.langue_code,'/',IF(p.variant='logged','',CONCAT(p.variant,'/'))),'')) AS page_path,
concat(c.val,c2.val,p.html_file_path) as internal_url,
concat(c.val,c2.val,p.html_file_path) as internal_prod_url
from dev_pages.pages p, dev_pages.language l, dev_commons.config c , dev_commons.config c2
where c.code = 'PAGES_APP_URL'
and c2.code = 'PAGES_PUBLISH_FOLDER'
and l.langue_code = p.langue_code
union all
select c.site_id, 'catalog' COLLATE utf8mb4_general_ci as content_type, c.id as content_id, c.name as name, cd.langue_id, l.langue_code,
lcase(concat(cd.page_path,'.html')) as page_path,
concat(cf.val, 'listproducts.jsp?cat=', c.id) as internal_url,
concat(cf2.val, 'listproducts.jsp?cat=', c.id) as internal_prod_url
from dev_catalog.catalogs c, dev_catalog.catalog_descriptions cd, dev_catalog.language l, dev_catalog.config cf, dev_prod_catalog.config cf2
where coalesce(cd.page_path,'') <> ''
and c.id = cd.catalog_id
and cf.code = 'EXTERNAL_CATALOG_LINK'
and cf2.code = 'EXTERNAL_CATALOG_LINK'
and l.langue_id = cd.langue_id
union all
select c.site_id, 'product' COLLATE utf8mb4_general_ci as content_type, p.id as content_id, case when l.langue_id = 1 then p.lang_1_name when l.langue_id = 2 then p.lang_2_name when l.langue_id = 3 then p.lang_3_name when l.langue_id = 4 then p.lang_4_name when l.langue_id = 5 then p.lang_5_name else p.lang_1_name end as name,
pd.langue_id, l.langue_code,
lcase(concat(pd.page_path,'.html')) as page_path,
concat(cf.val, 'product.jsp?id=', p.id) as internal_url,
concat(cf2.val, 'product.jsp?id=', p.id) as internal_prod_url
from dev_catalog.products p, dev_catalog.product_descriptions pd, dev_catalog.catalogs c, dev_catalog.language l, dev_catalog.config cf, dev_prod_catalog.config cf2
where coalesce(pd.page_path,'') <> ''
and p.catalog_id = c.id
and p.id = pd.product_id
and cf.code = 'EXTERNAL_CATALOG_LINK'
and cf2.code = 'EXTERNAL_CATALOG_LINK'
and l.langue_id = pd.langue_id
union all
select f.site_id, 'form' COLLATE utf8mb4_general_ci as content_type, f.form_id as content_id, f.process_name as name, l.langue_id, l.langue_code,
lcase(concat(case when f.variant = 'logged' then concat(f.variant,'/') else '' end, fd.page_path,'.html')) as page_path,
concat(c.val,'forms.jsp?form_id=', f.form_id) as internal_url,
concat(c.val,'forms.jsp?form_id=', f.form_id) as internal_prod_url
from dev_forms.process_forms f, dev_forms.process_form_descriptions fd, dev_forms.language l, dev_commons.config c
where coalesce(fd.page_path,'') <> ''
and c.code = 'EXTERNAL_FORMS_LINK'
and f.form_id = fd.form_id
and l.langue_id = fd.langue_id
union all
SELECT 0 AS site_id, 'file' COLLATE utf8mb4_general_ci AS content_type, f.id AS content_id, f.file_name AS name, 0 AS langue_id, '0' AS langue_code,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video')
;

-- END 16-11-2020

-- START 16-11-2020
ALTER TABLE subsidies ADD COLUMN redirect_url VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE subsidies ADD COLUMN open_as enum('new_tab','new_window','same_window') NOT NULL DEFAULT 'same_window';
-- END 16-11-2020

-- START 02-12-2020 -- 
ALTER TABLE `shop_parameters`
ADD COLUMN `multiple_catalogs_checkout`  tinyint(1) NULL DEFAULT 1 AFTER `lang_5_deliver_outside_dep_error`;
-- END 02-12-2020


-- START 09-12-2020 -- 
insert into dev_commons.config (code, val) values ('AVATAR_WIDTH', 36);
insert into dev_commons.config (code, val) values ('AVATAR_HEIGHT', 36);

-- for orange countries only
delete from page where name = 'Client Profils';
-- END 09-12-2020 -- 

