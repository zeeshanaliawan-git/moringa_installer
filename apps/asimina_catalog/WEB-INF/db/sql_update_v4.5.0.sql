update dev_commons.config set val = '4.5.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.5.0.1' where code = 'CSS_JS_VERSION';

----------------Ahsan start 1 Dec 2023----------------
ALTER TABLE catalogs_tbl DROP INDEX site_id_uuid;
ALTER TABLE catalogs_tbl ADD UNIQUE INDEX site_id_uuid (site_id, catalog_uuid, is_deleted);

DROP VIEW IF EXISTS catalogs;
CREATE VIEW catalogs AS SELECT * FROM catalogs_tbl WHERE is_deleted = 0;
----------------Ahsan end 1 Dec 2023----------------