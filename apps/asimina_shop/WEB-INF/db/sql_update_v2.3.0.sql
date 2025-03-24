-- START 13-07-2020 --
CREATE TABLE `usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_agent` text,
  `details` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


alter table login add access_time datetime;
alter table login add access_id varchar(50);

CREATE TABLE `login_tries` (
  `ip` varchar(15) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attempt` int(10) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8; 
-- END 13-07-2020 --

-- START 15-07-2020 --
insert into config (code,val) values ('SMTP_DEBUG','true');
-- END 15-07-2020 --


-- START 16-07-2020 --
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('VARIANT_IMAGES_URL', 'https://testportail.app/dev_shop/variant_images/', 'for emails');

DROP VIEW IF EXISTS customer;
CREATE VIEW `customer` AS select `orders`.`id` AS `customerid`,`orders`.`id` AS `orderid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode`,`orders`.`menu_uuid` AS `menu_uuid`,`orders`.`currency` AS `currency`,`orders`.`ip` AS `ip`,`orders`.`spaymentmean` AS `spaymentmean`,`orders`.`shipping_method_id` AS `shipping_method_id`,`orders`.`payment_ref_id` AS `payment_ref_id`,`orders`.`payment_id` AS `payment_id`,`orders`.`payment_token` AS `payment_token`,`orders`.`payment_url` AS `payment_url`,`orders`.`payment_notif_token` AS `payment_notif_token`,`orders`.`payment_status` AS `payment_status`,`orders`.`payment_txn_id` AS `payment_txn_id`,`orders`.`lastid` AS `lastid`,`orders`.`payment_fees` AS `payment_fees`,`orders`.`delivery_fees` AS `delivery_fees`,`orders`.`orderType` AS `orderType`,`orders`.`transaction_code` AS `transaction_code`,`orders`.`tracking_number` AS `tracking_number`,`orders`.`promo_code` AS `promo_code`,`orders`.`courier_name` AS `courier_name`,`orders`.`identityPhoto` AS `identityPhoto`,`orders`.`newPhoneNumber` AS `newPhoneNumber`,`orders`.`selected_boutique` AS `selected_boutique`,`orders`.`rdv_boutique` AS `rdv_boutique`,`orders`.`rdv_date` AS `rdv_date`,`orders`.`delivery_type` AS `delivery_type`,`orders`.`site_id` AS `site_id`,`orders`.`country` AS `country`,`orders`.`newsletter` AS `newsletter`,`orders`.`comments` AS `comments` from `orders`;
-- END 16-07-2020 --

-- START 17-07-2020 --
create table field_names_v2_2 as select * from field_names;
truncate field_names;

insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','delivery_type','Delivery Type','0','Delivery Address','5','','6','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','rdv_boutique','Appointment','0','Delivery Address','5','select ''false'', ''No'' from dual union select ''true'', ''Yes'' from dual;','7','','Customer Information','1','','orders','select');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','rdv_date','Appointment Time','0','Delivery Address','5','','8','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','tracking_number','Tracking Number','0','Tracking Info','4','','2','','Order Information','2','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','total_price','Price','1','Product Info','3','','3','','Order Information','2','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','courier_name','Courier Name','0','Tracking Info','4','','1','','Order Information','2','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','email','Email','0','Contact Info','3','','2','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','contactPhoneNumber1','Telephone','0','Contact Info','3','','1','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','country','Country','0','Billing Address','4','','5','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','batowncity','Town/City','0','Billing Address','4','','4','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','bapostalCode','Postal Code','0','Billing Address','4','','3','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','baline2','Address Line 2','0','Billing Address','4','','2','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','baline1','Address Line 1','0','Billing Address','4','','1','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','surnames','Surname','0','Client Data','2','','4','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','name','First Name','0','Client Data','2','','3','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','orderRef','Order Ref #','1','Customer Info','1','','2','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','insertionDate','Phase Date','1','Customer Info','1','','3','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','phase','Phase','1','Customer Info','1','','1','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','creationDate','Order Date','1','Customer Info','1','','4','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','orderId','Order Id','1','Customer Info','1','','5','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','newPhoneNumber','NumÃ©ro Orange','0','Contact Info','3','','4','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','supplier_id','Supplier','0','Supplier Detail','1','SELECT id, supplier FROM supplier GROUP BY 1, 2;','1','','Supplier Detail','5','','order_items','select');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','supplier','Supplier','1','Supplier Detail','1','','2','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','category','Category','1','Supplier Detail','1','','3','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','address','Address','1','Supplier Detail','1','','4','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','supplier_email','Email','1','Supplier Detail','1','','5','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','phone_number','Phone','1','Supplier Detail','1','','6','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','supplier_detail','Supplier Details','1','Supplier Detail','1','','7','','Supplier Detail','5','','supplier','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','identityPhoto','Identity Photo','0','Client Data','2','','7','','Customer Information','1','','orders','image');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','salutation','Civility','0','Client Data','2','','1','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','IdentityType','Identity Type','0','Client Data','2','','5','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','identityId','Identity ID','0','Client Data','2','','6','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','newsletter','Newsletter','0','Contact Info','3','select 1, ''Yes'' from dual union select 0, ''No'' from dual;','3','','Customer Information','1','','orders','select');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','daline1','Address Line 1','0','Delivery Address','5','','3','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','daline2','Address Line 2','0','Delivery Address','5','','4','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','dapostalCode','Postal Code','0','Delivery Address','5','','5','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','datowncity','Town/City','0','Delivery Address','5','','1','','Customer Information','1','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','shipping_method_id','Delivery Mode','0','Delivery Address','5','select method, displayName from GlobalParm_CATALOG_DB.delivery_methods where site_id=Orders_SITE_ID group by method;','2','','Customer Information','1','','orders','select');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','spaymentmean','Payment Method','0','Payment Info','2','select method, displayName from GlobalParm_CATALOG_DB.payment_methods where site_id=Orders_SITE_ID;','1','','Order Information','2','','orders','select');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','transaction_code','Transaction Code','0','Payment Info','2','','2','','Order Information','2','','orders','text');
insert into field_names (screenName,fieldName,displayName,isLabel,section,sectionDisplaySeq,query,fieldDisplaySeq,fieldType,tab,tabDisplaySeq,tabId,tableName,input_type) values ('CUSTOMER_EDIT','promo_code','Promo Code','0','Payment Info','2','','3','','Order Information','2','','orders','text');


DELETE FROM `config` WHERE (`code`='VARIANT_IMAGE_UPLOAD_DIRECTORY');
INSERT INTO config (`code`, `val`, `comments`) VALUES ('VARIANT_IMAGE_UPLOAD_DIRECTORY', '/home/ronaldo/tomcat/webapps/dev_shop/variant_images/', 'for shop');

-- END 17-07-2020 --

-- START 20-07-2020 --
alter table order_items add promotion text ;
-- END 20-07-2020 --

-- START 21-07-2020 --
insert into config (code, val) values ('CART_URL','/dev_portal/cart/');

drop table language;
drop table langue_msg;

-- translations main table is in _catalog so we will create view from there in prod as well
create view language as select * from dev_catalog.language;
create view langue_msg as select * from dev_catalog.langue_msg;

-- END 21-07-2020 --

-- START 06-08-2020 -- 
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('PRODUCTS_IMG_PATH', '/dev_catalog/uploads/products/', NULL);
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('PRODUCTS_UPLOAD_DIRECTORY', '/home/etn/tomcat/webapps/dev_catalog/uploads/products/', NULL);
-- END 06-08-2020 --

-- START 09-08-2020 -- 
INSERT INTO `config` (`code`, `val`, `comments`) VALUES ('STOCK_ALERT_MAIL_ID', '', NULL);
delete from config where code = 'STOCK_MAIL_REPOSITORY';

--not required where services are not used
delete from page where name = 'Calendar';
--not required as we are not supporting these forms anymore
delete from page where name = 'Generic form to Process mapping';
delete from page where name = 'Generic forms field settings';
update page set name = 'Field Settings' where name = 'Orders form field settings';
--not required where services are not used
delete from page where name = 'Service Colors';

CREATE TABLE `page_sub_urls` (
  `url` varchar(150) NOT NULL DEFAULT '',
  `sub_url` varchar(150) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

update page set url = concat('/dev_shop/',url) where url not like '/%' and url not like 'http%';

update page_profil set url = concat('/dev_shop/',url) where url not like '/%' and url not like 'http%';

-- END 09-08-2020 -- 

-- START 04-09-2020 --

update field_names set query='select method, displayName from GlobalParm_CATALOG_DB.delivery_methods where enable=1 and site_id=Orders_SITE_ID group by method;' where fieldName='shipping_method_id';

update field_names set query='select method, displayName from GlobalParm_CATALOG_DB.payment_methods where enable=1 and site_id=Orders_SITE_ID;' where fieldName='spaymentmean';

CREATE TABLE `store_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(500) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `city` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 04-09-2020 --

-- START 07-09-2020 --
INSERT INTO `page` (`name`, `url`, `parent`, `rang`, `new_tab`, `icon`, `parent_icon`) VALUES ('Store emails management', '/dev_shop/admin/storeEmailsManagement.jsp', 'Admin', '3', '0', 'cui-wrench', 'cui-settings');
-- END 07-09-2020 --



-- START 25-09-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_API_MSISDN', '67685696');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USERNAME', 'PLATEFORMESHOP');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_PASSWORD', 'Orange@13');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_URL', 'https://testom.orange.bf:9008/payment');
-- START 25-09-2020 --