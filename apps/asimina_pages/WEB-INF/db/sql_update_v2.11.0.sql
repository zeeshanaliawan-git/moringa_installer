-- START 14-09-2021 --
CREATE TABLE folders (
    id               int(11) unsigned NOT NULL AUTO_INCREMENT,
    uuid             varchar(36) NOT NULL DEFAULT uuid(),
    name             varchar(300) NOT NULL,
    site_id          int(10) unsigned NOT NULL DEFAULT 0,
    parent_folder_id int(11) unsigned NOT NULL DEFAULT '0',
    folder_level     enum ('1','2','3') NOT NULL DEFAULT '1',
    type             enum('pages','contents','stores')  NOT NULL DEFAULT 'pages',
    created_ts       datetime NOT NULL DEFAULT current_timestamp(),
    updated_ts       datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    created_by       int(11) NOT NULL,
    updated_by       int(11) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

CREATE TABLE folders_details (
    folder_id   int(11) unsigned NOT NULL,
    langue_id   int(1) unsigned NOT NULL,
    path_prefix varchar(100) NOT NULL DEFAULT '',
    PRIMARY KEY (folder_id, langue_id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

CREATE VIEW pages_folders AS
    SELECT * FROM folders WHERE type = 'pages';

CREATE VIEW structured_contents_folders AS
    SELECT * FROM folders WHERE type = 'contents';

ALTER TABLE pages
    ADD COLUMN folder_id int(11) unsigned NOT NULL DEFAULT '0' AFTER variant;

ALTER TABLE structured_contents
    ADD COLUMN uuid        varchar(36) NOT NULL DEFAULT uuid() AFTER id,
    ADD COLUMN site_id     int(10) unsigned NOT NULL DEFAULT 0 AFTER name,
    ADD COLUMN type        enum ('content','page') NOT NULL DEFAULT 'content' AFTER site_id,
    ADD COLUMN template_id int(11) unsigned NOT NULL DEFAULT 0 AFTER type,
    ADD COLUMN folder_id   int(11) unsigned NOT NULL DEFAULT '0' AFTER template_id;

ALTER TABLE structured_contents_published
    ADD COLUMN uuid        varchar(36) NOT NULL DEFAULT '' AFTER id,
    ADD COLUMN site_id     int(10) unsigned NOT NULL DEFAULT 0 AFTER name,
    ADD COLUMN type        enum ('content','page') NOT NULL DEFAULT 'content' AFTER site_id,
    ADD COLUMN template_id int(11) unsigned NOT NULL DEFAULT 0 AFTER type,
    ADD COLUMN folder_id   int(11) unsigned NOT NULL DEFAULT '0' AFTER template_id;


-- replace structured catalogs with folders
REPLACE INTO folders (id, uuid, name, site_id, created_ts, updated_ts, created_by, updated_by, type)
SELECT id, uuid, name, site_id, created_ts, updated_ts, created_by, updated_by,
       IF(sc.type = 'page','pages','contents') AS type
FROM structured_catalogs sc;

REPLACE INTO folders_details(folder_id, langue_id, path_prefix)
SELECT scd.catalog_id, langue_id, path_prefix
FROM structured_catalogs_details scd
JOIN structured_catalogs sc ON sc.id = scd.catalog_id;

-- set new column values of existing data
UPDATE structured_contents sc
    JOIN structured_catalogs c ON c.id = sc.catalog_id
SET sc.site_id     = c.site_id,
    sc.type        = c.type,
    sc.template_id = c.template_id;

UPDATE structured_contents sc
SET sc.folder_id = sc.catalog_id;

UPDATE structured_contents_published scpub
    JOIN structured_contents sc ON sc.id = scpub.id
SET scpub.uuid        = sc.uuid,
    scpub.site_id     = sc.site_id,
    scpub.type        = sc.type,
    scpub.template_id = sc.template_id,
    scpub.folder_id   = sc.folder_id;

DROP VIEW IF EXISTS pages_folders_lang_path;
CREATE VIEW pages_folders_lang_path AS
SELECT f.site_id, f.id AS folder_id, fd.langue_id,
    CONCAT_WS('/',NULLIF(fd3.path_prefix,''), NULLIF(fd2.path_prefix,''),NULLIF(fd.path_prefix,'')) as concat_path,
    f.folder_level, fd.path_prefix path1, fd2.path_prefix path2, fd3.path_prefix path3
FROM pages_folders f
JOIN folders_details fd ON fd.folder_id = f.id
LEFT JOIN pages_folders f2 ON f.parent_folder_id = f2.id
LEFT JOIN folders_details fd2 ON fd2.folder_id = f2.id AND fd.langue_id = fd2.langue_id
LEFT JOIN pages_folders f3 ON f2.parent_folder_id = f3.id
LEFT JOIN folders_details fd3 ON fd3.folder_id = f3.id AND fd.langue_id = fd3.langue_id;

-- END 14-09-2021 --

-- START 05-10-2021 --
-- updating bloc and content data json entries change catalog c. to folder f.
UPDATE blocs
SET template_data = REPLACE(template_data,'"c.','"f.')
WHERE  template_data LIKE '%"c.%';

UPDATE blocs
SET template_data = REPLACE(template_data,'"cd.','"fd.')
WHERE  template_data LIKE '%"cd.%';

UPDATE menus
SET template_data = REPLACE(template_data,'"c.','"f.')
WHERE  template_data LIKE '%"c.%';

UPDATE menus
SET template_data = REPLACE(template_data,'"cd.','"fd.')
WHERE  template_data LIKE '%"cd.%';

UPDATE structured_contents_details
SET content_data = REPLACE(content_data,'"c.','"f.')
WHERE  content_data LIKE '%"c.%';

UPDATE structured_contents_details_published
SET content_data = REPLACE(content_data,'"c.','"f.')
WHERE  content_data LIKE '%"c.%';

UPDATE structured_contents_details
SET content_data = REPLACE(content_data,'"cd.','"fd.')
WHERE  content_data LIKE '%"cd.%';

UPDATE structured_contents_details_published
SET content_data = REPLACE(content_data,'"cd.','"fd.')
WHERE  content_data LIKE '%"cd.%';

-- END 05-10-2021 --
