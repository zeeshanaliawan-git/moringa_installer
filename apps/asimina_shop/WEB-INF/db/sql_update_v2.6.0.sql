-- START 29-01-2021 --

ALTER TABLE `order_items` ADD INDEX `parent_id_index` (`parent_id`) ;

-- END 29-01-2021 --

-- START 09-02-2021 --

CREATE TABLE `dashboard_urls` (
  `url_type` varchar(20) DEFAULT '',
  `compare_type` varchar(20) DEFAULT '',
  `url` varchar(255) DEFAULT '',
  `url_group` varchar(20) DEFAULT '',
  `color` varchar(20) DEFAULT '',
  `sort_order` int(11) DEFAULT NULL,
  `label` varchar(20) DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `dashboard_urls` VALUES ('cart', 'contains', 'cart.jsp', 'funnel', '#67b7dc', '1', 'Basket');
INSERT INTO `dashboard_urls` VALUES ('funnel_step_1', 'contains', 'checkout.jsp', 'funnel', '#6771dc', '2', 'Customer detail');
INSERT INTO `dashboard_urls` VALUES ('funnel_step_2', 'contains', 'deliv.jsp', 'funnel', '#a367dc', '3', 'Delivery method');
INSERT INTO `dashboard_urls` VALUES ('funnel_step_2', 'contains', 'funnel_step_2.jsp', 'funnel', '#a367dc', '3', 'Delivery method');
INSERT INTO `dashboard_urls` VALUES ('funnel_step_3', 'contains', 'funnel_step_3.jsp', 'funnel', '#dc67ce', '4', 'Payment method');
INSERT INTO `dashboard_urls` VALUES ('funnel_step_3', 'contains', 'recap.jsp', 'funnel', '#dc67ce', '4', 'Payment method');
INSERT INTO `dashboard_urls` VALUES ('completion', 'contains', 'completion.jsp', 'funnel', '#dc6788', '5', 'Congrat');
-- INSERT INTO `dashboard_urls` VALUES ('eshop_visits', 'starting_from', 'https://www.orange.bf/fr/telephones-classiques/', null, null, null, null);
-- INSERT INTO `dashboard_urls` VALUES ('eshop_visits', 'starting_from', 'https://www.orange.bf/fr/catalogs/', null, null, null, null);
INSERT INTO `dashboard_urls` VALUES ('eshop_visits', 'contains', 'cart.jsp', '', '', null, '');

CREATE TABLE `dashboard_cancel_phases` (
  `site_id` int(11) NOT NULL,
  `process` varchar(16) NOT NULL,
  `phase` varchar(32) NOT NULL,
  PRIMARY KEY (`site_id`,`process`,`phase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- INSERT INTO `dashboard_cancel_phases` VALUES ('1', 'OBF', 'AnnulationTraitee');
-- INSERT INTO `dashboard_cancel_phases` VALUES ('1', 'OBF', 'RetractationTraitee');

-- END 09-02-2021 --

-- START 26-02-2021 -- 

UPDATE `page` SET `url`='/dev_shop/dashboard/dashboard.jsp' WHERE (`name`='Dashboard');
DELETE FROM page where name = 'Jeune Afrique';

-- END 26-02-2021 -- 
