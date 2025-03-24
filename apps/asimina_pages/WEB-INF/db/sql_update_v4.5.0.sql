create table products_view_bloc_data(
id int(11) not null auto_increment,
site_id int(11) not null,
page_id int(11) not null,
bloc_id int(11) not null,
langue_code varchar(5) not null,
for_prod_site tinyint(1) not null default 0,
view_query mediumtext not null,
created_ts TIMESTAMP not null default CURRENT_TIMESTAMP,
updated_ts datetime default null,
primary key (id),
unique key (site_id, page_id, bloc_id, langue_code, for_prod_site)
)engine=myisam default charset=utf8;

create table products_view_bloc_criteria(
data_id int(11) not null,
cid varchar(50) not null,
primary key(data_id, cid)
)engine=myisam default charset=utf8;

create table products_view_bloc_results(
data_id int(11) not null,
product_id int(11) not null,
primary key(data_id, product_id)
)engine=myisam default charset=utf8;

alter table blocs drop column nb_columns;


alter table bloc_templates_libraries add index idx_lib_id (library_id);
alter table page_templates_items add index idx_pti (page_template_id);
alter table structured_contents_tbl add index idx_site_id (site_id);
alter table structured_contents_published add index idx_site_id (site_id);
alter table media_records add index idx_file_id (file_id);