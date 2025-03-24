-- START 05-03-2020 --
insert into page (name, url, parent, rang, icon, parent_icon) values ('Search Forms','/dev_forms/admin/searchforms.jsp','System','609','chevron-right','settings');
-- END 05-03-2020 --


-- START 03-04-2020 --
insert into dev_commons.config (code, val, comments) values ('PREPROD_CATALOG_DB','dev_catalog', 'This is used in com.etn.asimina.util.UrlReplacer class. That class will be almost in all apps so we add specific configs in commons db');

CREATE TABLE `catalog_descriptions` (
  `catalog_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `canonical_url` varchar(1000) NOT NULL DEFAULT '',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  PRIMARY KEY (`catalog_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;


update dev_commons.config set val = '2.2' where code = 'app_version';
-- END 03-04-2020 --

-- START 11-04-2020 --
alter table dev_commons.user_sessions add is_publish_prod_login tinyint(1) not null default 0;
-- END 11-04-2020 --

-- START 14-04-2020 --
alter table catalog_descriptions add folder_name varchar(255) comment 'This name will be used for default path for products in a catalog';
-- END 14-04-2020 --


-- START 18-04-2020 --

drop table dev_prod_catalog.language;

-- Translations must have one common table and no need of publish to prod 
-- Normally if a word needs translation the code adds it to langue_msg table 
-- and there were cases when in Test site those pages were not viewed so 
-- the translations key words were not there in langue_msg table and user was not able to publish them
-- So to get rid of this situation translations will be common from now on
drop table dev_prod_catalog.langue_msg;

create view dev_prod_catalog.language as select * from dev_catalog.language;
create view dev_prod_catalog.langue_msg as select * from dev_catalog.langue_msg;

-- END 18-04-2020 --

-- START 23-04-2020 -- 

ALTER TABLE `delivery_methods`
CHANGE COLUMN `subText` `subType`  varchar(50) NOT NULL DEFAULT '' AFTER `orderSeq`,
ADD COLUMN `mapsDisplay`  tinyint(1) NULL AFTER `subType`;

ALTER TABLE `delivery_methods`
DROP INDEX `site_id` ,
ADD UNIQUE INDEX `site_id` (`site_id`, `method`, `subType`) USING BTREE ;


-- END 23-04-2020 --


-- START 26-04-2020 --
alter table dev_commons.config change code code varchar(100) not null;
--commons engine configs
insert into dev_commons.config(code, val, comments) values ('HTTP_PROXY_AUTH','','');
insert into dev_commons.config(code, val, comments) values ('APP_PREFIX','dev','');
insert into dev_commons.config (code, val, comments) values ('MAIL.SMTP.HOST','127.0.0.1','');
insert into dev_commons.config (code, val, comments) values ('MAIL.SMTP.PORT','25','');
insert into dev_commons.config (code, val, comments) values ('MAIL.SMTP.AUTH','false','');
insert into dev_commons.config (code, val, comments) values ('MAIL.SMTP.AUTH.USER','','');
insert into dev_commons.config (code, val, comments) values ('MAIL.SMTP.AUTH.PWD','','');

insert into dev_commons.config (code, val, comments) values ('CACHESYNC_DB','dev_sync','');



insert into config (code, val, comments) values ('WAIT_TIMEOUT','300','');
insert into config (code, val, comments) values ('DEBUG','Oui','');

insert into config (code, val, comments) values ('SHELL_DIR','/home/ronaldo/pjt/dev_engines/catalog/bin','');

insert into config (code, val, comments) values ('PROD_PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/essentials/','');

insert into config (code, val, comments) values ('PROD_CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/ronaldo/tomcat/webapps/dev_prodcatalog/uploads/catalogs/essentials/','');

insert into config (code, val, comments) values ('COPY_PRODUCT_COMMENTS','0','If we want comments added in test site by admins to be moved to prod at time of publish set this to 1');

-- END 26-04-2020 --


-- START 07-05-2020 --
insert into page (name, url, parent, rang, icon, parent_icon) values ('Clients Log','/dev_menu/pages/prodclientslog.jsp','System','611','chevron-right','settings');
update page set rang = 612 where name = 'Search Forms' and parent = 'System';
-- END 07-05-2020 --