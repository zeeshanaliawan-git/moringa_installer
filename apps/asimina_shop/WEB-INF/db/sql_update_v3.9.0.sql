alter table has_action modify action varchar(255);

alter table rules modify action varchar(255);


--------------Start Ahsan 15 Dec 2022 -------------------
CREATE TABLE login_v390 select * from login;
Alter table login add column is_two_auth_enabled tinyInt(1) default 0,add column send_email tinyInt(1) default 0, add column secret_key varchar(100);
ALTER TABLE login ENGINE=InnoDB;
alter table login ENCRYPTED=Yes;

INSERT into public_urls (url,url_type) values('/checkAuth.jsp','endsWith');


create table consolidated_stat_urls_before(
	date_l  date not null,
	page_c  varchar(255) not null,
	session_j  varchar(70) not null,
	site_id  int(10),
	index `idx`(page_c,date_l)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table consolidated_stat_urls_after(
	date_l  date not null,
	page_c  varchar(255) not null,
	session_j  varchar(70) not null,
	site_id  int(10),
	index `idx`(page_c,date_l)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table consolidated_stat_urls_all(
	date_l  date not null,
	page_c  varchar(255) not null,
	session_j  varchar(70) not null,
	site_id  int(10),
	index `idx`(page_c,date_l)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE dashboard_urls_v390 select * from dashboard_urls;
ALTER TABLE dashboard_urls ADD COLUMN `table_name` VARCHAR(50);
ALTER TABLE dashboard_urls DROP column compare_type;
--------------End Ahsan 15 Dec 2022 ----------------- 

alter table payments_ref add order_id int(11) default null;
alter table payments_ref add is_success tinyint(1) not null default 0;
alter table orders add payment_is_success tinyint(1) not null default 0 comment 'Client side payment flows like Group orange money and paypal insert order in db using initiatePayment flow. In these cases the value of this column must be set to true once payment is done as this flag is used in process flow';
insert into osql (id, nextOnErr, sqltext) values ('waitPayment30mins','1','select case when coalesce(payment_is_success,0) = 1 then 0 when adddate(tm, interval 30 minute) <= now() then 19 else 120005 end from orders where id = $clid');


alter table orders add additional_info mediumtext default null;
insert into config (code, val) values ("SHOP_APP_URL", "/dev_shop");

insert into config (code, val) values ('funnel_documents_base_url','/dev_shop/uploads/');

delete from field_names where  tab = 'Order Information' and section  = 'Product Info' and fieldName = 'total_price';
delete from field_settings where screenName = 'CUSTOMER_EDIT' and fieldName = 'total_price';

-- IMPORTANT : added by umair
-- v3.9 will have uploads folder in shop webapps also .. update the deployment script for it and also add uploads folder to client_files_sync script

