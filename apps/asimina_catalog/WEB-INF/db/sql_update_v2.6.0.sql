-- START 11-12-2020 --
update dev_commons.config set val = '2.6.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.6.0.0' where code = 'CSS_JS_VERSION';
-- END 11-12-2020 --

-- START 25-01-2021 --
update dev_commons.config set val = '2.6.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.6.0.0' where code = 'CSS_JS_VERSION';
-- END 25-01-2021 --

-- START 29-01-2021 --

CREATE TABLE `stickers` (
  `site_id` int(11) NOT NULL,
  `sname` varchar(50) NOT NULL DEFAULT '',
  `display_name_1` varchar(50) DEFAULT '',
  `display_name_2` varchar(50) DEFAULT '',
  `display_name_3` varchar(50) DEFAULT '',
  `display_name_4` varchar(50) DEFAULT '',
  `display_name_5` varchar(50) DEFAULT '',
  `color` varchar(10) DEFAULT '',
	`priority` int(10),
  PRIMARY KEY (`sname`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DELETE FROM dev_commons.constants WHERE `group` = "product_stickers";

-- END 29-01-2021 --

-- START 03-02-2021 --
-- view updated : site_id added to file type

DROP VIEW IF EXISTS dev_commons.content_urls;

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
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video');

-- END 03-02-2021 --


