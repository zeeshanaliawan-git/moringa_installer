
-- START 02-02-2021 --

ALTER TABLE files ADD COLUMN site_id int(10) unsigned DEFAULT '0' AFTER file_name;

ALTER TABLE files DROP INDEX IF EXISTS uk_files_name_type;
ALTER TABLE files ADD CONSTRAINT uk_files_name_type  UNIQUE INDEX IF NOT EXISTS (site_id,file_name,type);

-- END 02-02-2021 --
