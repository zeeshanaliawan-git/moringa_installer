alter table web_sessions add index idx_date (access_time);

create table dev_commons.cors_whitelist (
w_domain varchar(255) not null,
primary key (w_domain)
)engine=myisam default charset=utf8;

-- by default we keep it false till we add all domains to whitelist
insert into dev_commons.config (code,val) value ('STRICT_CORS','0');

--dev_portal only
alter table cache_tasks add index idx1 (site_id, content_type);

--dev_prod_portal only
alter table publish_content add index idx1 (site_id, ctype, cid);     
alter table publish_content add index idx2 (status);

