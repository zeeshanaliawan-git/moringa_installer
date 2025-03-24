---------------Ashan Start 8 march 2023 -----------------------
DROP TABLE if EXISTS stat_log_page_ref;
create table stat_log_page_ref(
 id varchar(64),
 site_id int(11),
 page_c varchar(255),
 page_ref varchar(255),
 primary key (id,site_id)
)ENGINE=MyISAM default CHARSET=utf8;

insert ignore into stat_log_page_ref (id,page_c,page_ref,site_id) select distinct SHA2(CONCAT(TRIM(trailing '#' from s.page_c),s.page_ref),256),
TRIM(trailing '#' from s.page_c),s.page_ref,sm.site_id from stat_log s left join site_menus sm ON s.menu_uuid=sm.menu_uuid  
where COALESCE(TRIM(trailing '#' from s.page_c),'') !='' and COALESCE(sm.menu_uuid,'')!='' ;

				------------Only in prod_portal----------------
alter table publish_content add column action_dt DATETIME default now();
alter table publish_content modify column ctype enum('page','structuredcontent','structuredpage','store','catalog','product','forum','marketing_rules');
alter table algolia_indexation add column variant_id int(11);
ALTER TABLE algolia_indexation DROP INDEX menu_id;
ALTER TABLE algolia_indexation ADD CONSTRAINT menu_id UNIQUE (`menu_id`,`ctype`,`cid`,`algolia_index`,`variant_id`);


---------------Ashan End 20 march 2023 -----------------------

alter table stat_log modify user_agent varchar(255);

--- only required in portal DB
drop table if exists cache_tasks;
create table cache_tasks (
id int(11) not null auto_increment,
site_id int(10) not null,
content_type enum('freemarker','structured','catalog','product','form', 'resources', 'cachesync') not null,
content_id varchar(75) not null,
task enum('generate','publish','unpublish') not null default 'publish',
status tinyint(1) not null default 0,
priority datetime not null default now(),
created_on TIMESTAMP not null default CURRENT_TIMESTAMP,
updated_on datetime,
start datetime default null,
end datetime default null,
attempt int(10) not null default 0,
primary key (id)
)engine=myisam default charset=utf8;


insert into dev_commons.config (code, val) values ('PORTAL_ENG_SEMA','D002');

alter table sites_apply_to add unique key unq1 (site_id, apply_type, apply_to);


--- only required in portal DB
insert into config(code, val) values ('SYNC_RESOURCES_FOLDER_SCRIPT','/home/etn/pjt/dev_engines/portal/syncresources.sh');
insert into dev_commons.config(code, val) values ('page_preview_api_url','/dev_catalog/admin/testsitepagepreview.jsp');
insert into config (code, val) values ('VARIANT_IMAGE_UPLOAD_DIRECTORY','/home/etn/tomcat/webapps/dev_shop/variant_images/');
