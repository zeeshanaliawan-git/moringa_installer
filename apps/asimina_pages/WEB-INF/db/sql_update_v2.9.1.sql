-- START 06-07-2021 --

DROP VIEW IF EXISTS menus;
DROP VIEW IF EXISTS menus_apply_to;

ALTER TABLE dev_portal.menus
DROP COLUMN production_path,
DROP COLUMN homepage_url,
DROP COLUMN page_404_url,
DROP COLUMN favicon,
DROP COLUMN favicon_alt;

DROP TABLE dev_portal.menus_apply_to;

CREATE VIEW menus AS
SELECT * FROM dev_portal.menus;

-- END 06-07-2021 --