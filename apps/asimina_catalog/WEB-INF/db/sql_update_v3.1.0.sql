update dev_commons.config set val = '3.1.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.1.0.1' where code = 'CSS_JS_VERSION';

--Start 1-27-2022 Usman --

ALTER TABLE shop_parameters
ADD COLUMN lang_1_currency_position  enum('after','before') NOT NULL DEFAULT 'after';

ALTER TABLE shop_parameters
ADD COLUMN lang_2_currency_position  enum('after','before') NOT NULL DEFAULT 'after';

ALTER TABLE shop_parameters
ADD COLUMN lang_3_currency_position  enum('after','before') NOT NULL DEFAULT 'after';

ALTER TABLE shop_parameters
ADD COLUMN lang_4_currency_position  enum('after','before') NOT NULL DEFAULT 'after';

ALTER TABLE shop_parameters
ADD COLUMN lang_5_currency_position  enum('after','before') NOT NULL DEFAULT 'after';

--End 1-27-2022 Usman --


--Start 2-14-2022 Ahsan--

INSERT INTO dev_commons.config (code,val,comments) VALUES ("client_image_max_size", "2000000", "This size is in bytes");
INSERT INTO dev_commons.config (code,val,comments) VALUES ("client_image_quality", "0.7","");

--End 2-14-2022 Ahsan--

alter table shop_parameters add column lang_1_continue_shop_url varchar(255);
alter table shop_parameters add column lang_2_continue_shop_url varchar(255);
alter table shop_parameters add column lang_3_continue_shop_url varchar(255);
alter table shop_parameters add column lang_4_continue_shop_url varchar(255);
alter table shop_parameters add column lang_5_continue_shop_url varchar(255);


-- updated for adding catalog prefix path(folder_name) and folder prefix path to the product page_path
DROP VIEW IF EXISTS dev_commons.content_urls;
CREATE VIEW dev_commons.content_urls AS
SELECT p.site_id, 'page' as content_type, p.id as content_id, p.name as name, l.langue_id, p.langue_code,
	lcase(REPLACE(p.html_file_path,CONCAT(p.site_id,'/',p.langue_code,'/',IF(p.variant='logged','',CONCAT(p.variant,'/'))),'')) AS page_path,
	CONCAT(c.val,c2.val,p.html_file_path) as internal_url,
	CONCAT(c.val,c2.val,p.html_file_path) as internal_prod_url
FROM dev_pages.pages p, dev_pages.language l, dev_commons.config c , dev_commons.config c2
WHERE c.code = 'PAGES_APP_URL'
AND c2.code = 'PAGES_PUBLISH_FOLDER'
AND l.langue_code = p.langue_code
UNION ALL
SELECT c.site_id, 'catalog' as content_type, c.id as content_id, c.name as name, cd.langue_id, l.langue_code,
	case when c.html_variant = 'logged' then  lcase(CONCAT(c.html_variant,'/',cd.page_path,'.html')) else lcase(CONCAT(cd.page_path,'.html')) end as page_path,
	CONCAT(cf.val, 'listproducts.jsp?cat=', c.id) as internal_url,
	CONCAT(cf2.val, 'listproducts.jsp?cat=', c.id) as internal_prod_url
FROM dev_catalog.catalogs c, dev_catalog.catalog_descriptions cd, dev_catalog.language l, dev_catalog.config cf, dev_prod_catalog.config cf2
WHERE coalesce(cd.page_path,'') != ''
AND c.id = cd.catalog_id
AND cf.code = 'EXTERNAL_CATALOG_LINK'
AND cf2.code = 'EXTERNAL_CATALOG_LINK'
AND l.langue_id = cd.langue_id
UNION ALL
SELECT c.site_id, 'product' as content_type, p.id as content_id,
	case when l.langue_id = 1 then p.lang_1_name when l.langue_id = 2 then p.lang_2_name when l.langue_id = 3 then p.lang_3_name when l.langue_id = 4 then p.lang_4_name when l.langue_id = 5 then p.lang_5_name else p.lang_1_name end as name,
    pd.langue_id, l.langue_code,
	lcase(CONCAT(
        CONCAT_WS('/',
            IF(p.html_variant='logged',p.html_variant,NULL),
            IF(TRIM(IFNULL(cd.folder_name,''))!='',cd.folder_name,NULL),
            IF(TRIM(IFNULL(f.concat_path,''))!='',f.concat_path,NULL),
            pd.page_path)
	,'.html' ))  as page_path ,
	CONCAT(cf.val, 'product.jsp?id=', p.id) as internal_url,
	CONCAT(cf2.val, 'product.jsp?id=', p.id) as internal_prod_url
FROM dev_catalog.products p
JOIN dev_catalog.product_descriptions pd ON  p.id = pd.product_id
JOIN dev_catalog.catalogs c ON c.id = p.catalog_id
JOIN dev_catalog.language l ON l.langue_id = pd.langue_id
JOIN dev_catalog.config cf
JOIN dev_prod_catalog.config cf2
LEFT JOIN dev_catalog.catalog_descriptions cd ON  cd.catalog_id = c.id AND cd.langue_id = l.langue_id
LEFT JOIN dev_catalog.products_folders_lang_path f ON f.folder_id = p.folder_id AND f.langue_id = l.langue_id
WHERE coalesce(pd.page_path,'') != ''
and cf.code = 'EXTERNAL_CATALOG_LINK'
and cf2.code = 'EXTERNAL_CATALOG_LINK'
UNION ALL
SELECT f.site_id, 'file' AS content_type, f.id AS content_id, f.file_name AS name, 0 AS langue_id, '0' AS langue_code,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS page_path,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_url,
    CONCAT(c.val, c2.val, f.site_id, '/', f.type,'/', f.file_name) AS internal_prod_url
FROM dev_pages.files f
JOIN dev_pages.config c ON c.code = 'EXTERNAL_LINK'
JOIN dev_pages.config c2 ON c2.code = 'UPLOADS_FOLDER'
WHERE f.type IN ('other','video');
