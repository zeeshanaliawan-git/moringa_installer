-- START 11-11-2020 --

drop view login;
create view login as select * from dev_catalog.login;

-- END 11-11-2020 --


-- START 24-11-2020 --

INSERT INTO config(code, val) VALUES('PROD_PORTAL_DB', 'dev_prod_portal');
INSERT INTO dev_commons.config(code, val) VALUES('PROD_PORTAL_DB', 'dev_prod_portal');

INSERT INTO actions(name, className) VALUES 
('client','AsiminaClient'),
('checkAdmin','CheckAdmin'),
('checkAuto','CheckAuto');


ALTER TABLE process_form_fields change date_format date_format VARCHAR(25) DEFAULT 'm/d/Y';

ALTER TABLE process_forms `type` varchar(25) not null default 'simple';

ALTER TABLE process_form_fields ADD COLUMN `is_deletable` char(1) DEFAULT '1';

-- END 24-11-2020 --
