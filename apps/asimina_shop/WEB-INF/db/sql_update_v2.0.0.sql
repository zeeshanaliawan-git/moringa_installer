CREATE TABLE `temporary_cart_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) DEFAULT NULL,
  `product_id` varchar(50) DEFAULT NULL,
  `qty` int(11) DEFAULT NULL,
  `tm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attributes` text,
  `start_time` int(11) DEFAULT NULL,
  `date` varchar(10) DEFAULT NULL,
  `business_type` varchar(25) DEFAULT NULL,
  `installment_plan` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE customer;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_uuid` varchar(50) NOT NULL,
  `identityId` varchar(12) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `surnames` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `contactPhoneNumber1` varchar(10) CHARACTER SET utf8 NOT NULL,
  `nationality` varchar(30) CHARACTER SET utf8 DEFAULT NULL,
  `email` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  `IdentityType` varchar(25) CHARACTER SET utf8 DEFAULT NULL,
  `total_price` varchar(32) CHARACTER SET utf8 DEFAULT NULL,
  `tm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `baline1` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  `baline2` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  `batowncity` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  `bapostalCode` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `salutation` char(4) CHARACTER SET utf8 DEFAULT '',
  `infoSup1` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `creationDate` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `order_items` (
`customerid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `orderid` varchar(32) NOT NULL DEFAULT '',
  `orderType` varchar(32) DEFAULT NULL,
  `orderStatus` enum('IN PROGRESS','CLOSED','CANCELLED','HISTORY','INITIALISED','IN ORDER','SUSPENDED','REMOVED','ABORTED') DEFAULT NULL,
  `price` varchar(32) DEFAULT NULL,
  `product_name` varchar(128) NOT NULL,
  `product_type` varchar(32) NOT NULL,
  `quantity` int(11) NOT NULL,
  `parent_id` varchar(50) NOT NULL,
  `spaymentmean` char(16) NOT NULL,
  `lastid` int(10) unsigned DEFAULT '0',
  `comments` text,
  `updatedBy` varchar(50) DEFAULT NULL,
  `updatedDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `shipping_method_id` varchar(8) DEFAULT NULL,
  `product_ref` varchar(50) DEFAULT NULL,
  `installment_duration_unit` varchar(32) DEFAULT NULL,
  `installment_duration` varchar(32) DEFAULT NULL,
  `installment_price` varchar(32) DEFAULT NULL,
  `installment_recurring_price` varchar(32) DEFAULT NULL,
  `business_type` varchar(25) DEFAULT NULL,
  `installment_plan` varchar(25) DEFAULT NULL,
  `attributes` text,
  `service_start_time` int(11) DEFAULT NULL,
  `service_date` varchar(10) DEFAULT NULL,
  `product_snapshot` text,
  `service_duration` int(11) DEFAULT NULL,
  `service_end_date` varchar(10) DEFAULT NULL,
  `tracking_number` varchar(50) DEFAULT NULL,
  `courier_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`customerid`),
  UNIQUE KEY `oid` (`orderid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


ALTER TABLE `post_work`
MODIFY COLUMN `status`  int(1) NOT NULL DEFAULT 0 COMMENT 'running action status ; 0 - init ; 1 : pris en running ; 2 : end' AFTER `instance_agent`;

ALTER TABLE `orders`
ADD COLUMN `orderRef`  varchar(25) NULL AFTER `creationDate`;

drop view if exists customer;

CREATE VIEW `customer` AS select `orders`.`id` AS `id`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`order_items`.`customerid` AS `customerid`,`order_items`.`orderid` AS `orderid`,`order_items`.`orderType` AS `orderType`,`order_items`.`orderStatus` AS `orderStatus`,`order_items`.`price` AS `price`,`order_items`.`product_name` AS `product_name`,`order_items`.`product_type` AS `product_type`,`order_items`.`quantity` AS `quantity`,`order_items`.`spaymentmean` AS `spaymentmean`,`order_items`.`lastid` AS `lastid`,`order_items`.`comments` AS `comments`,`order_items`.`updatedBy` AS `updatedBy`,`order_items`.`updatedDate` AS `updatedDate`,`order_items`.`shipping_method_id` AS `shipping_method_id`,`order_items`.`product_ref` AS `product_ref`,`order_items`.`installment_duration_unit` AS `installment_duration_unit`,`order_items`.`installment_duration` AS `installment_duration`,`order_items`.`installment_price` AS `installment_price`,`order_items`.`installment_recurring_price` AS `installment_recurring_price`,`order_items`.`business_type` AS `business_type`,`order_items`.`installment_plan` AS `installment_plan`,`order_items`.`attributes` AS `attributes`,`order_items`.`service_start_time` AS `service_start_time`,`order_items`.`service_date` AS `service_date`,`order_items`.`product_snapshot` AS `product_snapshot`,`order_items`.`service_duration` AS `service_duration`,`order_items`.`service_end_date` AS `service_end_date`,`order_items`.`tracking_number` AS `tracking_number`,`order_items`.`courier_name` AS `courier_name`,`order_items`.`parent_id` AS `parent_id`, `order_items`.`resources` from (`orders` join `order_items` on((`orders`.`parent_uuid` = `order_items`.`parent_id`)));


CREATE TABLE `generic_forms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_name` text,
  `form_data` mediumtext,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT NULL,
  `muid` varchar(50) DEFAULT NULL,
  `f_email` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table post_work add is_generic_form tinyint(1) not null default 0;


 CREATE TABLE `generic_forms_process_mapping` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_name` varchar(255) DEFAULT NULL,
  `process` text,
  `phase` text,
  PRIMARY KEY (`id`),
  KEY `form_name` (`form_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;




-- for ui ---
alter table page add new_tab tinyint(1) default 0;
delete from profil where profil_id;
insert into profil (profil_id, profil, description) values (1, 'ADMIN','Administrator');
insert into profil (profil_id, profil, description) values (2, 'basic_user','Basic User');

insert into page_profil values ('/',1);

delete from page;
insert into page (name, url, parent, rang) values ('Orders','ibo.jsp','',0);
insert into page (name, url, parent, rang) values ('Requests','ibo2.jsp','',1);
insert into page (name, url, parent, rang) values ('Processes','viewProcess.jsp','',2);

insert into page (name, url, parent, rang) values ('Orders form field settings','admin/fieldSettings.jsp','Admin',3);
insert into page (name, url, parent, rang) values ('Generic forms field settings','admin/genericFieldSettings.jsp','Admin',3);
insert into page (name, url, parent, rang) values ('Generic form to Process mapping','admin/genericFormMapping.jsp','Admin',3);
insert into page (name, url, parent, rang) values ('User management','admin/userManagement.jsp','Admin',3);
insert into page (name, url, parent, rang) values ('Profile management','admin/manageProfil.jsp','Admin',3);

-- before running following scripts better to compare ids in following tables ... we are just leaving user admin and deleting rest
-- 2 was admin before, now we set its profil_id = 1
delete from profilperson where person_id <> 2;
update profilperson set profil_id = 1;

delete from login where pid <> 2;
delete from person where person_id <> 2;

drop table orders;
drop table order_items;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_uuid` varchar(50) NOT NULL,
  `identityId` varchar(12) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `surnames` varchar(100) DEFAULT NULL,
  `contactPhoneNumber1` varchar(10) NOT NULL,
  `nationality` varchar(30) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `IdentityType` varchar(25) DEFAULT NULL,
  `total_price` varchar(32) DEFAULT NULL,
  `tm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `baline1` varchar(128) DEFAULT NULL,
  `baline2` varchar(128) DEFAULT NULL,
  `batowncity` varchar(64) DEFAULT NULL,
  `bapostalCode` varchar(5) DEFAULT NULL,
  `salutation` char(4) DEFAULT '',
  `infoSup1` varchar(100) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `creationDate` datetime NOT NULL,
  `orderRef` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `order_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `orderType` varchar(32) DEFAULT NULL,
  `orderStatus` enum('IN PROGRESS','CLOSED','CANCELLED','HISTORY','INITIALISED','IN ORDER','SUSPENDED','REMOVED','ABORTED') DEFAULT NULL,
  `price` varchar(32) DEFAULT NULL,
  `product_name` varchar(128) NOT NULL,
  `product_type` varchar(32) NOT NULL,
  `quantity` int(11) NOT NULL,
  `parent_id` varchar(50) NOT NULL,
  `spaymentmean` char(16) NOT NULL,
  `comments` text,
  `updatedBy` varchar(50) DEFAULT NULL,
  `updatedDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `product_ref` varchar(50) DEFAULT NULL,
  `installment_duration_unit` varchar(32) DEFAULT NULL,
  `installment_duration` varchar(32) DEFAULT NULL,
  `installment_price` varchar(32) DEFAULT NULL,
  `installment_recurring_price` varchar(32) DEFAULT NULL,
  `business_type` varchar(25) DEFAULT NULL,
  `installment_plan` varchar(25) DEFAULT NULL,
  `attributes` text,
  `service_start_time` int(11) DEFAULT NULL,
  `service_date` varchar(10) DEFAULT NULL,
  `product_snapshot` text,
  `service_duration` int(11) DEFAULT NULL,
  `service_end_date` varchar(10) DEFAULT NULL,
  `tracking_number` varchar(50) DEFAULT NULL,
  `courier_name` varchar(50) DEFAULT NULL,
  `lastid` int(11) DEFAULT NULL,
  `shipping_method_id` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

drop view if exists customer;

CREATE
VIEW `customer` AS
SELECT
orders.parent_uuid,
orders.identityId,
orders.`name`,
orders.surnames,
orders.contactPhoneNumber1,
orders.nationality,
orders.email,
orders.IdentityType,
orders.total_price,
orders.tm,
orders.baline1,
orders.baline2,
orders.batowncity,
orders.bapostalCode,
orders.salutation,
orders.infoSup1,
orders.client_id,
orders.creationDate,
orders.orderRef,
order_items.id AS customerid,
order_items.orderType,
order_items.orderStatus,
order_items.price,
order_items.product_name,
order_items.product_type,
order_items.quantity,
order_items.parent_id,
order_items.spaymentmean,
order_items.comments,
order_items.updatedBy,
order_items.updatedDate,
order_items.product_ref,
order_items.installment_duration_unit,
order_items.installment_duration,
order_items.installment_price,
order_items.installment_recurring_price,
order_items.business_type,
order_items.installment_plan,
order_items.attributes,
order_items.service_start_time,
order_items.service_date,
order_items.product_snapshot,
order_items.service_duration,
order_items.service_end_date,
order_items.tracking_number,
order_items.courier_name,
order_items.lastid,
order_items.shipping_method_id,
order_items.id AS orderid
FROM
orders
Inner Join order_items ON orders.parent_uuid = order_items.parent_id ;


alter table generic_forms add lastId int(10) unsigned;
alter table generic_forms add comments text;

drop table rlock;
CREATE TABLE `rlock` (
  `id` int(10) unsigned NOT NULL,
  `is_generic_form` tinyint(1) not null default 0,
  `csr` varchar(50) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`, is_generic_form)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


delete from actions where name = 'mes';
delete from actions where name = 'crm';
delete from actions where name = 'BdcrWS';

alter table generic_forms change f_email email varchar(255) ;

-- Abdul Rehman 07-06-2017 --start
ALTER TABLE order_items ADD COLUMN resources text DEFAULT NULL;
-- Abdul Rehman 07-06-2017 --end


 CREATE TABLE `osql` (
  `id` varchar(16) NOT NULL,
  `nextOnErr` char(1) default NULL,
  `throwErr` char(1) default NULL,
  `sqltext` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;

insert into osql  (id, nextOnErr, sqltext) values ('processNow','1','select 0');
insert into osql (id,nextOnErr,sqltext) values ('waitProcessNow','1','select case when flag > 0 then 0 else 120000 end from post_work where id =  $wkid');

CREATE TABLE `mails` (
  `sujet` varchar(128) NOT NULL,
  `id` int(10) unsigned NOT NULL auto_increment,
  `de` varchar(128) default NULL,
  `type` varchar(256) default NULL,
  `attachs` text,
  `seq` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ;



CREATE TABLE `mail_config` (
  `id` int(10) unsigned NOT NULL,
  `ordertype` varchar(24) NOT NULL,
  `email_to` mediumtext,
  `where_clause` mediumtext,
  `attach` varchar(255) default NULL,
  PRIMARY KEY  (`id`,`ordertype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


insert into page (name,url,parent,rang) values ('Mail/SMS','mail_sms/modele.jsp','Admin',3);


drop view if exists customer;

CREATE
VIEW `customer` AS
SELECT
order_items.id AS customerid,
orders.parent_uuid,
orders.identityId,
orders.`name`,
orders.surnames,
orders.contactPhoneNumber1,
orders.nationality,
orders.email,
orders.IdentityType,
orders.total_price,
orders.tm,
orders.baline1,
orders.baline2,
orders.batowncity,
orders.bapostalCode,
orders.salutation,
orders.infoSup1,
orders.client_id,
orders.creationDate,
orders.orderRef,
order_items.orderType,
order_items.orderStatus,
order_items.price,
order_items.product_name,
order_items.product_type,
order_items.quantity,
order_items.parent_id,
order_items.spaymentmean,
order_items.comments,
order_items.updatedBy,
order_items.updatedDate,
order_items.product_ref,
order_items.installment_duration_unit,
order_items.installment_duration,
order_items.installment_price,
order_items.installment_recurring_price,
order_items.business_type,
order_items.installment_plan,
order_items.attributes,
order_items.service_start_time,
order_items.service_date,
order_items.product_snapshot,
order_items.service_duration,
order_items.service_end_date,
order_items.tracking_number,
order_items.courier_name,
order_items.lastid,
order_items.shipping_method_id,
order_items.id AS orderid,
order_items.resources as resources
FROM
orders
Inner Join order_items ON orders.parent_uuid = order_items.parent_id ;

CREATE TABLE IF NOT EXISTS `resources`;
CREATE TABLE `resources` (
  `name` varchar(50) NOT NULL,
  `phone_no` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO page (name, url, parent, rang, new_tab) VALUES ('Calendar','customCalendar.jsp','','4','0');
INSERT INTO page (name, url, parent, rang, new_tab) VALUES ('Resource','admin/resource.jsp','Admin','5','0');


ALTER TABLE `order_items`
ADD COLUMN `service_gap`  int(11) NULL DEFAULT NULL AFTER `resources`;

ALTER TABLE `orders`
ADD COLUMN `lang`  varchar(2) NULL AFTER `orderRef`;

ALTER TABLE `order_items`
ADD COLUMN `catalog_name`  varchar(255) NULL AFTER `product_type`;

alter table order_items change resources resource varchar(255) DEFAULT NULL;

alter table order_items add secondary_resource varchar(255) default null;

drop view if exists customer;

CREATE
VIEW `customer` AS
SELECT
order_items.id AS customerid,
orders.parent_uuid,
orders.identityId,
orders.`name`,
orders.surnames,
orders.contactPhoneNumber1,
orders.nationality,
orders.email,
orders.IdentityType,
orders.total_price,
orders.tm,
orders.baline1,
orders.baline2,
orders.batowncity,
orders.bapostalCode,
orders.salutation,
orders.infoSup1,
orders.client_id,
orders.creationDate,
orders.orderRef,
order_items.orderType,
order_items.orderStatus,
order_items.price,
order_items.product_name,
order_items.product_type,
order_items.quantity,
order_items.parent_id,
order_items.spaymentmean,
order_items.comments,
order_items.updatedBy,
order_items.updatedDate,
order_items.product_ref,
order_items.installment_duration_unit,
order_items.installment_duration,
order_items.installment_price,
order_items.installment_recurring_price,
order_items.business_type,
order_items.installment_plan,
order_items.attributes,
order_items.service_start_time,
order_items.service_date,
order_items.product_snapshot,
order_items.service_duration,
order_items.service_end_date,
order_items.tracking_number,
order_items.courier_name,
order_items.lastid,
order_items.shipping_method_id,
order_items.id AS orderid,
order_items.service_gap as service_gap,
order_items.resource as resource,
order_items.secondary_resource as secondary_resource
FROM
orders
Inner Join order_items ON orders.parent_uuid = order_items.parent_id ;


drop table resources;

delete from page where name = 'Resource';

alter table clients add first_time_pass varchar(15);

 alter table osql change id id varchar(30);

alter table order_items add actual_amount_collected varchar(32);

drop view if exists customer;

CREATE
VIEW `customer` AS
SELECT
order_items.id AS customerid,
orders.parent_uuid,
orders.identityId,
orders.`name`,
orders.surnames,
orders.contactPhoneNumber1,
orders.nationality,
orders.email,
orders.IdentityType,
orders.total_price,
orders.tm,
orders.baline1,
orders.baline2,
orders.batowncity,
orders.bapostalCode,
orders.salutation,
orders.infoSup1,
orders.client_id,
orders.creationDate,
orders.orderRef,
order_items.orderType,
order_items.orderStatus,
order_items.price,
order_items.product_name,
order_items.product_type,
order_items.quantity,
order_items.parent_id,
order_items.spaymentmean,
order_items.comments,
order_items.updatedBy,
order_items.updatedDate,
order_items.product_ref,
order_items.installment_duration_unit,
order_items.installment_duration,
order_items.installment_price,
order_items.installment_recurring_price,
order_items.business_type,
order_items.installment_plan,
order_items.attributes,
order_items.service_start_time,
order_items.service_date,
order_items.product_snapshot,
order_items.service_duration,
order_items.service_end_date,
order_items.tracking_number,
order_items.courier_name,
order_items.lastid,
order_items.shipping_method_id,
order_items.id AS orderid,
order_items.service_gap as service_gap,
order_items.resource as resource,
order_items.secondary_resource as secondary_resource,
order_items.actual_amount_collected as actual_amount_collected
FROM
orders
Inner Join order_items ON orders.parent_uuid = order_items.parent_id ;



drop table language;
CREATE TABLE `language` (
  `langue_id` int(1) unsigned NOT NULL AUTO_INCREMENT,
  `langue` varchar(32) NOT NULL DEFAULT '',
  `langue_code` varchar(2) DEFAULT NULL,
  `og_local` varchar(10) DEFAULT NULL,
  `direction` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into language (langue, langue_code, og_local) values ('French','fr','fr_FR');
insert into language (langue, langue_code, og_local) values ('English','en','en_EN');
insert into language (langue, langue_code, og_local) values ('Spanish','es','es_ES');
insert into language (langue, langue_code, og_local) values ('Catalan','ca','ca_CA');


alter table mails add sujet_lang_2 varchar(255);
alter table mails add sujet_lang_3 varchar(255);
alter table mails add sujet_lang_4 varchar(255);
alter table mails add sujet_lang_5 varchar(255);

alter table generic_forms add lang varchar(5);


ALTER TABLE `phases`
ADD COLUMN `color`  varchar(7) NULL DEFAULT '#000000' AFTER `orderTrackVisible`;

ALTER TABLE `field_names`
ADD COLUMN `query`  text NULL AFTER `sectionDisplaySeq`,
ADD COLUMN `fieldDisplaySeq`  int NOT NULL DEFAULT 0 AFTER `query`,
ADD COLUMN `fieldType`  varchar(25) NULL AFTER `fieldDisplaySeq`,
ADD COLUMN `tab`  varchar(50) NOT NULL AFTER `fieldType`,
ADD COLUMN `tabDisplaySeq`  int(11) NOT NULL AFTER `tab`;

ALTER TABLE `field_names`
ADD COLUMN `tabId`  varchar(25) NOT NULL AFTER `tabDisplaySeq`;

ALTER TABLE `field_names`
ADD COLUMN `tableName`  varchar(25) NULL AFTER `tabId`;


ALTER TABLE `order_items` ADD COLUMN `supplier_id` int DEFAULT NULL;
ALTER TABLE `field_names` ADD COLUMN `input_type` VARCHAR(50) DEFAULT NULL;
DROP VIEW IF EXISTS customer;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customer` AS select `order_items`.`id` AS `customerid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`order_items`.`orderType` AS `orderType`,`order_items`.`orderStatus` AS `orderStatus`,`order_items`.`price` AS `price`,`order_items`.`product_name` AS `product_name`,`order_items`.`product_type` AS `product_type`,`order_items`.`quantity` AS `quantity`,`order_items`.`parent_id` AS `parent_id`,`order_items`.`spaymentmean` AS `spaymentmean`,`order_items`.`comments` AS `comments`,`order_items`.`updatedBy` AS `updatedBy`,`order_items`.`updatedDate` AS `updatedDate`,`order_items`.`product_ref` AS `product_ref`,`order_items`.`installment_duration_unit` AS `installment_duration_unit`,`order_items`.`installment_duration` AS `installment_duration`,`order_items`.`installment_price` AS `installment_price`,`order_items`.`installment_recurring_price` AS `installment_recurring_price`,`order_items`.`business_type` AS `business_type`,`order_items`.`installment_plan` AS `installment_plan`,`order_items`.`attributes` AS `attributes`,`order_items`.`service_start_time` AS `service_start_time`,`order_items`.`service_date` AS `service_date`,`order_items`.`product_snapshot` AS `product_snapshot`,`order_items`.`service_duration` AS `service_duration`,`order_items`.`service_end_date` AS `service_end_date`,`order_items`.`tracking_number` AS `tracking_number`,`order_items`.`courier_name` AS `courier_name`,`order_items`.`lastid` AS `lastid`,`order_items`.`shipping_method_id` AS `shipping_method_id`,`order_items`.`id` AS `orderid`,`order_items`.`service_gap` AS `service_gap`,`order_items`.`resource` AS `resource`,`order_items`.`secondary_resource` AS `secondary_resource`,`order_items`.`actual_amount_collected` AS `actual_amount_collected`, `order_items`.`supplier_id` AS `supplier_id` from (`orders` join `order_items` on((`orders`.`parent_uuid` = `order_items`.`parent_id`)));


TRUNCATE field_names;
INSERT INTO `field_names` VALUES ('502', 'CUSTOMER_EDIT', 'secondary_resource', 'Secondary Resource', '0', 'Order Info', '6', 'select service_resources as secondary_resources from GlobalParm_CATALOG_DB.products p left outer join GlobalParm_CATALOG_DB.product_stocks ps on ps.product_id = p.id left outer join GlobalParm_CATALOG_DB.product_link pl on pl.id = p.link_id where p.product_uuid = $product_ref$;', '2', null, 'Order Information', '2', '', 'order_items', 'select');
INSERT INTO `field_names` VALUES ('501', 'CUSTOMER_EDIT', 'resource', 'Resource', '0', 'Order Info', '6', 'select case when coalesce(p.link_id,\'\') <> \'\' then pl.resources else ps.resources end as resources from GlobalParm_CATALOG_DB.products p left outer join GlobalParm_CATALOG_DB.product_stocks ps on ps.product_id = p.id left outer join GlobalParm_CATALOG_DB.product_link pl on pl.id = p.link_id where p.product_uuid = $product_ref$;', '1', null, 'Order Information', '2', '', 'order_items', 'select');
INSERT INTO `field_names` VALUES ('500', 'CUSTOMER_EDIT', 'tracking_number', 'Tracking Number', '0', 'Tracking Info', '5', null, '2', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('498', 'CUSTOMER_EDIT', 'price', 'Price', '0', 'Product Info', '4', null, '3', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('499', 'CUSTOMER_EDIT', 'courier_name', 'Courier Name', '0', 'Tracking Info', '5', null, '1', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('497', 'CUSTOMER_EDIT', 'quantity', 'Quantity', '0', 'Product Info', '4', null, '2', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('496', 'CUSTOMER_EDIT', 'product_name', 'Product Name', '0', 'Product Info', '4', null, '1', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('495', 'CUSTOMER_EDIT', 'email', 'Email', '0', 'Contact Info', '3', null, '2', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('494', 'CUSTOMER_EDIT', 'contactPhoneNumber1', 'Phone', '0', 'Contact Info', '3', null, '1', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('493', 'CUSTOMER_EDIT', 'nationality', 'Country', '0', 'Billing Address', '2', null, '5', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('492', 'CUSTOMER_EDIT', 'batowncity', 'Town/City', '0', 'Billing Address', '2', null, '4', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('491', 'CUSTOMER_EDIT', 'bapostalCode', 'Postal Code', '0', 'Billing Address', '2', null, '3', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('490', 'CUSTOMER_EDIT', 'baline2', 'Address Line 2', '0', 'Billing Address', '2', null, '2', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('489', 'CUSTOMER_EDIT', 'baline1', 'Address Line 1', '0', 'Billing Address', '2', null, '1', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('488', 'CUSTOMER_EDIT', 'surnames', 'Surname', '0', 'Client Data', '1', null, '2', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('487', 'CUSTOMER_EDIT', 'name', 'Name', '0', 'Client Data', '1', null, '1', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('486', 'CUSTOMER_EDIT', 'orderRef', 'Order Ref #', '1', 'Customer Info', '1', null, '5', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('485', 'CUSTOMER_EDIT', 'insertionDate', 'Phase Date', '1', 'Customer Info', '1', null, '4', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('484', 'CUSTOMER_EDIT', 'phase', 'Phase', '1', 'Customer Info', '1', null, '3', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('483', 'CUSTOMER_EDIT', 'creationDate', 'Order Date', '1', 'Customer Info', '1', null, '2', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('482', 'CUSTOMER_EDIT', 'orderId', 'Order Id', '1', 'Customer Info', '1', null, '1', null, 'Customer Information', '1', '', 'orders', 'text');
INSERT INTO `field_names` VALUES ('503', 'CUSTOMER_EDIT', 'actual_amount_collected', 'Amount Collected', '0', 'Order Info', '6', null, '3', null, 'Order Information', '2', '', 'order_items', 'text');
INSERT INTO `field_names` VALUES ('504', 'CUSTOMER_EDIT', 'supplier_id', 'Supplier', '0', 'Supplier Detail', '1', 'SELECT id, supplier FROM supplier GROUP BY 1, 2;', '1', null, 'Supplier Detail', '5', '', 'order_items', 'select');
INSERT INTO `field_names` VALUES ('505', 'CUSTOMER_EDIT', 'supplier', 'Supplier', '1', 'Supplier Detail', '1', null, '2', null, 'Supplier Detail', '5', '', 'supplier', 'text');
INSERT INTO `field_names` VALUES ('506', 'CUSTOMER_EDIT', 'category', 'Category', '1', 'Supplier Detail', '1', null, '3', null, 'Supplier Detail', '5', '', 'supplier', 'text');
INSERT INTO `field_names` VALUES ('507', 'CUSTOMER_EDIT', 'address', 'Address', '1', 'Supplier Detail', '1', null, '4', null, 'Supplier Detail', '5', '', 'supplier', 'text');
INSERT INTO `field_names` VALUES ('508', 'CUSTOMER_EDIT', 'supplier_email', 'Email', '1', 'Supplier Detail', '1', null, '5', null, 'Supplier Detail', '5', '', 'supplier', 'text');
INSERT INTO `field_names` VALUES ('509', 'CUSTOMER_EDIT', 'phone_number', 'Phone', '1', 'Supplier Detail', '1', null, '6', null, 'Supplier Detail', '5', '', 'supplier', 'text');
INSERT INTO `field_names` VALUES ('510', 'CUSTOMER_EDIT', 'supplier_detail', 'Supplier Details', '1', 'Supplier Detail', '1', null, '7', null, 'Supplier Detail', '5', '', 'supplier', 'text');



DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier` (
  `id` int AUTO_INCREMENT,
  `supplier` VARCHAR(50) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `supplier_detail` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `page` VALUES ('Supplier', 'admin/supplier.jsp', 'Admin', 3, 0);


insert into page (name, url, parent, rang, new_tab) values ('Asimina','/dev_catalog/admin/gestion.jsp','',51, 1);

 alter table login change name name varchar(255);

-- START 30-11-2017 -- Asad
ALTER TABLE `orders`
MODIFY COLUMN `contactPhoneNumber1`  varchar(15) NOT NULL;
-- END 30-11-2017 --

-- START 14-12-2017 -- Asad
ALTER TABLE `orders`
ADD COLUMN `order_snapshot`  text NULL AFTER `lang`;

CREATE TABLE `client_profil` (
  `profil` varchar(50) NOT NULL,
  `discount_type` varchar(15) NOT NULL,
  `discount_value` decimal(10,0) NOT NULL DEFAULT '0',
  `catalog_id` int(11) NOT NULL DEFAULT '0',
  `product_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`profil`,`catalog_id`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 14-12-2017 --


-- START 27-12-2017 --
insert into page (name, url, parent, rang, new_tab) values ('Profils','/dev_shop/admin/profilManagement.jsp','Customers',52, 0);
insert into page (name, url, parent, rang, new_tab) values ('Customer Profils','/dev_shop/admin/clientManagement.jsp','Customers',53, 0);
-- END 27-12-2017 --


-- START 17-01-2018 -- Asad
ALTER TABLE `order_items`
ADD COLUMN `product_rating`  tinyint NULL AFTER `supplier_id`;
-- END 17-01-2018 --


-- START 24-01-2018 --
CREATE TABLE `config` (
  `code` varchar(100) DEFAULT NULL,
  `val` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into config (code, val) values ('app_version','1.2.5');
-- END 24-01-2018 --

-- START 29-01-2018 -- Asad
ALTER TABLE `order_items`
ADD COLUMN `complaint`  text NULL AFTER `product_rating`,
ADD COLUMN `complaint_response`  text NULL AFTER `complaint`;
-- END 29-01-2018 --

-- START 16-02-2018 -- Asad
ALTER TABLE `order_items`
ADD COLUMN `price_value`  varchar(32) NULL AFTER `complaint_response`,
ADD COLUMN `tax_percentage`  varchar(10) NULL AFTER `price_value`;

alter table config add primary key (code);
-- END 16-02-2018 -- Asad


-- START 14-03-2018 --
-- AliAdnan
DROP VIEW IF EXISTS customer;

CREATE VIEW  customer AS
select `order_items`.`id` AS `customerid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`order_items`.`orderType` AS `orderType`,`order_items`.`orderStatus` AS `orderStatus`,`order_items`.`price` AS `price`,`order_items`.`product_name` AS `product_name`,`order_items`.`product_type` AS `product_type`,`order_items`.`quantity` AS `quantity`,`order_items`.`parent_id` AS `parent_id`,`order_items`.`spaymentmean` AS `spaymentmean`,`order_items`.`comments` AS `comments`,`order_items`.`updatedBy` AS `updatedBy`,`order_items`.`updatedDate` AS `updatedDate`,`order_items`.`product_ref` AS `product_ref`,`order_items`.`installment_duration_unit` AS `installment_duration_unit`,`order_items`.`installment_duration` AS `installment_duration`,`order_items`.`installment_price` AS `installment_price`,`order_items`.`installment_recurring_price` AS `installment_recurring_price`,`order_items`.`business_type` AS `business_type`,`order_items`.`installment_plan` AS `installment_plan`,`order_items`.`attributes` AS `attributes`,`order_items`.`service_start_time` AS `service_start_time`,`order_items`.`service_date` AS `service_date`,`order_items`.`product_snapshot` AS `product_snapshot`,`order_items`.`service_duration` AS `service_duration`,`order_items`.`service_end_date` AS `service_end_date`,`order_items`.`tracking_number` AS `tracking_number`,`order_items`.`courier_name` AS `courier_name`,`order_items`.`lastid` AS `lastid`,`order_items`.`shipping_method_id` AS `shipping_method_id`,`order_items`.`id` AS `orderid`,`order_items`.`service_gap` AS `service_gap`,`order_items`.`resource` AS `resource`,`order_items`.`secondary_resource` AS `secondary_resource`,`order_items`.`actual_amount_collected` AS `actual_amount_collected`,`order_items`.`supplier_id` AS `supplier_id`,`order_items`.`price_value` AS `price_value`,`order_items`.`tax_percentage` AS `tax_percentage` from (`orders` join `order_items` on((`orders`.`parent_uuid` = `order_items`.`parent_id`)));

-- END 14-03-2018 --



-- START 12-04-2018 --

ALTER TABLE `order_items`
MODIFY COLUMN `shipping_method_id`  varchar(25) NULL DEFAULT NULL AFTER `lastid`,
MODIFY COLUMN `spaymentmean`  varchar(20) NOT NULL AFTER `parent_id`;

-- END 12-04-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 13-APR-2018 ----------------------------------

-- START 22-05-2018 --

ALTER TABLE `orders`
ADD COLUMN `daline1`  varchar(128) NULL DEFAULT NULL AFTER `order_snapshot`,
ADD COLUMN `daline2`  varchar(128) NULL DEFAULT NULL AFTER `daline1`,
ADD COLUMN `datowncity`  varchar(64) NULL DEFAULT NULL AFTER `daline2`,
ADD COLUMN `dapostalCode`  varchar(5) NULL DEFAULT NULL AFTER `datowncity`;

DROP VIEW IF EXISTS customer;

CREATE VIEW `customer` AS select `order_items`.`id` AS `customerid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`order_items`.`orderType` AS `orderType`,`order_items`.`orderStatus` AS `orderStatus`,`order_items`.`price` AS `price`,`order_items`.`product_name` AS `product_name`,`order_items`.`product_type` AS `product_type`,`order_items`.`quantity` AS `quantity`,`order_items`.`parent_id` AS `parent_id`,`order_items`.`spaymentmean` AS `spaymentmean`,`order_items`.`comments` AS `comments`,`order_items`.`updatedBy` AS `updatedBy`,`order_items`.`updatedDate` AS `updatedDate`,`order_items`.`product_ref` AS `product_ref`,`order_items`.`installment_duration_unit` AS `installment_duration_unit`,`order_items`.`installment_duration` AS `installment_duration`,`order_items`.`installment_price` AS `installment_price`,`order_items`.`installment_recurring_price` AS `installment_recurring_price`,`order_items`.`business_type` AS `business_type`,`order_items`.`installment_plan` AS `installment_plan`,`order_items`.`attributes` AS `attributes`,`order_items`.`service_start_time` AS `service_start_time`,`order_items`.`service_date` AS `service_date`,`order_items`.`product_snapshot` AS `product_snapshot`,`order_items`.`service_duration` AS `service_duration`,`order_items`.`service_end_date` AS `service_end_date`,`order_items`.`tracking_number` AS `tracking_number`,`order_items`.`courier_name` AS `courier_name`,`order_items`.`lastid` AS `lastid`,`order_items`.`shipping_method_id` AS `shipping_method_id`,`order_items`.`id` AS `orderid`,`order_items`.`service_gap` AS `service_gap`,`order_items`.`resource` AS `resource`,`order_items`.`secondary_resource` AS `secondary_resource`,`order_items`.`actual_amount_collected` AS `actual_amount_collected`,`order_items`.`supplier_id` AS `supplier_id`,`order_items`.`price_value` AS `price_value`,`order_items`.`tax_percentage` AS `tax_percentage`,`order_items`.`catalog_name` AS `catalog_name`,`order_items`.`product_rating` AS `product_rating`,`order_items`.`complaint` AS `complaint`,`order_items`.`complaint_response` AS `complaint_response`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode` from (`orders` join `order_items` on((`orders`.`parent_uuid` = `order_items`.`parent_id`)));


-- END 22-05-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 24-MAY-2018 ----------------------------------

-- START 30-05-2018 --

update config set val = '1.3' where code = 'app_version';

-- END 30-05-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 30-MAY-2018 ----------------------------------

-- START 16-07-2018 --

INSERT INTO `page` (`name`, `url`, `parent`, `rang`) VALUES ('Order Tracking Visible', '/dev_shop/admin/orderTrackingVisible.jsp', 'Admin', '3');

ALTER TABLE `phases`
ADD COLUMN `displayName1`  varchar(100) NULL AFTER `color`;

-- END 16-07-2018 --

-- START 24-07-2018 --

ALTER TABLE `orders`
ADD COLUMN `menu_uuid`  varchar(50) NULL AFTER `dapostalCode`;

-- END 24-07-2018 --

-- START 31-07-2018 --

ALTER TABLE `order_items`
ADD COLUMN `transaction_code`  varchar(25) NULL DEFAULT NULL AFTER `tax_percentage`;

-- END 31-07-2018 --

-- START 03-08-2018 --

ALTER TABLE `order_items`
ADD COLUMN `brand_name`  varchar(100) NULL AFTER `transaction_code`;

-- END 03-08-2018 --

-- START 06-08-2018 --

ALTER TABLE `orders`
ADD COLUMN `currency`  varchar(25) NULL AFTER `menu_uuid`;

-- END 06-08-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 07-AUG-2018 ----------------------------------

-- START 09-08-2018 --
alter table login add sso_id varchar(36) default null;
-- END 09-08-2018 --

-- START 10-08-2018 --
ALTER TABLE `order_items`
ADD COLUMN `product_full_name`  varchar(255) NULL AFTER `brand_name`;
ALTER TABLE `orders`
ADD COLUMN `ip`  varchar(15) NULL AFTER `currency`;
-- END 10-08-2018 --

---------------------------------------- TEMPLATE UPDATED TILL HERE 17-AUG-2018 ----------------------------------


-- START 29-08-2018

ALTER TABLE `orders`
ADD COLUMN `spaymentmean`  varchar(20) NOT NULL AFTER `ip`,
ADD COLUMN `shipping_method_id`  varchar(25) NULL DEFAULT NULL AFTER `spaymentmean`;

ALTER TABLE `order_items`
DROP COLUMN `spaymentmean`,
DROP COLUMN `shipping_method_id`;

-- END 29-08-2018

-- START 08-10-2018 --

DROP VIEW IF EXISTS customer;

CREATE VIEW `customer` AS select `order_items`.`id` AS `customerid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`order_items`.`orderType` AS `orderType`,`order_items`.`orderStatus` AS `orderStatus`,`order_items`.`price` AS `price`,`order_items`.`product_name` AS `product_name`,`order_items`.`product_type` AS `product_type`,`order_items`.`quantity` AS `quantity`,`order_items`.`parent_id` AS `parent_id`,`order_items`.`comments` AS `comments`,`order_items`.`updatedBy` AS `updatedBy`,`order_items`.`updatedDate` AS `updatedDate`,`order_items`.`product_ref` AS `product_ref`,`order_items`.`installment_duration_unit` AS `installment_duration_unit`,`order_items`.`installment_duration` AS `installment_duration`,`order_items`.`installment_price` AS `installment_price`,`order_items`.`installment_recurring_price` AS `installment_recurring_price`,`order_items`.`business_type` AS `business_type`,`order_items`.`installment_plan` AS `installment_plan`,`order_items`.`attributes` AS `attributes`,`order_items`.`service_start_time` AS `service_start_time`,`order_items`.`service_date` AS `service_date`,`order_items`.`product_snapshot` AS `product_snapshot`,`order_items`.`service_duration` AS `service_duration`,`order_items`.`service_end_date` AS `service_end_date`,`order_items`.`tracking_number` AS `tracking_number`,`order_items`.`courier_name` AS `courier_name`,`order_items`.`lastid` AS `lastid`,`order_items`.`id` AS `orderid`,`order_items`.`service_gap` AS `service_gap`,`order_items`.`resource` AS `resource`,`order_items`.`secondary_resource` AS `secondary_resource`,`order_items`.`actual_amount_collected` AS `actual_amount_collected`,`order_items`.`supplier_id` AS `supplier_id`,`order_items`.`price_value` AS `price_value`,`order_items`.`tax_percentage` AS `tax_percentage`,`order_items`.`catalog_name` AS `catalog_name`,`order_items`.`product_rating` AS `product_rating`,`order_items`.`complaint` AS `complaint`,`order_items`.`complaint_response` AS `complaint_response`,`order_items`.`transaction_code` AS `transaction_code`,`order_items`.`brand_name` AS `brand_name`,`order_items`.`product_full_name` AS `product_full_name`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode`,`orders`.`spaymentmean` AS `spaymentmean`,`orders`.`shipping_method_id` AS `shipping_method_id` from (`orders` join `order_items` on((`orders`.`parent_uuid` = `order_items`.`parent_id`)));

-- END 08-10-2018 --

-- START 09-10-2018 --

ALTER TABLE `order_items`
ADD COLUMN `advance_duration`  varchar(32) NULL DEFAULT NULL AFTER `product_full_name`,
ADD COLUMN `advance_amount`  varchar(32) NULL DEFAULT NULL AFTER `advance_duration`;

-- END 09-10-2018 --

-- START 18-10-2018 --
update config set val = '1.4' where code = 'app_version';
-- END 18-10-2018 --

--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- senegal updated till here on 19 OCT 2018 ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

-- START 24-10-2018 --
CREATE TABLE `payments_ref` (
  `id` varchar(50) NOT NULL,
  `menu_uuid` varchar(50) NOT NULL DEFAULT '',
  `payment_method` varchar(50) NOT NULL DEFAULT '',
  `delivery_method` varchar(50) NOT NULL DEFAULT '',
  `store` varchar(50) NOT NULL DEFAULT '',
  `host_url` varchar(1000) NOT NULL DEFAULT '',
  `total_price` varchar(50) NOT NULL DEFAULT '',
  `payment_id` varchar(100) NOT NULL DEFAULT '',
  `payment_token` varchar(1000) NOT NULL DEFAULT '',
  `payment_url` varchar(1000) NOT NULL DEFAULT '',
  `payment_notif_token` varchar(1000) NOT NULL DEFAULT '',
  `payment_status` varchar(100) NOT NULL DEFAULT '',
  `payment_txn_id` varchar(1000) NOT NULL DEFAULT '',
  `created_ts` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `orders`
ADD COLUMN `payment_ref_id` varchar(50) NOT NULL DEFAULT '' AFTER shipping_method_id,
ADD COLUMN `payment_id` varchar(100) NOT NULL DEFAULT '' AFTER payment_ref_id,
ADD COLUMN `payment_token` varchar(1000) NOT NULL DEFAULT '' AFTER payment_id,
ADD COLUMN `payment_url` varchar(1000) NOT NULL DEFAULT '' AFTER payment_token,
ADD COLUMN `payment_notif_token` varchar(1000) NOT NULL DEFAULT '' AFTER payment_url,
ADD COLUMN `payment_status` varchar(100) NOT NULL DEFAULT '' AFTER payment_notif_token,
ADD COLUMN `payment_txn_id` varchar(1000) NOT NULL DEFAULT '' AFTER payment_status;

-- END 24-10-2018 --

-- START 06-11-2018 --

ALTER TABLE `order_items`
ADD COLUMN `price_old_value`  varchar(32) NULL DEFAULT NULL AFTER `advance_amount`,
ADD COLUMN `installment_old_recurring_price`  varchar(32) NULL DEFAULT NULL AFTER `price_old_value`,
ADD COLUMN `installment_discount_duration`  int(11) NULL AFTER `installment_old_recurring_price`;

ALTER TABLE `orders`
ADD COLUMN `lastid`  int(11) NULL DEFAULT NULL AFTER `payment_txn_id`,
ADD COLUMN `payment_fees`  varchar(32) NULL DEFAULT NULL AFTER `lastid`,
ADD COLUMN `delivery_fees`  varchar(32) NULL DEFAULT NULL AFTER `payment_fees`;

DROP VIEW IF EXISTS customer;

CREATE VIEW `customer` AS select `orders`.`id` AS `customerid`,`orders`.`id` AS `orderid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode`,`orders`.`menu_uuid` AS `menu_uuid`,`orders`.`currency` AS `currency`,`orders`.`ip` AS `ip`,`orders`.`spaymentmean` AS `spaymentmean`,`orders`.`shipping_method_id` AS `shipping_method_id`,`orders`.`payment_ref_id` AS `payment_ref_id`,`orders`.`payment_id` AS `payment_id`,`orders`.`payment_token` AS `payment_token`,`orders`.`payment_url` AS `payment_url`,`orders`.`payment_notif_token` AS `payment_notif_token`,`orders`.`payment_status` AS `payment_status`,`orders`.`payment_txn_id` AS `payment_txn_id`,`orders`.`lastid` AS `lastid` from `orders`;

-- END 06-11-2018 --

-- START 03-12-2018 --

ALTER TABLE `orders`
ADD COLUMN `orderType`  varchar(32) NULL AFTER `delivery_fees`;

ALTER TABLE `order_items`
DROP COLUMN `orderType`;

DROP VIEW IF EXISTS customer;

CREATE VIEW `customer` AS select `orders`.`id` AS `customerid`,`orders`.`id` AS `orderid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`IdentityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode`,`orders`.`menu_uuid` AS `menu_uuid`,`orders`.`currency` AS `currency`,`orders`.`ip` AS `ip`,`orders`.`spaymentmean` AS `spaymentmean`,`orders`.`shipping_method_id` AS `shipping_method_id`,`orders`.`payment_ref_id` AS `payment_ref_id`,`orders`.`payment_id` AS `payment_id`,`orders`.`payment_token` AS `payment_token`,`orders`.`payment_url` AS `payment_url`,`orders`.`payment_notif_token` AS `payment_notif_token`,`orders`.`payment_status` AS `payment_status`,`orders`.`payment_txn_id` AS `payment_txn_id`,`orders`.`lastid` AS `lastid`,`orders`.`payment_fees` AS `payment_fees`,`orders`.`delivery_fees` AS `delivery_fees`,`orders`.`orderType` AS `orderType` from `orders`;

-- END 03-12-2018 --

-- START 11-01-2019 --
CREATE TABLE `stock_mail` (
  `product_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  `attribute_values` varchar(200) NOT NULL,
  `is_stock_alert` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`,`email`,`attribute_values`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `page` (`name`, `url`, `parent`, `rang`) VALUES ('Service Colors', 'admin/serviceColors.jsp', 'Admin', '3');
-- END 11-01-2019 --

-- START 18-01-2019 --
delete from config where code = 'app_version';
-- END 18-01-2019 --

-- START 11-02-2019 --
UPDATE `page` SET `name`='View Process', `parent`='Processes' WHERE (`url`='viewProcess.jsp');
INSERT INTO `page` (`name`, `url`, `parent`, `rang`) VALUES ('Edit Process', 'processStatus.jsp', 'Processes', '2');
INSERT INTO `page` (`name`, `url`, `rang`) VALUES ('Dashboard', 'ibo.jsp?', '5');
INSERT INTO `page` (`name`, `url`, `parent`, `rang`) VALUES ('Notifications', 'mail_sms/modele.jsp', 'Admin', '3');
-- END 11-02-2019 --

-- START 14-03-2019 --

ALTER TABLE `page`
ADD COLUMN `icon`  varchar(20) NULL DEFAULT NULL AFTER `new_tab`,
ADD COLUMN `parent_icon`  varchar(20) NULL AFTER `icon`;

-- END 14-03-2019 --

-- START 30-04-2019 --

CREATE TABLE payment_log (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  payment_ref_id varchar(50) NOT NULL,
  payment_method varchar(50) NOT NULL,
  action varchar(500) NOT NULL,
  url varchar(1000) NOT NULL,
  request text NOT NULL,
  response text NOT NULL,
  created_ts datetime NOT NULL,
  created_by int(11) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 30-04-2019 --

-- START 16-05-2019 -- 

ALTER TABLE `order_items`
DROP COLUMN `tracking_number`,
DROP COLUMN `courier_name`,
DROP COLUMN `promo_code`,
DROP COLUMN `transaction_code`;

ALTER TABLE `orders`
ADD COLUMN `transaction_code`  varchar(25) NULL DEFAULT NULL AFTER `orderType`,
ADD COLUMN `promo_code`  varchar(50) NULL DEFAULT NULL AFTER `transaction_code`,
ADD COLUMN `tracking_number`  varchar(50) NULL DEFAULT NULL AFTER `promo_code`,
ADD COLUMN `courier_name`  varchar(50) NULL DEFAULT NULL AFTER `tracking_number`;

-- END 16-05-2019 -- 

-- START 23-09-2019 --

ALTER TABLE `stock_mail`
CHANGE COLUMN `attribute_values` `variant_id`  int(11) NOT NULL,
DROP PRIMARY KEY,
ADD PRIMARY KEY (`product_id`, `email`, `variant_id`);

-- END 23-09-2019 --



-- START 07-10-2019 --
alter table dev_shop.config add unique key (code);
alter table dev_shop.config add comments text;

insert into dev_shop.config(code,val) values ('UPLOAD_FOLDER','/home/ronaldo/tomcat/webapps/dev_shop/WEB-INF/upload_file');
insert into dev_shop.config(code,val) values ('EXEC_FOLDER','/home/ronaldo/tomcat/webapps/dev_shop/WEB-INF/classes');
insert into dev_shop.config(code,val) values ('basic_auth_realm','dev-shop');
insert into dev_shop.config(code,val) values ('APP_NAME','Dev shop');
insert into dev_shop.config(code,val) values ('CATALOG_DB','dev_catalog');
insert into dev_shop.config(code,val) values ('MAIL_UPLOAD_PATH','/home/ronaldo/tomcat/webapps/dev_shop/mail_sms/mail/');
insert into dev_shop.config(code,val) values ('CATALOG_URL','/dev_catalog/');
insert into dev_shop.config(code,val) values ('SEMAPHORE','D005');
insert into dev_shop.config(code,val) values ('PORTAL_DB','dev_portal');
insert into dev_shop.config(code,val) values ('EXTERNAL_PORTAL_LINK','/dev_portal/');
insert into dev_shop.config(code,val) values ('COOKIE_PREFIX','dev_catalog');
insert into dev_shop.config(code,val) values ('ABSENCE_PRODUCT_NAME','Absence Product');
insert into dev_shop.config(code,val) values ('IS_PROD_SHOP','0');
insert into dev_shop.config(code,val) values ('COMMONS_DB','dev_commons'); 


alter table dev_prod_shop.config add unique key (code);
alter table dev_prod_shop.config add comments text;

insert into dev_prod_shop.config(code,val) values ('UPLOAD_FOLDER','/home/ronaldo/tomcat/webapps/dev_prodshop/WEB-INF/upload_file');
insert into dev_prod_shop.config(code,val) values ('EXEC_FOLDER','/home/ronaldo/tomcat/webapps/dev_prodshop/WEB-INF/classes');
insert into dev_prod_shop.config(code,val) values ('basic_auth_realm','dev-prod-shop');
insert into dev_prod_shop.config(code,val) values ('APP_NAME','Dev Prod Shop');
insert into dev_prod_shop.config(code,val) values ('CATALOG_DB','dev_prod_catalog');
insert into dev_prod_shop.config(code,val) values ('MAIL_UPLOAD_PATH','/home/ronaldo/tomcat/webapps/dev_prodshop/mail_sms/mail/');
insert into dev_prod_shop.config(code,val) values ('CATALOG_URL','/dev_prodcatalog/');
insert into dev_prod_shop.config(code,val) values ('SEMAPHORE','D006');
insert into dev_prod_shop.config(code,val) values ('PORTAL_DB','dev_prod_portal');
insert into dev_prod_shop.config(code,val) values ('EXTERNAL_PORTAL_LINK','/dev_prodportal/');
insert into dev_prod_shop.config(code,val) values ('COOKIE_PREFIX','dev_prodcatalog');
insert into dev_prod_shop.config(code,val) values ('ABSENCE_PRODUCT_NAME','Absence Product');
insert into dev_prod_shop.config(code,val) values ('IS_PROD_SHOP','1');
insert into dev_prod_shop.config(code,val) values ('COMMONS_DB','dev_commons'); 


-- END 07-10-2019 --
