-- START 29-10-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('CHECKOUT_JSP', '/cart/payment.jsp');
-- END 29-10-2020 --

-- START 11-11-2020 --
alter table sites add suid varchar(36) not null after id;
update dev_portal.sites set suid = uuid();
alter table sites add unique key (suid);

alter table dev_prod_portal.sites add suid varchar(36) not null after id;
update dev_prod_portal.sites s inner join dev_portal.sites s2 on s.id = s2.id set s.suid = s2.suid;
alter table dev_prod_portal.sites add unique key (suid);


drop view dev_portal.login;
create view dev_portal.login as select * from dev_catalog.login;

drop view dev_prod_portal.login;
create view dev_prod_portal.login as select * from dev_catalog.login;

-- END 11-11-2020 --

-- START 26-11-2020 --
ALTER TABLE dev_portal.clients ADD COLUMN is_active tinyint(1) not null default 1;
ALTER TABLE dev_prod_portal.clients ADD COLUMN is_active tinyint(1) not null default 1;
-- END 26-11-2020 --


-- START 27-11-2020 --
alter table dev_portal.clients change email username varchar(255) not null;
alter table dev_portal.clients add email varchar(255) after username;
update dev_portal.clients set email = username;

alter table dev_prod_portal.clients change email username varchar(255) not null;
alter table dev_prod_portal.clients add email varchar(255) after username;
update dev_prod_portal.clients set email = username;
-- END 27-11-2020 --

-- START 27-11-2020 --
ALTER TABLE dev_portal.sites ADD COLUMN auto_accept_signup tinyint(1) not null default 0;
ALTER TABLE dev_prod_portal.sites ADD COLUMN auto_accept_signup tinyint(1) not null default 0;

alter table dev_portal.clients add column form_row_id int(11);
alter table dev_prod_portal.clients add column form_row_id int(11);


-- END 27-11-2020 --

-- START 04-12-2020 --
alter table dev_portal.clients change additional_info additional_info mediumtext ;
alter table dev_portal.clients add avatar text ;
alter table dev_portal.clients add civility varchar(10) ;

alter table dev_prod_portal.clients change additional_info additional_info mediumtext ;
alter table dev_prod_portal.clients add avatar text ;
alter table dev_prod_portal.clients add civility varchar(10) ;

insert into dev_portal.config (code,val) values ('CATALOG_LINK','/dev_catalog/');
insert into dev_prod_portal.config (code,val) values ('CATALOG_LINK','/dev_prodcatalog/');
-- END 04-12-2020 --

