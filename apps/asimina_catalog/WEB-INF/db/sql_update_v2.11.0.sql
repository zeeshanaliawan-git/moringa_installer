-- START 31-08-2021 --
update dev_commons.config set val = '2.11.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.11.0.1' where code = 'CSS_JS_VERSION';
-- START 31-08-2021 --

-- START 13-09-2021 --

ALTER TABLE shop_parameters
    ADD save_cart_email_id_test  int(11) NOT NULL DEFAULT 0,
    ADD save_cart_email_id_prod int(11) NOT NULL DEFAULT 0;

-- END 13-09-2021 --

-- START 16-09-2021 --

CREATE TABLE products_folders (
    id               int(11) unsigned NOT NULL AUTO_INCREMENT,
    uuid             varchar(36) NOT NULL DEFAULT uuid(),
    name             varchar(300) NOT NULL,
    site_id          int(10) unsigned NOT NULL DEFAULT 0,
    catalog_id       int(11) unsigned NOT NULL DEFAULT '0',
    parent_folder_id int(11) unsigned NOT NULL DEFAULT '0',
    folder_level     enum ('2','3') NOT NULL DEFAULT '2' COMMENT 'level=1 is catalog',
    version          int(10) NOT NULL DEFAULT 1,
    created_on       datetime NOT NULL DEFAULT current_timestamp(),
    updated_on       datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    created_by       int(11) NOT NULL,
    updated_by       int(11) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

CREATE TABLE products_folders_details (
    folder_id   int(11) unsigned NOT NULL,
    langue_id   int(1) unsigned NOT NULL,
    path_prefix varchar(100) NOT NULL DEFAULT '',
    PRIMARY KEY (folder_id, langue_id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

ALTER TABLE products
    ADD COLUMN folder_id int(11) unsigned NOT NULL DEFAULT '0' AFTER catalog_id;

-- END 16-09-2021 --

-- START 30-09-2021 --
-- Rearranging 'Content' menu according to new V3 specs
-- 'Catalog' menu removed , all its entries moved to 'Content' menu in specified order

UPDATE dev_catalog.page p
SET p.parent_icon = 'file-text'
WHERE parent = 'Content';

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Pages', '/dev_pages/admin/pages.jsp', 'Content', 301, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Products', '/dev_catalog/admin/catalogs/catalogs.jsp', 'Content', 302, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Forms', '/dev_forms/admin/process.jsp', 'Content', 303, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Structured data', '/dev_pages/admin/structuredContents.jsp', 'Content', 304, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('RSS', '/dev_pages/admin/rssFeeds.jsp', 'Content', 305, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Media', '/dev_pages/admin/mediaLibrary.jsp', 'Content', 306, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Blocks', '/dev_pages/admin/blocs.jsp', 'Content', 307, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Tags', '/dev_catalog/admin/catalogs/tags.jsp', 'Content', 308, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Menus (new)', '/dev_pages/admin/menus.jsp', 'Content', 309, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Knowledge', '', 'Content', 315, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Products relationship', '/dev_catalog/admin/catalogs/productrelation.jsp', 'Content', 316, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Translations', '/dev_catalog/admin/libmsgs.jsp', 'Content', 317, 0, 'chevron-right', 'file-text', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Ckeditor', '/dev_ckeditor/pages/htmlPageMain.jsp', 'Content', 399, 0, 'chevron-right', 'file-text', 0);

-- move Data import export to top of 'Tools' menu
UPDATE dev_catalog.page p
SET p.rang = (p.rang + 2)
WHERE parent = 'Tools';


REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Data import', '/dev_pages/admin/import.jsp', 'Tools', 700, 0, 'chevron-right', 'grid', 0);

REPLACE INTO `page` (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ('Data export', '/dev_pages/admin/export.jsp', 'Tools', 701, 0, 'chevron-right', 'grid', 0);

--  remove obsolete structured catalog screens
DELETE FROM page
WHERE TRIM(url) = '/dev_pages/admin/structuredCatalogs.jsp';

DELETE FROM page
WHERE TRIM(url) = '/dev_pages/admin/structuredPageCatalogs.jsp';

DROP VIEW IF EXISTS products_folders_lang_path;
CREATE VIEW products_folders_lang_path AS
SELECT f.site_id, f.id AS folder_id, fd.langue_id,
       CONCAT_WS('/', NULLIF(fd2.path_prefix, ''), NULLIF(fd.path_prefix, '')) as concat_path,
       f.folder_level, fd.path_prefix path1, fd2.path_prefix path2
FROM products_folders f
JOIN products_folders_details fd ON fd.folder_id = f.id
LEFT JOIN products_folders f2 ON f.parent_folder_id = f2.id
LEFT JOIN products_folders_details fd2 ON fd2.folder_id = f2.id AND fd.langue_id = fd2.langue_id;

-- END 30-09-2021 --

-- START 06-10-2021 --

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
	CONCAT(
        CONCAT_WS('/',
            IF(p.html_variant='logged',p.html_variant,NULL),
            IF(TRIM(IFNULL(cd.folder_name,''))!='',cd.folder_name,NULL),
            IF(TRIM(IFNULL(f.concat_path,''))!='',f.concat_path,NULL),
            pd.page_path)
	,'.html' )  as page_path ,
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

-- to safely remove the catalog prefix path from page path of product in existing datas
UPDATE products p
join product_descriptions pd ON pd.product_id = p.id
join `language` l on l.langue_id = pd.langue_id
join catalogs c on c.id = p.catalog_id
LEFT JOIN catalog_descriptions cd on cd.catalog_id = c.id AND cd.langue_id = l.langue_id
SET pd.page_path = REGEXP_REPLACE(pd.page_path, CONCAT('^',cd.folder_name,'/'),'')
WHERE cd.folder_name IS NOT NULL
AND pd.page_path LIKE CONCAT(TRIM(cd.folder_name),'/%');


update dev_commons.config set val = '10' where code = 'SESSION_TIMEOUT_MINS';

-- END 06-10-2021 --

-- START 11-10-2021 --
CREATE TABLE products_meta_tags (
    id  int(11) UNSIGNED NULL AUTO_INCREMENT ,
    product_id  int(11) NOT NULL ,
    langue_id  int(11) NOT NULL ,
    meta_name  varchar(100) NOT NULL DEFAULT '',
    content  varchar(250) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;
-- END 11-10-2021 --

