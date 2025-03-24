-- start 03/09/2020 ----

ALTER TABLE mails ADD COLUMN  `template_type` char(15) DEFAULT 'text';

-- end 03/09/2020 ----

-- start 10/23/2020 ----

ALTER TABLE process_form_fields ADD COLUMN custom_classes varchar(255) DEFAULT '';

-- end 10/23/2020 ----

-- start 11/04/2020 ----

ALTER TABLE process_forms ADD COLUMN form_css longtext DEFAULT NULL;

-- end 11/04/2020 ----

-- start 11/13/2020 ----
ALTER TABLE process_form_fields ADD COLUMN date_format VARCHAR(25) DEFAULT 'm/d/Y';
-- end 11/13/2020 ----
