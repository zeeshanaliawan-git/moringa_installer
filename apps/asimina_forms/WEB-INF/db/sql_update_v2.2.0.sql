-- START 18-03-2020 -- 

CREATE TABLE `process_form_lines` (
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `line_id` varchar(50) DEFAULT '',
  `line_class` varchar(50) DEFAULT '',
  `line_width` char(10) DEFAULT '',
  `line_seq` char(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `process_forms`
ADD COLUMN `variant` char(12) NOT NULL,
ADD COLUMN `template` char(15) NOT NULL,
ADD COLUMN `meta_description` text,
ADD COLUMN `meta_keywords` text,
ADD COLUMN `form_class` text,
ADD COLUMN `html_form_id` varchar(25) DEFAULT '',
ADD COLUMN `form_method` char(10) DEFAULT '',
ADD COLUMN `form_enctype` varchar(50) DEFAULT '',
ADD COLUMN `form_autocomplete` char(10) DEFAULT '';

ALTER TABLE process_form_fields ADD COLUMN `line_id` varchar(36) NOT NULL;

INSERT INTO config(code, val) VALUES ('FORM_DB', 'dev_forms');

ALTER TABLE process_form_fields MODIFY value VARCHAR(255) DEFAULT NULL;
-- END 18-03-2020 -- 

-- START 27-03-2020 -- 
ALTER TABLE process_forms ADD COLUMN `redirect_url` varchar(255) DEFAULT '';
ALTER TABLE process_forms DROP INDEX process_name;
ALTER TABLE process_forms ADD UNIQUE (process_name, site_id);
ALTER TABLE process_forms ADD COLUMN btn_align CHAR(1) DEFAULT 'r';
ALTER TABLE process_forms ADD COLUMN cancel_btn_lbl varchar(255) DEFAULT '';
ALTER TABLE process_forms ADD COLUMN label_display CHAR(3) DEFAULT 'tal';

ALTER TABLE process_form_fields 
ADD COLUMN min_range int(10) DEFAULT '0',
ADD COLUMN max_range int(10) DEFAULT '0',
ADD COLUMN step_range int(10) DEFAULT '0';
-- END 27-03-2020 -- 



-- START 03/04/2020 ---

CREATE TABLE `process_form_descriptions` (
  `form_id`  varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  PRIMARY KEY (`form_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

-- END 03/04/2020 ---


-- START 26-04-2020 --
alter table config change code code varchar(100) not null;

insert into config (code, val, comments) values ('MAIL.SMTP.DEBUG','true','');

insert into config (code, val, comments) values ('WAIT_TIMEOUT','300','');
insert into config (code, val, comments) values ('DEBUG','Oui','');

insert into config (code, val, comments) values ('SHELL_DIR','/home/ronaldo/pjt/dev_engines/forms/bin','');

insert into config (code, val, comments) values ('WITH_MAIL','Oui','');

insert into config (code, val, comments) values ('MAIL_REPOSITORY','/home/ronaldo/tomcat/webapps/dev_forms/mail_sms/mail','');
insert into config (code, val, comments) values ('MAIL_DEBUG','OUI','');
insert into config (code, val, comments) values ('MAIL_FROM','noreply@eboutique.com','');
insert into config (code, val, comments) values ('MAIL_REPLY','noreply@eboutique.com','');
insert into config (code, val, comments) values ('BACKOFFICE_MAIL_FROM','noreply@eboutique.com','');
insert into config (code, val, comments) values ('BACKOFFICE_MAILS','','');
insert into config (code, val, comments) values ('MAIL_FROM_DISPLAY_NAME','Service','');
insert into config (code, val, comments) values ('UPLOADED_FILES_REPOSITORY','/home/ronaldo/tomcat/webapps/dev_forms/uploads/','');

-- END 26-04-2020 --

-- START 29-04-2020 --

ALTER TABLE process_forms ADD COLUMN form_width char(10) DEFAULT '';
ALTER TABLE process_form_fields ADD COLUMN img_url varchar(20) DEFAULT '';
ALTER TABLE process_form_descriptions
ADD COLUMN title varchar(255) DEFAULT '',
ADD COLUMN success_msg varchar(255) DEFAULT '',
ADD COLUMN submit_btn_lbl varchar(255) DEFAULT '',
ADD COLUMN cancel_btn_lbl varchar(255) DEFAULT '';

CREATE TABLE process_form_field_descriptions (
  form_id varchar(36) NOT NULL,
  field_id varchar(36) NOT NULL,
  langue_id int(1) NOT NULL COMMENT 'language for which the resource was added',
  label varchar(255) DEFAULT '',
  placeholder varchar(50) DEFAULT '',
  err_msg varchar(255) DEFAULT '',
  value varchar(255) DEFAULT '',
  options text,
  PRIMARY KEY (form_id,field_id,langue_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table process_forms_temp as SELECT * FROM process_forms;


create table process_form_fields_temp as SELECT * FROM process_form_fields;

ALTER TABLE process_forms 
DROP COLUMN title,
DROP COLUMN success_msg,
DROP COLUMN submit_btn_lbl,
DROP COLUMN cancel_btn_lbl;

ALTER TABLE process_form_fields 
DROP COLUMN label,
DROP COLUMN label_name,
DROP COLUMN placeholder,
DROP COLUMN err_msg,
DROP COLUMN value,
DROP COLUMN options;

-- END 29-04-2020 --

-- START 30-06-2020 --

ALTER TABLE process_form_field_descriptions ADD COLUMN option_query TEXT;
ALTER TABLE process_form_descriptions MODIFY success_msg text DEFAULT '';
ALTER TABLE process_form_field_descriptions MODIFY label text DEFAULT '';

-- END 30-06-2020 --
