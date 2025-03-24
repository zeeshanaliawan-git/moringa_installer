

-- START 30-12-2020 --
-- Ali Adnan , for temp files writing to disk e.g. import data files
INSERT INTO dev_commons.config(code, val, comments) VALUES ('TEMP_DIRECTORY','/tmp/dev_tmp/','This path should not be inside tomcat as we just need to upload files and use them for processing');
INSERT INTO dev_commons.config(code, val, comments) VALUES ('ADMIN_PASS_SALT', left(UUID(), 8), 'Salt used for admin side passwords');
INSERT INTO dev_commons.config(code, val, comments) VALUES ('CLIENT_PASS_SALT', left(UUID(), 8), 'Salt used for client passwords');

update dev_commons.config set val = '2.5.1' where code = 'APP_VERSION';
update dev_commons.config set val = '2.5.1.0' where code = 'CSS_JS_VERSION';

alter table dev_catalog.login change pass pass varchar(75) not null;
alter table dev_catalog.login add pass_expiry date not null;

update dev_catalog.login set pass_expiry = adddate(now(), interval 90 day);

update dev_catalog.login l, dev_commons.config c set pass = sha2(concat(c.val,':', 'welcome01', ':', puid), 256) where c.code = 'ADMIN_PASS_SALT';


update dev_catalog.login l, dev_commons.config c set pass = sha2(concat(c.val,':', 'tadmin00$#t0', ':', puid), 256) where name = 'tadmin' and c.code = 'ADMIN_PASS_SALT';
update dev_catalog.login l, dev_commons.config c set pass = sha2(concat(c.val,':', 'padmin00$#p0', ':', puid), 256) where name = 'padmin' and c.code = 'ADMIN_PASS_SALT';

-- END 30-12-2020 --


