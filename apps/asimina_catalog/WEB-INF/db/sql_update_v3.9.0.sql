update dev_commons.config set val = '3.9.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.9.0.1' where code = 'CSS_JS_VERSION';

-------------- MAHIN 07/12/2022 --------------------------------

CREATE TABLE dev_commons.sites_langs(
	site_id INT(10),
	langue_id INT(1),
	UNIQUE KEY `sites_langs_index` (`site_id`,`langue_id`)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO dev_commons.sites_langs(site_id,langue_id)
SELECT s.id, l.langue_id 
FROM dev_portal.sites s, dev_portal.`language` l;




--------------Start Ahsan 13 Dec 2022 -------------------
CREATE TABLE login_v390 select * from login;
Alter table login add column is_two_auth_enabled tinyInt(1) default 0,add column send_email tinyInt(1) default 0, add column secret_key varchar(100);
ALTER TABLE login ENGINE=InnoDB;
alter table login ENCRYPTED=Yes;
--------------End Ahsan 15 Dec 2022 ----------------- 

insert into dev_commons.config (code, val) values ('APP_INSTANCE_NAME','DEV');
