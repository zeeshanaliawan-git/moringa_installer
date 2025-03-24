alter table partoo_publish add attempt int(5) not null default 0;
alter table partoo_publish add updated_ts datetime default null;
