----------------------------------------Ahsan Start 14 April 2023----------------------------------------
		-------------Note: Need to add phase, process, site_id according to country
INSERT INTO dashboard_phases_config (site_id,ctype,process,PHASE) VALUES(1,'order-confirmed','DevOrder','orderConfirmed');
INSERT INTO dashboard_phases_config (site_id,ctype,process,PHASE) VALUES(1,'order-picked-for-delivery','DevOrder','orderPickedForDelivery');
INSERT INTO dashboard_phases_config (site_id,ctype,process,PHASE) VALUES(1,'order-delivered-to-home','DevOrder','orderDeliveredToHome');

ALTER TABLE consolidated_stat_urls_after ADD COLUMN eletype varchar(100) DEFAULT NULL, ADD COLUMN eleid int(11) DEFAULT NULL;
ALTER TABLE consolidated_stat_urls_before ADD COLUMN eletype varchar(100) DEFAULT NULL, ADD COLUMN eleid int(11) DEFAULT NULL;
ALTER TABLE consolidated_stat_urls_all ADD COLUMN eletype varchar(100) DEFAULT NULL, ADD COLUMN eleid int(11) DEFAULT NULL;

insert into page (name, url, rang,icon,menu_badge) values('Dashboard Filters','/dev_shop/dashboard/dashboardFiltersList.jsp',1,'cui-speedometer','NEW');
update page set menu_badge = '' where url='/dev_shop/admin/gestion.jsp';
update page set parent='Analytics', parent_icon='cui-speedometer' where url in ('/dev_shop/dashboard/dashboardFiltersList.jsp','/dev_shop/dashboard/dashboard.jsp');


CREATE TABLE dashboard_filters (
  id INT(11) AUTO_INCREMENT NOT NULL,
  filter_name VARCHAR(100) NOT NULL,
  site_id INT(11),
  created_on DATETIME DEFAULT CURRENT_TIMESTAMP(),
  created_by INT(11),
  updated_on DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  updated_by INT(11),
  PRIMARY KEY(id)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

CREATE TABLE dashboard_filters_items (
  id INT(11) AUTO_INCREMENT NOT NULL,
  filter_id VARCHAR(100) NOT NULL,
  filter_type VARCHAR(100) NOT NULL,
  filter_on TEXT,
  site_id INT(11),
  created_on DATETIME DEFAULT CURRENT_TIMESTAMP(),
  created_by INT(11),
  updated_on DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  updated_by INT(11),
  PRIMARY KEY(id),
  UNIQUE KEY uq_filters (filter_id,filter_type,filter_on)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

----------------------------------------Ahsan End 22 May 2023----------------------------------------

create table payment_actions
(
payment_method varchar(75) not null,
className varchar(255) not null,
primary key(payment_method)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into payment_actions (payment_method, className) value ('orange_money','com.etn.eshop.payment.GroupOrangeMoney');
insert into payment_actions (payment_method, className) value ('paypal','com.etn.eshop.payment.PayPal');

insert into payment_actions (payment_method, className) value ('cash_on_pickup','com.etn.eshop.payment.Cash');
insert into payment_actions (payment_method, className) value ('cash_on_delivery','com.etn.eshop.payment.Cash');

alter table orders add updated_ts datetime default null;
alter table payments_ref add updated_ts datetime default null;

CREATE TABLE payment_actions_logs (
id int(11) NOT NULL AUTO_INCREMENT,
wkid varchar(25) DEFAULT NULL,
clid varchar(25) DEFAULT NULL,
http_code varchar(25) DEFAULT NULL,
req text DEFAULT NULL,
resp text DEFAULT NULL,
payment_method varchar(255) not null,
action_type varchar(75) not null,
error_code varchar(10) default null,
error_msg text default null,
status enum('success','error') NOT NULL DEFAULT 'error',
created_on timestamp NOT NULL DEFAULT current_timestamp(),
PRIMARY KEY (id)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;
