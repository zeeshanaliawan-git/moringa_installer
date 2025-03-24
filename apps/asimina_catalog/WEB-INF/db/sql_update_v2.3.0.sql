

-- Added 07-08-2020 by Ali Adnan
INSERT INTO dev_commons.config(code,val,comments)
VALUES ('FORM_HTML_API_URL', 'http://127.0.0.1/dev_forms/api/forms.jsp','');

-- START 09-07-2020 --
create view dev_commons.content_urls as
select p.site_id, 'page' as content_type, p.id as content_id, p.name as name, l.langue_id, p.langue_code,
lcase(concat(case when p.variant = 'logged' then concat(p.variant,'/') else '' end,p.path,'.html')) as page_path,
concat(c.val,c2.val,p.site_id,'/',p.langue_code,'/',p.variant,'/',p.path, '.html') as internal_url,
concat(c.val,c2.val,p.site_id,'/',p.langue_code,'/',p.variant,'/',p.path, '.html') as internal_prod_url
from dev_pages.pages p, dev_pages.language l, dev_commons.config c , dev_commons.config c2
where c.code = 'PAGES_APP_URL'
and c2.code = 'PAGES_PUBLISH_FOLDER'
and l.langue_code = p.langue_code
union all
select c.site_id, 'catalog' as content_type, c.id as content_id, c.name as name, cd.langue_id, l.langue_code,
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
select c.site_id, 'product' as content_type, p.id as content_id, case when l.langue_id = 1 then p.lang_1_name when l.langue_id = 2 then p.lang_2_name when l.langue_id = 3 then p.lang_3_name when l.langue_id = 4 then p.lang_4_name when l.langue_id = 5 then p.lang_5_name else p.lang_1_name end as name,
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
select f.site_id, 'form' as content_type, f.form_id as content_id, f.process_name as name, l.langue_id, l.langue_code,
lcase(concat(case when f.variant = 'logged' then concat(f.variant,'/') else '' end, fd.page_path,'.html')) as page_path,
concat(c.val,'forms.jsp?form_id=', f.form_id) as internal_url,
concat(c.val,'forms.jsp?form_id=', f.form_id) as internal_prod_url
from dev_forms.process_forms f, dev_forms.process_form_descriptions fd, dev_forms.language l, dev_commons.config c
where coalesce(fd.page_path,'') <> ''
and c.code = 'EXTERNAL_FORMS_LINK'
and f.form_id = fd.form_id
and l.langue_id = fd.langue_id;

update dev_commons.config set val = '2.3.0' where code = 'APP_VERSION';

update dev_commons.config set val = '0' where code = 'POST_WORK_SPLIT_ITEMS';

update dev_commons.config set val = '2.3.0' where code = 'CSS_JS_VERSION';

-- END 09-07-2020 --

-- START 13-07-2020
INSERT INTO dev_commons.config(code,val,comments)
VALUES ('URL_GEN_JS_URL', '/dev_catalog/js/urlgen/etn.urlgenerator.js','');
INSERT INTO dev_commons.config(code,val,comments)
VALUES ('URL_GEN_AJAX_URL', '/dev_catalog/js/urlgen/urlgeneratorAjax.jsp','');
-- END 13-07-2020

-- START 15-07-2020 --
update dev_commons.config set code = 'mail.smtp.host' where code = 'MAIL.SMTP.HOST';
update dev_commons.config set code = 'mail.smtp.port' where code = 'MAIL.SMTP.PORT';
update dev_commons.config set code = 'mail.smtp.auth' where code = 'MAIL.SMTP.AUTH';
update dev_commons.config set code = 'mail.smtp.auth.user' where code = 'MAIL.SMTP.AUTH.USER';
update dev_commons.config set code = 'mail.smtp.auth.pwd' where code = 'MAIL.SMTP.AUTH.PWD';
-- END 15-07-2020 --

-- START 17-07-2020 --
delete from page where name = 'Checkout parameters';
-- by default auto_verify_user is 0
update dev_commons.config set val = '0' where code = 'AUTO_VERIFY_CLIENT';

-- Ali Adnan
INSERT INTO dev_commons.config(code,val,comments)
VALUES ('PAGES_FORM_UPDATE_API_URL', 'http://127.0.0.1/dev_pages/api/formUpdate.jsp','');

-- END 17-07-2020 --

