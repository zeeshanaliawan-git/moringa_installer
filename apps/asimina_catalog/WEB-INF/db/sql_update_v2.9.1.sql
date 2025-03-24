-- START 06-07-2021 --
update dev_commons.config set val = '2.9.1' where code = 'APP_VERSION';
update dev_commons.config set val = '2.9.0.1' where code = 'CSS_JS_VERSION';

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
case when c.html_variant = 'logged' then  lcase(concat(c.html_variant,'/',cd.page_path,'.html')) else lcase(concat(cd.page_path,'.html')) end as page_path,
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
case when p.html_variant = 'logged' then  lcase(concat(p.html_variant,'/',pd.page_path,'.html')) else lcase(concat(pd.page_path,'.html')) end as page_path,
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
SELECT f.site_id, 'file' AS content_type, f.id AS content_id, f.file_name AS name, 0 AS langue_id, '0' AS langue_code,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video');

update page set url ='/dev_menu/pages/cachemanagement.jsp' where name='cache';

-- END 06-07-2021 --

-- START 13-07-2021 ---

insert into dev_commons.config  (code, val) values ("DANDELION_TEST_FORGOT_PASS_URL", "/dev_shop/resetpass.jsp");
insert into dev_commons.config  (code, val) values ("DANDELION_PROD_FORGOT_PASS_URL", "/dev_prod_shop/resetpass.jsp");
insert into dev_commons.config  (code, val) values ("PROD_SHOP_DB", "dev_prod_shop");


insert into config  (code, val) values ("CATALOG_INTERNAL_LINK", "http://127.0.0.1/dev_catalog/");

-- END 13-07-2021 ---
