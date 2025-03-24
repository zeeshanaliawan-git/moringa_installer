-- START 24-03-2022 ---
-- AHSAN 
INSERT INTO dev_shop.dashboard_phases_config (`site_id`, `ctype`,`process`,`phase`) VALUES (1,'delivery','OBF','ColisRemis');

ALTER TABLE dev_shop.phases 
ADD COLUMN displayName2 VARCHAR(100),
ADD COLUMN displayName3 VARCHAR(100),
ADD COLUMN displayName4 VARCHAR(100),
ADD COLUMN displayName5 VARCHAR(100);
-- END 24-03-2022 ---