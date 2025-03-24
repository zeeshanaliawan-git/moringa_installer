update dev_commons.config set val = '4.6.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.6.0.1' where code = 'CSS_JS_VERSION';


alter table fraud_rules add cart_type enum ('topup','normal') not null default 'normal';
alter table fraud_rules_log add cart_type enum ('topup','normal') not null default 'normal';
alter table fraud_rules_log add ip varchar(255);

create table dev_commons.fraud_rules_columns (
name varchar(255) not null,
display_name varchar(255) not null,
primary key(name)
)Engine=myisam default charset=utf8;

insert into dev_commons.fraud_rules_columns (name, display_name) value ('identityId', 'Identity Id');
insert into dev_commons.fraud_rules_columns (name, display_name) value ('email', 'Email');
insert into dev_commons.fraud_rules_columns (name, display_name) value ('ip', 'IP Address');
insert into dev_commons.fraud_rules_columns (name, display_name) value ('contactPhoneNumber1', 'Contact number');


alter table shop_parameters add topup_max_amount double;
alter table shop_parameters add card2wallet_max_amount double;


alter table algolia_settings add test_application_id varchar(255);
alter table algolia_settings add test_search_api_key varchar(255);
alter table algolia_settings add test_write_api_key varchar(255);



CREATE TABLE dev_commons.api_action_logs (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wkid` int(11) DEFAULT NULL,
  `clid` varchar(100) DEFAULT NULL,
  `appl_name` varchar(255) DEFAULT NULL,
  `procedure_name` varchar(255) DEFAULT NULL,
  `api_url` varchar(500) DEFAULT NULL,
  `request_method` varchar(10) DEFAULT NULL,
  `request_body` mediumtext DEFAULT NULL,
  `api_response` mediumtext DEFAULT NULL,
  `http_code` varchar(10) not null default 0,
  `api_env` enum('prod','test') DEFAULT NULL,
  `response_time` varchar(75) DEFAULT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  `cart_id` varchar(255) default null,
  `msg` text default null,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


update dev_commons.config set val = concat(val,',Partoo,ImportExport') where code = 'OBSERVER_ENGINES';

