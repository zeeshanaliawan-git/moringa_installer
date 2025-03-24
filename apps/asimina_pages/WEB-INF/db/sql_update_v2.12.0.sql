-- START 18-10-2021 --

UPDATE blocs
SET template_data = REPLACE(template_data,'"p.status','"p2.publish_status')
WHERE  template_data LIKE '%"p.status%';

UPDATE structured_contents_details
SET content_data = REPLACE(content_data, '"p.status', '"p2.publish_status')
WHERE content_data LIKE '%"p.status%';

UPDATE structured_contents_details_published
SET content_data = REPLACE(content_data, '"p.status', '"p2.publish_status')
WHERE content_data LIKE '%"p.status%';

INSERT INTO ignore_xss_fields VALUES ('importAjax.jsp', 'itemsJson');

ALTER TABLE folders
ADD UNIQUE KEY uk_folders (site_id, type, parent_folder_id, name);

ALTER TABLE pages
DROP INDEX uk_pages_path_variant_lang,
ADD UNIQUE INDEX uk_pages_path_variant_lang_folder (site_id, path, variant, langue_code, folder_id);

-- END 18-10-2021 --


-- START 20-10-2021 --

ALTER TABLE bloc_templates
MODIFY COLUMN type enum ( 'block','feed_view','structured_content','structured_page','store','menu' ) NOT NULL DEFAULT 'block';

CREATE VIEW stores_folders AS
SELECT *
FROM folders
WHERE type = 'stores';

UPDATE dev_catalog.page SET rang = rang+1 WHERE parent = 'Content' AND rang >= 303;

INSERT INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce)
VALUES ("Stores", "/dev_pages/admin/stores.jsp", "Content", 303, 0, "chevron-right", "file-text", 0);

ALTER TABLE structured_contents
MODIFY COLUMN catalog_id int(11) unsigned NOT NULL DEFAULT '0';

-- END 20-10-2021 --

-- START 02-11-2021 --

DROP VIEW IF EXISTS pages_folders_lang_path;
CREATE VIEW pages_folders_lang_path AS
SELECT f.site_id, f.id AS folder_id, fd.langue_id,
    CONCAT_WS('/',NULLIF(fd3.path_prefix,''), NULLIF(fd2.path_prefix,''),NULLIF(fd.path_prefix,'')) as concat_path,
    f.folder_level, fd.path_prefix path1, fd2.path_prefix path2, fd3.path_prefix path3
FROM folders f
JOIN folders_details fd ON fd.folder_id = f.id
LEFT JOIN folders f2 ON f.parent_folder_id = f2.id
LEFT JOIN folders_details fd2 ON fd2.folder_id = f2.id AND fd.langue_id = fd2.langue_id
LEFT JOIN folders f3 ON f2.parent_folder_id = f3.id
LEFT JOIN folders_details fd3 ON fd3.folder_id = f3.id AND fd.langue_id = fd3.langue_id;
-- END 02-11-2021 --
