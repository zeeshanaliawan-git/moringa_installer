alter table orders add currency_code varchar(5) not null;

update orders o, dev_catalog.shop_parameters p set o.currency_code = p.lang_1_currency where o.site_id = p.site_id;

CREATE TABLE `dashboard_phases_config` (
  `site_id` int(11) NOT NULL,
  `ctype` varchar(50) not null,
  `process` varchar(75) NOT NULL,
  `phase` varchar(75) NOT NULL,
  PRIMARY KEY (`site_id`,`ctype`,`process`,`phase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into dashboard_phases_config (site_id, ctype, process, phase) select site_id, 'cancel', process, phase from dashboard_cancel_phases;

drop table dashboard_cancel_phases;

insert into dashboard_phases_config (site_id, ctype, process, phase) values (1, 'order-received', 'OBF', 'CommanceValidee');

--- we are not adding lang_1_texte because the column texte will be considered to be first lang texte ... otherwise some custom code can break if we change texte to lang_1_texte
alter table sms add lang_2_texte text;
alter table sms add lang_3_texte text;
alter table sms add lang_4_texte text;
alter table sms add lang_5_texte text;


