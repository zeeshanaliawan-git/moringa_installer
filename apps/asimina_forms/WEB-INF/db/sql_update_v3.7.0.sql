-------------------- Mahin 12/10/2022 ----------------

CREATE TABLE `games_unpublished` (
	`nid` int(11) not null auto_increment,
	`id` VARCHAR(36) NOT NULL,
	`form_id` VARCHAR(36) NOT NULL,
	`name` VARCHAR(255) NOT NULL,
	`attempts_per_user` INT(12) NOT NULL,
	`launch_date` datetime default null,
	`end_date` datetime default null,
	`created_by` VARCHAR(36) NOT NULL,
	`updated_on` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`created_on` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	`updated_by` VARCHAR(36),
	`site_id` INT(11) NOT NULL,
	`to_publish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_publish_by` VARCHAR(36),
	`to_publish_ts` TIMESTAMP,
	`version` INT(10) NOT NULL DEFAULT '0',
	`to_unpublish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_unpublish_by` VARCHAR(36),
	`to_unpublish_ts` TIMESTAMP,
	`is_deleted` TINYINT(1) NOT NULL DEFAULT '0',
	`win_type` ENUM('Draw','Instant'),
	`can_lose` TINYINT(1) NOT NULL DEFAULT '1',
	PRIMARY KEY (`nid`),
	unique KEY (`id`),
	UNIQUE INDEX `uq_kys` (`form_id`, `name`, `site_id`, `is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `games` (
	`nid` int(11) not null auto_increment,
	`id` VARCHAR(36) NOT NULL,
	`form_id` VARCHAR(36) NOT NULL,
	`name` VARCHAR(255) NOT NULL,
	`attempts_per_user` INT(12) NOT NULL,
	`launch_date` datetime default null,
	`end_date` datetime default null,
	`created_by` VARCHAR(36) NOT NULL,
	`updated_on` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`created_on` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	`updated_by` VARCHAR(36),
	`site_id` INT(11) NOT NULL,
	`to_publish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_publish_by` VARCHAR(36),
	`to_publish_ts` TIMESTAMP,
	`version` INT(10) NOT NULL DEFAULT '0',
	`to_unpublish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_unpublish_by` VARCHAR(36),
	`to_unpublish_ts` TIMESTAMP,
	`is_deleted` TINYINT(1) NOT NULL DEFAULT '0',
	`win_type` ENUM('Draw','Instant'),
	`can_lose` TINYINT(1) NOT NULL DEFAULT '1',
	PRIMARY KEY (`nid`),
	unique KEY (`id`),
	UNIQUE INDEX `uq_kys` (`form_id`, `name`, `site_id`, `is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `game_prize` (
	`id` VARCHAR(36) NOT NULL,
	`game_uuid` VARCHAR(36) NOT NULL,
	`cart_rule_id` VARCHAR(36),
	`prize` VARCHAR(255),
	`created_by` VARCHAR(36) NOT NULL,
	`updated_on` TIMESTAMP ON UPDATE current_timestamp(),
	`created_on` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	`updated_by` VARCHAR(36),
	`to_publish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_publish_by` VARCHAR(36),
	`to_publish_ts` TIMESTAMP,
	`to_unpublish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_unpublish_by` VARCHAR(36),
	`to_unpublish_ts` TIMESTAMP,
	`type` ENUM('Coupon','Prize'),
	`quantity` INT(11),
	PRIMARY KEY (`id`),
	UNIQUE INDEX `uq_kys` (`game_uuid`, `cart_rule_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `game_prize_unpublished` (
	`id` VARCHAR(36) NOT NULL,
	`game_uuid` VARCHAR(36) NOT NULL,
	`cart_rule_id` VARCHAR(36),
	`prize` VARCHAR(255),
	`created_by` VARCHAR(36) NOT NULL,
	`updated_on` TIMESTAMP ON UPDATE current_timestamp(),
	`created_on` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	`updated_by` VARCHAR(36),
	`to_publish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_publish_by` VARCHAR(36),
	`to_publish_ts` TIMESTAMP,
	`to_unpublish` TINYINT(1) NOT NULL DEFAULT '0',
	`to_unpublish_by` VARCHAR(36),
	`to_unpublish_ts` TIMESTAMP,
	`type` ENUM('Coupon','Prize'),
	`quantity` INT(11),
	PRIMARY KEY (`id`),
	UNIQUE INDEX `uq_kys` (`game_uuid`, `cart_rule_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

----------------------------------------------------------------------------


CREATE TABLE `sms` (
  `sms_id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `where_clause` varchar(255) DEFAULT NULL,
  `texte` text DEFAULT NULL,
  `lang_2_texte` text DEFAULT NULL,
  `lang_3_texte` text DEFAULT NULL,
  `lang_4_texte` text DEFAULT NULL,
  `lang_5_texte` text DEFAULT NULL,
  PRIMARY KEY (`sms_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `sms_unpublished` (
  `sms_id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `where_clause` varchar(255) DEFAULT NULL,
  `texte` text DEFAULT NULL,
  `lang_2_texte` text DEFAULT NULL,
  `lang_3_texte` text DEFAULT NULL,
  `lang_4_texte` text DEFAULT NULL,
  `lang_5_texte` text DEFAULT NULL,
  PRIMARY KEY (`sms_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--------------- Mahin 14/10/2022 -----------------------------------


ALTER TABLE process_forms_unpublished_tbl 
ADD COLUMN  `is_sms` TINYINT(1) DEFAULT '0', ADD COLUMN `cust_sms_id` INT(11);

ALTER TABLE process_forms 
ADD COLUMN  `is_sms` TINYINT(1) DEFAULT '0', ADD COLUMN `cust_sms_id` INT(11);

DROP VIEW process_forms_unpublished;

CREATE VIEW process_forms_unpublished AS 
SELECT `process_forms_unpublished_tbl`.`form_id` AS `form_id`,`process_forms_unpublished_tbl`.`process_name` AS `process_name`,`process_forms_unpublished_tbl`.`table_name` AS `table_name`,`process_forms_unpublished_tbl`.`created_by` AS `created_by`,`process_forms_unpublished_tbl`.`created_on` AS `created_on`,`process_forms_unpublished_tbl`.`updated_on` AS `updated_on`,`process_forms_unpublished_tbl`.`updated_by` AS `updated_by`,`process_forms_unpublished_tbl`.`is_email_cust` AS `is_email_cust`,`process_forms_unpublished_tbl`.`is_email_bk_ofc` AS `is_email_bk_ofc`,`process_forms_unpublished_tbl`.`cust_eid` AS `cust_eid`,`process_forms_unpublished_tbl`.`bk_ofc_eid` AS `bk_ofc_eid`,`process_forms_unpublished_tbl`.`site_id` AS `site_id`,`process_forms_unpublished_tbl`.`variant` AS `variant`,`process_forms_unpublished_tbl`.`template` AS `template`,`process_forms_unpublished_tbl`.`meta_description` AS `meta_description`,`process_forms_unpublished_tbl`.`meta_keywords` AS `meta_keywords`,`process_forms_unpublished_tbl`.`form_class` AS `form_class`,`process_forms_unpublished_tbl`.`html_form_id` AS `html_form_id`,`process_forms_unpublished_tbl`.`form_method` AS `form_method`,`process_forms_unpublished_tbl`.`form_enctype` AS `form_enctype`,`process_forms_unpublished_tbl`.`form_autocomplete` AS `form_autocomplete`,`process_forms_unpublished_tbl`.`redirect_url` AS `redirect_url`,`process_forms_unpublished_tbl`.`btn_align` AS `btn_align`,`process_forms_unpublished_tbl`.`label_display` AS `label_display`,`process_forms_unpublished_tbl`.`form_width` AS `form_width`,`process_forms_unpublished_tbl`.`form_js` AS `form_js`,`process_forms_unpublished_tbl`.`type` AS `type`,`process_forms_unpublished_tbl`.`form_css` AS `form_css`,`process_forms_unpublished_tbl`.`to_publish` AS `to_publish`,`process_forms_unpublished_tbl`.`to_publish_by` AS `to_publish_by`,`process_forms_unpublished_tbl`.`to_publish_ts` AS `to_publish_ts`,`process_forms_unpublished_tbl`.`version` AS `version`,`process_forms_unpublished_tbl`.`to_unpublish` AS `to_unpublish`,`process_forms_unpublished_tbl`.`to_unpublish_by` AS `to_unpublish_by`,`process_forms_unpublished_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,`process_forms_unpublished_tbl`.`is_deleted` AS `is_deleted`,`process_forms_unpublished_tbl`.`is_sms` AS `is_sms`, `process_forms_unpublished_tbl`.`cust_sms_id` AS `cust_sms_id` 
FROM `process_forms_unpublished_tbl` 
WHERE `process_forms_unpublished_tbl`.`is_deleted` = 0;

-----------------------------------------------------------------------

insert into page (name, url, parent, rang, icon, parent_icon, menu_badge) values ('Game','/dev_forms/admin/games.jsp','Content','401','chevron-right','file-text','BETA');

-----------------------------------------------------------------------

alter table game_prize_unpublished drop index uq_kys;

alter table game_prize drop index uq_kys;

--------------------------------------------------------------------