alter table idnow_sessions add iframe_url_json mediumtext;
alter table idnow_sessions add site_id int(11) not null;
alter table idcheck_access_tokens add idnow_uuid varchar(75);
alter table idcheck_access_tokens modify idnow_uuid varchar(75);

insert into config (code, val) value ("IDNOW_CIS_BASE_URL", "https://api-test.ariadnext.com/gw/cis/");


alter table sites add is_active tinyint(1) not null default 1;

