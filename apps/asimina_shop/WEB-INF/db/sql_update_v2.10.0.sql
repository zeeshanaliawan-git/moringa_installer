alter table payments_ref add cart_id int(11) not null;
alter table payments_ref add paypal_order_id varchar(255);

-- set appropriate value in production
insert into config (code, val) values ('paypal_order_confirmation_url','https://api-m.sandbox.paypal.com/v2/checkout/orders/');

insert into actions (name, className) values ("payment","Payment");
--- start 30-8-2021 ---
CREATE TABLE user_block_config (
  type enum('user','ip') NOT NULL,
  number_of_tries varchar(50) NOT NULL DEFAULT '3',
  block_time varchar(50) NOT NULL DEFAULT '15',
  block_time_unit enum('minutes','hours','days','weeks') NOT NULL DEFAULT 'minutes'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO user_block_config VALUES("user","3","15","minutes");
INSERT INTO user_block_config VALUES("ip","3","15","minutes");

CREATE TABLE user_login_tries (
  username varchar(50) NOT NULL,
  tm timestamp NOT NULL DEFAULT current_timestamp(),
  attempt int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (username)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into page VALUES("Accounts Blocking","/dev_shop/admin/blockedUserConfig.jsp", "Admin",3,0,"cui-wrench","cui-settings");
--- end 30-8-2021 ---