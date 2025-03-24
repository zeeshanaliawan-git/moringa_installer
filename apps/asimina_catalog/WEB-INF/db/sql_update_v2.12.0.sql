-- START 15-10-2021 --
update dev_commons.config set val = '2.12.0' where code = 'APP_VERSION';
update dev_commons.config set val = '2.12.0.1' where code = 'CSS_JS_VERSION';
-- END 15-10-2021 --

-- START 6-11-2021 --
update algolia_rules set rule_type = 'structuredpage' where rule_type = 'structuredcatalog';

insert into dev_commons.config (code, val) values ('PAGES_INDEXED_DATA_API','http://127.0.0.1/dev_pages/api/indexData.jsp');

update dev_commons.config set val ='/dev_prodshop/resetpass.jsp' where code ='DANDELION_PROD_FORGOT_PASS_URL';


create table dev_commons.currencies (
currency_code varchar(10) not null,
primary key (currency_code)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into dev_commons.currencies (currency_code) values ('SLL');
insert into dev_commons.currencies (currency_code) values ('LE');
insert into dev_commons.currencies (currency_code) values ('FRA');
insert into dev_commons.currencies (currency_code) values ('USD');
insert into dev_commons.currencies (currency_code) values ('EUR');
insert into dev_commons.currencies (currency_code) values ('XOF');
insert into dev_commons.currencies (currency_code) values ('XAF');
insert into dev_commons.currencies (currency_code) values ('BWP');
insert into dev_commons.currencies (currency_code) values ('PKR');

ALTER TABLE products_folders
ADD UNIQUE KEY uk_products_folders (site_id, catalog_id, name, parent_folder_id);

-- START 6-11-2021 --