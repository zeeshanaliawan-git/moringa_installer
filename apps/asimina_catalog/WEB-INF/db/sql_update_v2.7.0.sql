-- START 03-03-2021 --

update dev_commons.config set val = '2.7.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.7.0.0' where code = 'CSS_JS_VERSION';

ALTER TABLE `deliverymins`
ADD COLUMN `minimum_type`  varchar(10) NULL DEFAULT '' AFTER `dep_value`;


-- END 03-03-2021 --

-- START 05-03-2021 --

ALTER TABLE `deliverymins`
ADD COLUMN `criteria_type`  varchar(10) NULL AFTER `dep_value`;

-- END 05-03-2021 --

-- START 18-03-2021 --

ALTER TABLE `deliverymins`
ADD COLUMN `applied_to_type`  varchar(50) NULL DEFAULT '' AFTER `version`,
ADD COLUMN `applied_to_value`  varchar(255) NULL DEFAULT '' AFTER `applied_to_type`;

-- END 18-03-2021 --


-- START 22-03-2021 --
drop table dev_commons.algolia_indexes;
drop table dev_commons.algolia_rules;
drop table dev_commons.algolia_settings;

CREATE TABLE `algolia_indexes` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `index_type` varchar(75) NOT NULL,
  `index_name` varchar(255) NOT NULL,
  `algolia_index` varchar(255) NOT NULL,
  `order_seq` int(10) not null default 0,  
  PRIMARY KEY (`site_id`,`langue_id`,`index_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `algolia_rules` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `rule_type` varchar(75) NOT NULL,
  `rule_criteria` varchar(30) NOT NULL,
  `rule_value` varchar(255) NOT NULL,
  `index_name` varchar(255) NOT NULL,
  `exclude_from_default` tinyint(1) NOT NULL default 0,  
  `order_seq` int(10) not null default 0    
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `algolia_default_index` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `index_name` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `algolia_settings` (
  `site_id` int(11) NOT NULL,
  `activated` tinyint(1) NOT NULL DEFAULT 0,
  `application_id` varchar(255) DEFAULT NULL,
  `search_api_key` varchar(255) DEFAULT NULL,
  `write_api_key` varchar(255) DEFAULT NULL,
  `exclude_noindex` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `version` int(10) not null default 1,
  PRIMARY KEY (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into page (name, url, parent, rang, icon, parent_icon) values ('Module Parameters','/dev_catalog/admin/moduleparameters.jsp','System','608','chevron-right','settings');

INSERT INTO `page` (`name`, `url`, `parent`, `rang`, `icon`, `parent_icon`, `requires_ecommerce`) VALUES ('Quantity Limits', '/dev_catalog/admin/catalogs/commercialoffers/quantitylimits/quantitylimits.jsp', 'Marketing', '410', 'chevron-right', 'shopping-cart', '1');

CREATE TABLE `quantitylimits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `quantity_limit` int(11) NOT NULL DEFAULT 0,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT '',
  `lang_3_description` text DEFAULT '',
  `lang_4_description` text DEFAULT '',
  `lang_5_description` text DEFAULT '',
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `quantitylimits_rules` (
  `quantitylimit_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- END 22-03-2021 --

-- START 24-03-2021 --

ALTER TABLE additionalfee_rules MODIFY element_type_value varchar(100) default null;

drop view dev_commons.content_urls;

CREATE VIEW dev_commons.content_urls AS
select p.site_id, 'page' as content_type, p.id as content_id, p.name as name, l.langue_id, p.langue_code,
lcase(REPLACE(p.html_file_path,concat(p.site_id,'/',p.langue_code,'/',IF(p.variant='logged','',CONCAT(p.variant,'/'))),'')) AS page_path,
concat(c.val,c2.val,p.html_file_path) as internal_url,
concat(c.val,c2.val,p.html_file_path) as internal_prod_url
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
where coalesce(cd.page_path,'') != ''
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
where coalesce(pd.page_path,'') != ''
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
where coalesce(fd.page_path,'') != ''
and c.code = 'EXTERNAL_FORMS_LINK'
and f.form_id = fd.form_id
and l.langue_id = fd.langue_id
union all
SELECT f.site_id, 'file' AS content_type, f.id AS content_id, f.file_name AS name, 0 AS langue_id, '0' AS langue_code,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video');


delete from config where code = 'PAGES_UPLOAD_DIRECTORY';
insert into dev_commons.config (code, val) values ('PAGES_UPLOAD_DIRECTORY','/home/etn/tomcat/webapps/dev_pages/uploads/');

alter table login_tries change ip ip varchar(50) not null;
-- END 24-03-2021 --

