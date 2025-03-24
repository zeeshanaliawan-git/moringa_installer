-- START ABJ 08-01-2020 --
alter table site_menus add column hide_top_nav TINYINT not null default '0';
alter table site_menus add column animate_on_scroll TINYINT not null default '1';
alter table site_menus add column default_size enum('small','large') not null default 'large';
-- END ABJ 08-01-2020 --

-- START Asad 30-01-2020 --
ALTER TABLE `client_profils`
ADD COLUMN `is_default`  tinyint(1) NULL AFTER `menu_id`;
-- END Asad 30-01-2020 --

-- START 12-02-2020 -- 
CREATE TABLE `client_prices` (
  `product_id` int(11) NOT NULL,
  `product_variant_id` int(11) unsigned NOT NULL,
  `client_id` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_variant_id`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 12-02-2020 --

-- START 18-02-2020 --

--following table is used for Site based Auth --
CREATE TABLE `client_sites` (
  `client_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`client_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table site_menus add logo_text varchar(255);
-- END 18-02-2020 --

-- START 20-02-2020 --
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('CART_URL', '/dev_portal/', NULL);

ALTER TABLE `clients`
ADD COLUMN `additional_info`  text NULL AFTER `client_profil_id`;

alter table site_menus add enable_breadcrumbs tinyint(1) not null default 1;

alter table clients add site_id int(11) not null;

alter table client_profils add site_id int(11) not null ;

-- run the update queries according to shop then drop the client_sites
-- update clients set site_id = '1';
drop table client_sites;

alter table clients drop key `email`;
alter table clients add unique key `uniq_client` (email, site_id);

-- START 20-02-2020

-- START 07-05-2020 --

CREATE TABLE `client_usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_agent` text,
  `details` varchar(255) DEFAULT NULL,
  `url` varchar(255) default null,
  `site_id` int(10),
   INDEX `activity_from` (`activity_from`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 07-05-2020 --