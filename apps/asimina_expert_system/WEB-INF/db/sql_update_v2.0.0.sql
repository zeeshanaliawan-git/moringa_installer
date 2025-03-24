drop table login;
drop table person;
drop table profil;
drop table profilperson;
drop table page;
drop table person_sites;
drop table profilemenu;
drop table relation;
drop table responsibility;

create view login as select * from dev_catalog.login;
create view person as select * from dev_catalog.person;
create view profil as select * from dev_catalog.profil;
create view profilperson as select * from dev_catalog.profilperson;
create view page as select * from dev_catalog.page;
create view person_sites as select * from dev_catalog.person_sites;
create view profilemenu as select * from dev_catalog.profilemenu;
create view relation as select * from dev_catalog.relation;
create view responsibility as select * from dev_catalog.responsibility;
create view page_sub_urls as select * from dev_catalog.page_sub_urls;


CREATE TABLE `config` (
  `code` varchar(50) DEFAULT NULL,
  `val` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table config add comments text;
alter table config add unique key (`code`);
alter table config convert to character set `utf8`;
delete from config;

insert into config (code, val) values ('ROOT_WEB','dev_expert_system');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER','/home/ronaldo/tomcat/webapps/dev_expert_system/generatedJs/');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATED_JS_URL','/generatedJs/');
insert into config (code, val) values ('EXPERT_SYSTEM_HELPER_JS_CSS_URL','/pages/');
insert into config (code, val) values ('WEBAPP_FOLDER','/home/ronaldo/tomcat/webapps/dev_expert_system/');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATE_JSP_FOLDER','/home/ronaldo/tomcat/webapps/dev_expert_system/generatedJsps/');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATE_HTML_FOLDER','/home/ronaldo/tomcat/webapps/dev_expert_system/generatedHtmls/');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATE_JSP_URL','/dev_expert_system/generatedJsps/');
insert into config (code, val) values ('EXPERT_SYSTEM_FETCH_JSP_TEMPLATE','/home/ronaldo/tomcat/webapps/dev_expert_system/pages/fetchdatajsptemplate');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATED_JSP_RELATIVE_PATH','generatedJsps/');
insert into config (code, val) values ('EXPERT_SYSTEM_GENERATED_HTML_RELATIVE_PATH','generatedHtmls/');
insert into config (code, val) values ('EXPERT_SYSTEM_RELATIVE_PATH_TO_GENERATE_JSP','../pages/');
insert into config (code, val) values ('EXPERT_SYSTEM_JQUERY_URL','/dev_expert_system/js/jquery.min.js');
insert into config (code, val) values ('EXPERT_SYSTEM_D3_TEMPLATES_PATH','/home/ronaldo/tomcat/webapps/dev_expert_system/pages/d3templates/');
insert into config (code, val) values ('CKEDITOR_WEB_URL','/home/ronaldo/tomcat/webapps/dev_ckeditor/pages/');
insert into config (code, val) values ('DOWNLOAD_PAGES_FOLDER','/home/ronaldo/tomcat/webapps/dev_ckeditor/sites/');
insert into config (code, val) values ('CKEDITOR_DOWNLOAD_PAGES_FOLDER','/dev_ckeditor/sites/');
insert into config (code, val) values ('EXPERT_SYSTEM_WEB_APP','/dev_expert_system/');
insert into config (code, val) values ('CKEDITOR_WEB_APP','/dev_ckeditor/');
insert into config (code, val) values ('REQUETE_WEB_APP','http://127.0.0.1/req_asimina/ws/es.jsp');

insert into config (code, val) values ('COMMONS_DB','dev_commons');
insert into config (code, val) values ('CKEDITOR_DB_NAME','dev_ckeditor');

insert into config (code, val) values ('GOTO_EXPSYS_APP_URL','/dev_catalog/admin/gotoexpertsystem.jsp');

insert into config (code, val) values ('CATALOG_URL','/dev_catalog/');
insert into config (code, val) values ('PORTAL_DB','dev_portal');
 
alter table expert_system_json add site_id int(11) not null;
update expert_system_json set site_id = 1;