-- START 21-07-2020 --

INSERT INTO dev_commons.`config` (`code`, `val`, `comments`) VALUES ('HTML_TO_PDF_CMD', '/home/etn/pjt/dev_engines/shop/wkhtmltopdf', NULL);

-- END 21-07-2020 --

-- START 22-02-2020 --
alter table products add device_type varchar(50);

insert into dev_commons.config(code, val) values ("products_lg_cols", "col-lg-4");
-- START 22-02-2020 --

-- START 07-28-2020 --

DROP TABLE IF EXISTS `subsidies`;
DROP TABLE IF EXISTS `subsidies_rules`;
DROP TABLE IF EXISTS `subsidies_rules_details`;

CREATE TABLE `subsidies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lang_1_description` text,
  `lang_2_description` text,
  `lang_3_description` text,
  `lang_4_description` text,
  `lang_5_description` text,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `discount_type` varchar(10) NOT NULL,
  `discount_value` varchar(10) NOT NULL,
  `applied_to_type` varchar(50) DEFAULT NULL,
  `applied_to_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `subsidies_rules` (
  `subsidy_id` int(11) NOT NULL,
  `associated_to_type` varchar(50) DEFAULT NULL,
  `associated_to_value` varchar(255) DEFAULT NULL,
	UNIQUE (`subsidy_id`, `associated_to_type`, `associated_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page(name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce) VALUES
("Subsidies", "/dev_catalog/admin/catalogs/commercialoffers/subsidies/subsidies.jsp", "Marketing", "407", "0", "chevron-right", "shopping-cart", "0");

INSERT INTO `coordinates` VALUES 
(10,10,584,500,'subsidies','ADMIN',NULL),
(48,195,120,80,'subsidies','ADMIN','publish'),
(343,114,120,80,'subsidies','ADMIN','published'),
(43,284,120,80,'subsidies','ADMIN','delete'),
(347,283,120,80,'subsidies','ADMIN','deleted'),
(180,407,120,80,'subsidies','ADMIN','cancel'),
(620,10,300,500,'subsidies','PROD_SITE_ACCESS',NULL),
(924,18,300,500,'subsidies','PROD_CACHE_MGMT',NULL),
(50,62,120,80,'subsidies','ADMIN','publish_ordering');

INSERT INTO `has_action` VALUES 
('subsidies','delete',40,'remove:subsidy'),
('subsidies','publish',41,'publish:subsidy'),
('subsidies','publish_ordering',42,'publishorder:subsidy');

INSERT INTO `phases` VALUES ('subsidies','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('subsidies','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('subsidies','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('subsidies','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('subsidies','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('subsidies','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O');
INSERT INTO `rules` VALUES ('subsidies','delete',0,'subsidies','deleted',0,'remove:subsidy',0,40,0,'And','0','Cancelled'),('subsidies','publish',0,'subsidies','published',0,'publish:subsidy',0,41,0,'And','0','Cancelled'),('subsidies','publish_ordering',0,'subsidies','published',0,'publishorder:subsidy',0,42,0,'And','0','Cancelled');

-- END 07-28-2020 --

-- START 29-07-2020 --
delete from dev_commons.config where code = "products_lg_cols";

-- END 29-07-2020 --

-- START 09-08-2020 --
alter table catalog_attributes change visible_to visible_to enum('all','logged_customer','backoffice');
-- END 09-08-2020 --


-- START 10-08-2020 --
INSERT INTO dev_commons.config (`code`, `val`) VALUES ('SELECT_DEFAULT_VARIANT', '1');

-- not required for shop where services are not used
delete from page where name = 'Calendar prod';
delete from page where name = 'Calendar test';

-- END 10-08-2020 --

-- START 09-10-2020 --

ALTER TABLE `catalogs`
MODIFY COLUMN `lang_1_description`  text NULL DEFAULT '' AFTER `version`,
MODIFY COLUMN `lang_2_description`  text NULL DEFAULT '' AFTER `lang_1_description`,
MODIFY COLUMN `lang_3_description`  text NULL DEFAULT '' AFTER `lang_2_description`,
MODIFY COLUMN `lang_4_description`  text NULL DEFAULT '' AFTER `lang_3_description`,
MODIFY COLUMN `lang_5_description`  text NULL DEFAULT '' AFTER `lang_4_description`;

-- END 09-10-2020 --
