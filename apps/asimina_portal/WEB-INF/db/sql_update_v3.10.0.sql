alter table sites add open_only_in_iframe tinyint(1) not null default 0;

alter table cart modify identityType varchar(255);


-----------------Ahsan start 10 Feb 2023--------------------
drop table if exists site_config_process;
create table site_config_process(
 site_id int(11) not null,
 action enum('initpayment','confirmation'),
 process varchar(75) not null,
 phase varchar(75) not null,
 primary key (site_id, action)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table crawler_indexation modify column ctype enum('page','structuredpage','structuredcontent','offer','product','store','forum');
alter table algolia_indexation modify column ctype enum('page','structuredpage','structuredcontent','offer','product','store','forum');
-----------------Ahsan end 10 Feb 2023--------------------

insert into dev_portal.site_config_process (site_id, action, process, phase) select distinct site_id, 'initpayment', 'Order', 'InitiatePayment' from dev_shop.orders;
insert into dev_portal.site_config_process (site_id, action, process, phase) select distinct site_id, 'confirmation', 'Order', 'OrderReceived' from dev_shop.orders;

insert into dev_prod_portal.site_config_process (site_id, action, process, phase) select distinct site_id, 'initpayment', 'Order', 'InitiatePayment' from dev_prod_shop.orders;
insert into dev_prod_portal.site_config_process (site_id, action, process, phase) select distinct site_id, 'confirmation', 'Order', 'OrderReceived' from dev_prod_shop.orders;


