
alter table orders modify identityType varchar(500);

------------ Ashan start 7 Feb 2023 -------------------
CREATE TABLE `person_sites` (
  `person_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`person_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table processes(
  process_name varchar(75),
  display_name varchar(75),
  site_id int(11),
  PRIMARY key (process_name)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table profil add column assign_site tinyInt(1) not null default 0;

insert ignore into processes (process_name,display_name,site_id) select distinct process,process, (SELECT site_id FROM orders ORDER BY id desc LIMIT 1) as site_id from phases;

insert into person_sites (site_id,person_id) SELECT (SELECT site_id FROM orders ORDER BY id desc LIMIT 1) as site_id,pp.person_id FROM profil p, profilperson pp WHERE p.profil_id = pp.profil_id and p.assign_site=1;

INSERT INTO page (NAME,url,rang,icon) VALUES ('Home','/dev_shop/admin/gestion.jsp',0,'cui-home');

UPDATE page SET rang=1 WHERE url='/dev_shop/dashboard/dashboard.jsp';

DELETE FROM public_urls WHERE url='/dashboard/';

alter table login add column selected_site_id int(11) not null default 0;

alter table store_emails add column site_id int(11) not null default 0;
update store_emails set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

alter table supplier add column site_id int(11) not null default 0;
update supplier set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

alter table mails add column site_id int(11) not null default 0;
update mails set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

alter table sms add column site_id int(11) not null default 0;
update sms set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

alter table dashboard_urls add column site_id int(11) not null default 0;
update dashboard_urls set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

update dashboard_phases_config set site_id= (SELECT site_id FROM orders ORDER BY id desc LIMIT 1);

alter table coordinates modify column process varchar(75);
alter table coordinates modify column phase varchar(75);

alter table external_phases modify column start_proc varchar(75);
alter table external_phases modify column next_proc varchar(75);
alter table external_phases modify column next_phase varchar(75);

alter table field_settings modify column process varchar(75);
alter table field_settings modify column phase varchar(75);

alter table generic_forms_process_mapping modify column process varchar(75);
alter table generic_forms_process_mapping modify column phase varchar(75);

alter table has_action modify column start_proc varchar(75);
alter table has_action modify column start_phase varchar(75);

alter table phases modify column process varchar(75);
alter table phases modify column phase varchar(75);

alter table post_work modify column proces varchar(75);
alter table post_work modify column phase varchar(75);

alter table rules modify column start_proc varchar(75);
alter table rules modify column start_phase varchar(75);

alter table rules modify column next_proc varchar(75);
alter table rules modify column next_phase varchar(75);

------------ Ashan End 7 Feb 2023 -------------------