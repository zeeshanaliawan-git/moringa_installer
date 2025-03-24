drop view page;
create view page as select * from dev_catalog.page;

alter table cart add ip varchar(50);
alter table cart add visited_cart_page tinyint(1) not null default 0;

alter table client_reactions modify source_type enum ('page','product','forum') not null;
alter table client_favorites modify source_type enum ('page','product','forum') not null;

insert into config (code, val, comments) values ('allow_iframe_domains','','comma separate list of domains for which are allowed to include cached page as iframe');

alter table sites add voucher_api_implementation_cls VARCHAR(75);