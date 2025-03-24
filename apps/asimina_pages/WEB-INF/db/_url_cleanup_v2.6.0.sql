use dev_pages;

-- make backups of affected tables

CREATE TABLE IF NOT EXISTS bloc_templates_bk_before2_6
SELECT * FROM bloc_templates;

CREATE TABLE IF NOT EXISTS blocs_bk_before2_6
SELECT * FROM blocs;

CREATE TABLE IF NOT EXISTS structured_contents_details_bk_before2_6
SELECT * FROM structured_contents_details;

CREATE TABLE IF NOT EXISTS structured_contents_details_published_bk_before2_6
SELECT * FROM structured_contents_details_published;

-- bloc_templates img type replacement
UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages/uploads/img/',CONCAT('dev_pages/uploads/',site_id,'/img/'))
WHERE template_code LIKE '%dev_pages/uploads/img/%';

UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages//uploads/img/',CONCAT('dev_pages//uploads/',site_id,'/img/'))
WHERE template_code LIKE '%dev_pages//uploads/img/%';

-- bloc_templates other type replacement
UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages/uploads/other/',CONCAT('dev_pages/uploads/',site_id,'/other/'))
WHERE template_code LIKE '%dev_pages/uploads/other/%';

UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages//uploads/other/',CONCAT('dev_pages//uploads/',site_id,'/other/'))
WHERE template_code LIKE '%dev_pages//uploads/other/%';

-- bloc_templates video type replacement
UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages/uploads/video/',CONCAT('dev_pages/uploads/',site_id,'/video/'))
WHERE template_code LIKE '%dev_pages/uploads/video/%';

UPDATE bloc_templates
SET template_code = REPLACE(template_code,'dev_pages//uploads/video/',CONCAT('dev_pages//uploads/',site_id,'/video/'))
WHERE template_code LIKE '%dev_pages//uploads/video/%';


-- blocs img type replacement
UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages/uploads/img/',CONCAT('dev_pages/uploads/',site_id,'/img/'))
WHERE template_data LIKE '%dev_pages/uploads/img/%';


UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages//uploads/img/',CONCAT('dev_pages//uploads/',site_id,'/img/'))
WHERE template_data LIKE '%dev_pages//uploads/img/%';

-- blocs other type replacement
UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages/uploads/other/',CONCAT('dev_pages/uploads/',site_id,'/other/'))
WHERE template_data LIKE '%dev_pages/uploads/other/%';


UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages//uploads/other/',CONCAT('dev_pages//uploads/',site_id,'/other/'))
WHERE template_data LIKE '%dev_pages//uploads/other/%';


-- blocs video type replacement
UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages/uploads/video/',CONCAT('dev_pages/uploads/',site_id,'/video/'))
WHERE template_data LIKE '%dev_pages/uploads/video/%';


UPDATE blocs
SET template_data = REPLACE(template_data,'dev_pages//uploads/video/',CONCAT('dev_pages//uploads/',site_id,'/video/'))
WHERE template_data LIKE '%dev_pages//uploads/video/%';

-- structured img type replacement
UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/img/',CONCAT('dev_pages//uploads/',c.site_id,'/img/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/img/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/img/',CONCAT('dev_pages//uploads/',c.site_id,'/img/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/img/%';


UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/img/',CONCAT('dev_pages/uploads/',c.site_id,'/img/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/img/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/img/',CONCAT('dev_pages/uploads/',c.site_id,'/img/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/img/%';

-- structured other type replacement
UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/other/',CONCAT('dev_pages//uploads/',c.site_id,'/other/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/other/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/other/',CONCAT('dev_pages//uploads/',c.site_id,'/other/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/other/%';


UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/other/',CONCAT('dev_pages/uploads/',c.site_id,'/other/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/other/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/other/',CONCAT('dev_pages/uploads/',c.site_id,'/other/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/other/%';


-- structured video type replacement
UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/video/',CONCAT('dev_pages//uploads/',c.site_id,'/video/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/video/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages//uploads/video/',CONCAT('dev_pages//uploads/',c.site_id,'/video/'))
WHERE scd.content_data LIKE '%dev_pages//uploads/video/%';


UPDATE structured_contents_details scd
JOIN structured_contents sc ON sc.id = scd.content_id
JOIN structured_catalogs c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/video/',CONCAT('dev_pages/uploads/',c.site_id,'/video/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/video/%';

UPDATE structured_contents_details_published scd
JOIN structured_contents_published sc ON sc.id = scd.content_id
JOIN structured_catalogs_published c ON c.id = sc.catalog_id
SET scd.content_data = REPLACE(scd.content_data,'dev_pages/uploads/video/',CONCAT('dev_pages/uploads/',c.site_id,'/video/'))
WHERE scd.content_data LIKE '%dev_pages/uploads/video/%';

-- regenerate pages , and re published already published pages
UPDATE pages
SET to_generate = '1'
WHERE type IN ('freemarker', 'structured');

UPDATE pages
SET to_publish = '1', to_publish_ts = NOW()
WHERE type IN ('freemarker', 'structured')
AND publish_status != 'unpublished';
