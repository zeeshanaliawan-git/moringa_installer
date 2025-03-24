alter table algolia_indexation modify algolia_json mediumtext;

alter table sites add partoo_activated tinyint(1) not null default 0;
alter table sites add partoo_organization_id varchar(50);
alter table sites add partoo_country_code varchar(2);
alter table sites add partoo_api_key varchar(255);
alter table sites add partoo_main_group varchar(255);
alter table sites add partoo_language_id varchar(2) comment 'the language which will be used at time of calling partoo api';
