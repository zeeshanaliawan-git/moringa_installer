update dev_commons.config set val = '4.9.1' where code = 'APP_VERSION';
update dev_commons.config set val = '4.9.1.1' where code = 'CSS_JS_VERSION';

----------- Ashan Start 3 Oct 2024 -----------
alter table attributes_v2 add column unit varchar(255) default '';
alter table attributes_v2 add column icon varchar(255) default '';
----------- Ashan End 3 Oct 2024 -----------