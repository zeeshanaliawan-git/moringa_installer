
CREATE TABLE `config` (
  `code` varchar(50) DEFAULT NULL,
  `val` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- START 08-04-2019 -- 

ALTER TABLE process_forms ADD COLUMN site_id int(11) NOT NULL DEFAULT '0';
UPDATE page SET new_tab = '0' WHERE name = 'Forms';

-- END 08-04-2019 -- 


-- START 07-05-2019 -- 

ALTER TABLE process_forms ADD COLUMN submit_btn_lbl VARCHAR(255) DEFAULT NULL;
ALTER TABLE process_form_fields ADD COLUMN custom_css text DEFAULT NULL;

-- END 07-05-2019 -- 


-- END 07-10-2019 -- 
alter table dev_forms.config add comments text;

insert into dev_forms.config (code, val) values ('FORM_UPLOADS_ROOT_PATH','/home/ronaldo/tomcat/webapps/dev_forms/uploads/');
insert into dev_forms.config (code, val) values ('FORM_UPLOADS_PATH','/dev_forms/uploads/');
insert into dev_forms.config (code, val) values ('CATALOG_DB','dev_catalog');
insert into dev_forms.config (code, val) values ('FORMS_WEB_APP','/dev_forms/');
insert into dev_forms.config (code, val) values ('UPLOAD_IMG_PATH','/home/ronaldo/tomcat/webapps/dev_forms/uploads/images/');
insert into dev_forms.config (code, val) values ('CATALOG_URL','/dev_catalog/');
insert into dev_forms.config (code, val) values ('MAIL_UPLOAD_PATH','/home/ronaldo/tomcat/webapps/dev_forms/mail_sms/mail/');
insert into dev_forms.config (code, val) values ('SEMAPHORE','D003');
insert into dev_forms.config (code, val) values ('PORTAL_DB','dev_portal');
insert into dev_forms.config (code, val) values ('GOTO_FORMS_APP_URL','/dev_catalog/admin/forms.jsp');
insert into dev_forms.config(code,val) values ('COMMONS_DB','dev_commons'); 

-- END 07-10-2019 -- 

-- START 19-11-2019 -- 
ALTER TABLE process_form_fields ADD COLUMN site_key varchar(255) DEFAULT NULL;
ALTER TABLE process_form_fields ADD COLUMN theme varchar(50) DEFAULT NULL;
ALTER TABLE process_form_fields ADD COLUMN recaptcha_data_size varchar(50) DEFAULT NULL;
ALTER TABLE process_form_fields ADD COLUMN custom_css text DEFAULT NULL;
-- END 19-11-2019 -- 
