-- START 28-05-2020 --

ALTER TABLE `order_items`
ADD COLUMN `comewiths`  text NULL DEFAULT NULL AFTER `installment_discount_duration`,
ADD COLUMN `additionalfees`  text NULL DEFAULT NULL AFTER `comewiths`;

ALTER TABLE `orders`
ADD COLUMN `identityPhoto`  varchar(50) NULL DEFAULT NULL AFTER `courier_name`,
ADD COLUMN `newPhoneNumber`  varchar(15) NULL DEFAULT NULL AFTER `identityPhoto`,
ADD COLUMN `selected_boutique`  text NULL DEFAULT NULL AFTER `newPhoneNumber`,
ADD COLUMN `rdv_boutique`  varchar(5) NULL DEFAULT NULL AFTER `selected_boutique`,
ADD COLUMN `rdv_date`  datetime NULL DEFAULT NULL AFTER `rdv_boutique`,
ADD COLUMN `delivery_type`  varchar(50) NULL DEFAULT NULL AFTER `rdv_date`,
ADD COLUMN `site_id`  int(10) NULL DEFAULT NULL AFTER `delivery_type`,
ADD COLUMN `country`  varchar(64) NULL DEFAULT NULL AFTER `site_id`;

-- END 28-05-2020 --



-- START 02-06-2020 --
insert into config (code, val, comments) values ('WAIT_TIMEOUT','300','');
insert into config (code, val, comments) values ('DEBUG','Oui','');

insert into config (code, val, comments) values ('SHELL_DIR','/home/ronaldo/pjt/dev_engines/shop/bin','');

insert into config (code, val, comments) values ('WITH_MAIL','Oui','');
insert into config (code, val, comments) values ('MAIL_REPOSITORY','/home/ronaldo/tomcat/webapps/dev_shop/mail_sms/mail','');
insert into config (code, val, comments) values ('MAIL_DEBUG','OUI','');
insert into config (code, val, comments) values ('MAIL_FROM','noreply@eboutique.com','');
insert into config (code, val, comments) values ('MAIL_REPLY','noreply@eboutique.com','');
insert into config (code, val, comments) values ('MAIL_FROM_DISPLAY_NAME','Service','');
insert into config (code, val, comments) values ('STOCK_MAIL_REPOSITORY','/home/ronaldo/tomcat/webapps/dev_shop/mail_sms/stock_mail','');
insert into config (code, val, comments) values ('WKHTMLTOIMAGE_PATH','/home/ronaldo/pjt/dev_engines/shop/wkhtmltoimage','');

insert into config (code, val, comments) values ('CALENDAR_DIR','/home/ronaldo/pjt/dev_engines/shop/calfiles/','');
insert into config (code, val, comments) values ('CALENDAR_NAME','Dev Calendar','');

insert into config (code, val, comments) values ('INVOICE_DIR','/home/ronaldo/tomcat/webapps/dev_catapulte/upload/invoices/','');

insert into config (code, val, comments) values ('ANSWERS_URL','/dev_portal/pages/answerquestion.jsp','');
insert into config (code, val, comments) values ('PDF_REPO','/home/ronaldo/tomcat/webapps/dev_portal/invoices','');
insert into config (code, val, comments) values ('HTML_TO_PDF_CMD','/home/ronaldo/pjt/dev_engines/shop/wkhtmltopdf','');
insert into config (code, val, comments) values ('SMS_URL','','');
insert into config (code, val, comments) values ('DEFAULT_SMS_COLUMN','','');
insert into config (code, val, comments) values ('SMS_URL_PARAMS','','');
-- END 02-06-2020 --


-- START 05-06-2020 --

ALTER TABLE `orders`
ADD COLUMN `newsletter`  tinyint(1) NULL AFTER `country`;

alter table orders add comments text;
-- END 05-06-2020 --

