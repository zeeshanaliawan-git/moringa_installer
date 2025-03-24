-- start 11/08/2020 --

CREATE TABLE IF NOT EXISTS `comewiths_rules` (
  `comewith_id` int(11) NOT NULL,
  `associated_to_type` varchar(50) DEFAULT NULL,
  `associated_to_value` varchar(255) DEFAULT NULL,
	UNIQUE (`comewith_id`, `associated_to_type`, `associated_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO comewiths_rules(comewith_id, associated_to_type, associated_to_value) SELECT id, associated_to_type, associated_to_value FROM comewiths;

ALTER TABLE comewiths
DROP COLUMN associated_to_type,
DROP COLUMN associated_to_value;

-- end 11/08/2020 --


-- START 31-08-2020 --
alter table product_images change image_file_name image_file_name varchar(255) not null;
alter table product_images change image_label image_label varchar(255) not null;
-- END 31-08-2020 --

-- START 14-09-2020 --
alter table page_sub_urls add unique key (url,sub_url);

insert into page_sub_urls (url,sub_url) values  ('/dev_menu/pages/site.jsp','/dev_menu/pages/menudesigner.jsp');

insert into page_sub_urls (url,sub_url) values  ('/dev_menu/pages/site.jsp','/dev_menu/pages/previewmenu.jsp');

insert into page_sub_urls (url,sub_url) values  ('/dev_menu/pages/site.jsp','/dev_menu/pages/portal.jsp');

-- END 14-09-2020 --

-- START 15-09-2020 --
DROP VIEW IF EXISTS dev_commons.content_urls;

CREATE VIEW dev_commons.content_urls AS

select p.site_id, 'page' as content_type, p.id as content_id, p.name as name, l.langue_id, p.langue_code,
lcase(replace(p.html_file_path,concat(p.site_id,'/',p.langue_code,'/',p.variant,'/'),'')) as page_path,
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
and l.langue_id = fd.langue_id
union all
SELECT 0 AS site_id, 'file' AS content_type, f.id AS content_id, f.file_name AS name, 0 AS langue_id, '0' AS langue_code,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video')
;
-- END 15-09-2020 --


-- START 5-10-2020 --
ALTER TABLE products ADD COLUMN sort_variant char(5) NOT NULL DEFAULT 'cu';
ALTER TABLE catalog_essential_blocks ADD COLUMN order_seq int(10) NOT NULL DEFAULT 1;
ALTER TABLE product_variants ADD COLUMN order_seq int(10) NOT NULL DEFAULT 1;
ALTER TABLE product_essential_blocks ADD COLUMN order_seq int(10) NOT NULL DEFAULT 1;
ALTER TABLE catalogs ADD COLUMN default_sort VARCHAR(15) DEFAULT 'promotion';
-- END 5-10-2020 --

-- START 6-10-2020 --
INSERT INTO dev_commons.config(code,val,comments)
VALUES ('MEDIA_LIBRARY_UPLOADS_URL', '/dev_pages/uploads/','');

UPDATE page SET url = '/dev_pages/admin/mediaLibrary.jsp'
WHERE name = 'Media library';

-- END 6-10-2020 --

-- START 09-10-2020 --

ALTER TABLE `catalogs`
MODIFY COLUMN `lang_1_description`  text NULL DEFAULT '' AFTER `version`,
MODIFY COLUMN `lang_2_description`  text NULL DEFAULT '' AFTER `lang_1_description`,
MODIFY COLUMN `lang_3_description`  text NULL DEFAULT '' AFTER `lang_2_description`,
MODIFY COLUMN `lang_4_description`  text NULL DEFAULT '' AFTER `lang_3_description`,
MODIFY COLUMN `lang_5_description`  text NULL DEFAULT '' AFTER `lang_4_description`;

update dev_commons.config set val = '2.4.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.4.0.0' where code = 'CSS_JS_VERSION';

-- END 09-10-2020 --

-- START 19-10-2020 --
update catalog_attributes set visible_to = 'all' where coalesce(visible_to,'') = '';

alter table catalog_attributes change visible_to visible_to enum('all','logged_customer','backoffice') not null default 'all';

ALTER TABLE product_images
MODIFY COLUMN image_file_name varchar(500) NOT NULL,
MODIFY COLUMN image_label varchar(500) NOT NULL;

-- END 19-10-2020 --

-- START 03-11-2020 --

ALTER TABLE products ADD COLUMN first_publish_on DATETIME DEFAULT NULL;

-- END 03-11-2020 --
