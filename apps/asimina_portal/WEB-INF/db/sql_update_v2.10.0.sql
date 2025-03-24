update config set val = '/cart/personalinfo.jsp' where val = '/cart/payment.jsp' and code = 'CHECKOUT_JSP';
update config set val = 'cart/payment.jsp' where val = '/cart/recap.jsp' and code = 'payment_return_jsp';

alter table cart add promo_code varchar(255);

alter table cart add session_token varchar(50);

alter table cart add session_access_time datetime not null default now();

insert into dev_commons.config(code, val, comments) values ("SHOP_SESSION_TIMEOUT_MINS", "180", "Session time out in minutes used for client login and cart timeouts");

CREATE TABLE web_sessions (
  id varchar(50) NOT NULL,
  access_time timestamp not null default CURRENT_TIMESTAMP,
  params varchar(2000),
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table stat_log add browser_session_id varchar(70);
