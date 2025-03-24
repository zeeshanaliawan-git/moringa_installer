-- START 04-05-2021 --
update dev_commons.config set val = '2.9.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.9.0.0' where code = 'CSS_JS_VERSION';
-- END 04-05-2021 --

-- START 02-06-2021 --

insert into dev_commons.config  (code, val) values ("ADMIN_FORGOT_PASS_URL", "/dev_catalog/resetpass.jsp");
ALTER TABLE person
ADD COLUMN forgot_password  tinyint(1) NOT NULL DEFAULT 0 AFTER home_page,
ADD COLUMN forgot_pass_token  varchar(36) DEFAULT NULL AFTER forgot_password,
ADD COLUMN forgot_pass_token_expiry  datetime DEFAULT NULL AFTER forgot_pass_token;

alter table person add forgot_password_referrer varchar(255);

ALTER TABLE shop_parameters
ADD COLUMN show_product_detail_delivery_fee  tinyint(1) NULL DEFAULT 1 AFTER multiple_catalogs_checkout;

-- START 02-06-2021 --

-- START 04-06-2021 --

ALTER TABLE products
ADD COLUMN html_variant  enum('all','anonymous','logged') NOT NULL DEFAULT 'all';
ALTER TABLE catalogs
ADD COLUMN html_variant  enum('all','anonymous','logged') NOT NULL DEFAULT 'all';


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

-- END 04-06-2021 --

-- START 03-06-2021

ALTER TABLE product_variant_details
ADD COLUMN action_button_desktop_url_opentype varchar(30) DEFAULT "same_window" AFTER action_button_desktop_url,
ADD COLUMN action_button_mobile_url_opentype varchar(30) DEFAULT "same_window"  AFTER action_button_mobile_url;

ALTER TABLE catalog_descriptions
ADD COLUMN top_banner_path_opentype varchar(30) DEFAULT "same_window",
ADD COLUMN bottom_banner_path_opentype varchar(30) DEFAULT "same_window";

-- END 03-06-2021

-- START 17-06-2021
ALTER TABLE catalog_descriptions
ADD COLUMN page_template_id int(11) unsigned NOT NULL default '0';

UPDATE catalog_descriptions cd
JOIN catalogs c ON c.id = cd.catalog_id
SET cd.page_template_id = (
    SELECT id
    FROM dev_pages.page_templates pt
    WHERE pt.is_system = '1'
    AND pt.site_id = c.site_id );

ALTER TABLE product_descriptions
ADD COLUMN page_template_id int(11) unsigned NOT NULL default '0';

alter table comewiths add frequency varchar(10) DEFAULT NULL;
-- END 17-06-2021

