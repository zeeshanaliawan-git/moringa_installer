-- START 08-05-2020 --

ALTER TABLE process_form_fields
ADD COLUMN default_country_code char(2) DEFAULT '',
ADD COLUMN allow_country_code varchar(100) DEFAULT '',
ADD COLUMN allow_national_mode char(1) DEFAULT '1',
ADD COLUMN local_country_name char(1) DEFAULT '0';

-- END 08-05-2020 --

-- START 20-05-2020 --

ALTER TABLE mail_config
ADD COLUMN email_cc mediumtext,
ADD COLUMN email_ci mediumtext;

ALTER TABLE process_form_fields ADD COLUMN hidden char(1) DEFAULT '0';
ALTER TABLE process_forms ADD COLUMN form_js longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '';

-- END 20-05-2020 --

-- START 29-05-2020 --

ALTER TABLE process_form_fields 
MODIFY img_url VARCHAR(255),
MODIFY img_alt VARCHAR(100),
MODIFY img_murl VARCHAR(255);

-- END 29-05-2020 --

-- START 03-06-2020 --

ALTER TABLE process_form_field_descriptions ADD COLUMN option_query TEXT;
CREATE TABLE process_form_fields_temp AS SELECT * FROM process_form_fields;
ALTER TABLE process_form_fields DROP COLUMN element_option_query_value;

INSERT INTO config(code, val) VALUES ('PAGES_URL','/dev_pages/');

-- END 03-06-2020 --

-- START 09-06-2020 --

ALTER TABLE process_form_descriptions MODIFY success_msg text DEFAULT '';
ALTER TABLE process_form_field_descriptions MODIFY label text DEFAULT '';

-- END 09-06-2020 --
