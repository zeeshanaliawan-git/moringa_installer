
-- START 02-03-2020

ALTER TABLE files
MODIFY COLUMN type  enum('css','js','fonts','other') NOT NULL;

-- 2MB, in bytes : 2 * 1024 * 1024 = 2097152
INSERT INTO config(code,val,comments)
VALUES ('MAX_FILE_UPLOAD_SIZE', '2097152','size in bytes, must be numeric only');
-- 10MB, in bytes : 10 * 1024 * 1024 = 10485760
INSERT INTO config(code,val,comments)
VALUES ('MAX_FILE_UPLOAD_SIZE_OTHER', '10485760','size in bytes, must be numeric only, used for [other] file type ');

ALTER TABLE components
ADD COLUMN thumbnail_status enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished';

ALTER TABLE components
ADD COLUMN thumbnail_file_name varchar(100) NOT NULL DEFAULT '';

ALTER TABLE components
ADD COLUMN thumbnail_log mediumtext NOT NULL;

ALTER TABLE components
ADD COLUMN html mediumtext;


ALTER TABLE pages
ADD COLUMN get_html_status  enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished';
ALTER TABLE pages
ADD COLUMN get_html_log mediumtext NOT NULL DEFAULT '';
ALTER TABLE pages
ADD COLUMN dynamic_html text NOT NULL DEFAULT '';

-- END 02-03-2020

-- moving images to "files" table. images table was redundant, hence obsolete.

ALTER TABLE files
ADD COLUMN label  varchar(300) NOT NULL DEFAULT '' AFTER file_name,
DROP INDEX uk_files_name ,
ADD UNIQUE INDEX uk_files_name_type (file_name, type);

ALTER TABLE files
MODIFY COLUMN type  enum('img','css','js','fonts','other','video') NOT NULL;


INSERT IGNORE INTO files ( file_name, label, type, file_size, created_ts, updated_ts, created_by, updated_by)
SELECT file_name, label, 'img', file_size, created_ts, updated_ts, created_by, updated_by
FROM images
order by created_ts ASC;

-- for existing 'other' type files , as now label is mandatory for media library
UPDATE files SET label = file_name WHERE type IN ('other','video');

-- 10MB, in bytes : 50 * 1024 * 1024 = 52428800
INSERT INTO config(code,val,comments)
VALUES ('MAX_FILE_UPLOAD_SIZE_VIDEO', '52428800','size in bytes, must be numeric only, used for [video] file type ');


-- START 15-04-2020
CREATE TABLE structured_catalogs_details (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  catalog_id int(11) unsigned NOT NULL,
  langue_id int(1) unsigned NOT NULL,
  path_prefix varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY catalog_lang(catalog_id, langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 15-04-2020

