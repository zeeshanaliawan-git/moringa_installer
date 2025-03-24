use dev_portal;

CREATE TABLE sites_config (
site_id int(11) not null,
code varchar(100) NOT NULL,
val mediumtext DEFAULT NULL,
comments mediumtext DEFAULT NULL,
PRIMARY KEY (site_id,code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;

-- we must insert the orange api and paypal related vals into sites_config table as these are site based
create table config_v44 as select * from config;

insert into sites_config (site_id, code, val, comments) select distinct s.id, c.code, c.val, c.comments from sites s, config c where s.enable_ecommerce=1 and c.code like 'orange_%';
insert into sites_config (site_id, code, val, comments) select distinct s.id, c.code, c.val, c.comments from sites s, config c where s.enable_ecommerce=1 and c.code like 'paypal_%';

insert into sites_config (site_id, code, val, comments) select distinct s.id, c.code, c.val, c.comments from sites s, dev_shop.config c where s.enable_ecommerce=1 and c.code like 'paypal_%';

delete from dev_shop.config where code like 'paypal_%';

delete from sites_config where code = 'orange_access_expire_ts';
delete from sites_config where code = 'orange_access_token';


CREATE TABLE `idnow_sessions` (
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `cart_id` int(11) NOT NULL,
  `idnow_uid` varchar(36) NOT NULL,
  `resp` mediumtext DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `resp_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `un_key` (`cart_id`,`idnow_uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table cart add column idnow_uuid varchar(36);

alter table idcheck_configurations add column bloc_uuid varchar(100) DEFAULT NULL;


