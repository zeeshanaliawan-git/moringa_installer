create table api_fields_settings (
api_name varchar(25) not null,
field_name varchar(75) not null,
field_type varchar(25) not null,
is_required tinyint(1) not null,
primary key(api_name, field_name)
)Engine=MyISAM default charset=utf8;


-- maybe we have this configured in dev_portal.config so we try adding from there first otherwise we add from dev_commons.config
insert into sites_config (site_id, code, val, comments) select s.id, c.code, c.val, c.comments from dev_portal.sites s, dev_portal.config c where c.code = "allow_iframe_domains" and COALESCE(c.val,'') <> '';
insert into sites_config (site_id, code, val, comments) select s.id, c.code, c.val, c.comments from dev_portal.sites s, dev_commons.config c where c.code = "allow_iframe_domains" and COALESCE(c.val,'') <> '';

update config set comments = 'not used from here anymore. delete it in next version' where code = 'allow_iframe_domains';
update dev_commons.config set comments = 'not used from here anymore. delete it in next version' where code = 'allow_iframe_domains';
-- do not run this statement in dev_commons sql script file .. that executes before portal script so we must run this in portal scripts

ALTER TABLE idnow_sessions MODIFY COLUMN resp LONGTEXT;
ALTER TABLE idnow_sessions DROP CONSTRAINT un_key;
ALTER TABLE idnow_sessions DROP COLUMN cart_id;

ALTER TABLE cart DROP COLUMN idnow_resp;
ALTER TABLE cart DROP COLUMN idnow_status;
ALTER TABLE cart DROP COLUMN idnow_created_on;
ALTER TABLE cart DROP COLUMN idnow_resp_timestamp;
ALTER TABLE cart DROP COLUMN idnow_tries;
ALTER TABLE cart DROP COLUMN idnow_last_try_ts;
ALTER TABLE cart DROP COLUMN idnow_access_token;
ALTER TABLE cart DROP COLUMN idnow_expiry;


create table dev_commons.local_holidays
(
h_date date not null,
primary key(h_date)
)Engine=myisam default charset=utf8;

create table dev_commons.delivery_slots
(
site_id int(11) not null,
n_day int(1) not null,
start_hour int(2) not null,
start_min int(2) not null,
end_hour int(2) not null,
end_min int(2) not null,
create_by int(11) not null,
create_ts TIMESTAMP not null default CURRENT_TIMESTAMP,
primary key(site_id, n_day, start_hour, start_min, end_hour, end_min)
)Engine=myisam default charset=utf8;

alter table cart add delivery_date date;
alter table cart add delivery_start_hour int(2);
alter table cart add delivery_start_min int(2);
alter table cart add delivery_end_hour int(2);
alter table cart add delivery_end_min int(2);

