-- START 21-07-2020 --
insert into config (code, val) values ('CART_URL','/dev_portal/cart/');
-- END 21-07-2020 --

-- START 07-09-2020 --
INSERT INTO `page` (`name`, `url`, `parent`, `rang`, `new_tab`, `icon`, `parent_icon`) VALUES ('Store emails management', '/dev_shop/admin/storeEmailsManagement.jsp', 'Admin', '3', '0', 'cui-wrench', 'cui-settings');
-- END 07-09-2020 --

-- START 25-09-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_API_MSISDN', '67685696');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USERNAME', 'PLATEFORMESHOP');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_PASSWORD', 'Orange@13');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_URL', 'https://testom.orange.bf:9008/payment');
-- START 25-09-2020 --

-- START 09-10-2020 --
INSERT INTO dev_commons.`config` (`code`, `val`) VALUES ('IBO_EXPORT_JSP', 'defaultexport.jsp')
-- END 09-10-2020 --

-- START 09-10-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('IBO_JSP', 'defaultibo.jsp');

delete from dev_commons.`config` where code = 'IBO_EXPORT_JSP';

INSERT INTO `config` (`code`, `val`) VALUES ('IBO_EXPORT_JSP', 'defaultexport.jsp');

-- END 09-10-2020 --