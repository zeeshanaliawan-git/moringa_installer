-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_forms
-- ------------------------------------------------------
-- Server version	10.4.8-MariaDB-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `action_types`
--

DROP TABLE IF EXISTS `action_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `action_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_name` varchar(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_types`
--

LOCK TABLES `action_types` WRITE;
/*!40000 ALTER TABLE `action_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `action_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `name` varchar(25) NOT NULL,
  `paramTableName` varchar(50) DEFAULT NULL,
  `paramTableIdColumn` varchar(50) DEFAULT NULL,
  `className` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
INSERT INTO `actions` VALUES ('sql',NULL,NULL,'Sql'),('client',NULL,NULL,'AsiminaClient'),('checkAdmin',NULL,NULL,'CheckAdmin'),('checkAuto',NULL,NULL,'CheckAuto'),('forgotpassword',NULL,NULL,'AsiminaClientForgotPassword');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `check_rights`
--

DROP TABLE IF EXISTS `check_rights`;
/*!50001 DROP VIEW IF EXISTS `check_rights`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `check_rights` (
  `url` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) NOT NULL,
  `val` varchar(255) NOT NULL,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('BASE_DIR','/home/asimina/tomcat/webapps/asimina_forms/',NULL),('CATALOG_DB','cleandb_catalog',NULL),('CATALOG_URL','/asimina_catalog/',NULL),('COMMONS_DB','cleandb_commons',NULL),('DEBUG','Oui',''),('export_csv_dir','/home/asimina/tomcat/webapps/asimina_forms/admin/tmp/',NULL),('export_csv_url','/asimina_forms/admin/tmp/',NULL),('EXPORT_SCRIPT','/home/asimina/pjt/asimina_engines/forms/execdbscript.sh',NULL),('FORMS_WEB_APP','/asimina_forms/',NULL),('FORM_DB','cleandb_forms',NULL),('FORM_UPLOADS_PATH','/asimina_forms/uploads/',NULL),('FORM_UPLOADS_ROOT_PATH','/home/asimina/tomcat/webapps/asimina_forms/uploads/',NULL),('GOTO_FORMS_APP_URL','/asimina_catalog/admin/forms.jsp',NULL),('KEEP_FORMS_ATTACHMENT_MONTHS','3','Number of months data we want to keep for forms attachment'),('MAIL.SMTP.DEBUG','true',''),('MAIL_DEBUG','OUI',''),('MAIL_FROM','',''),('MAIL_FROM_DISPLAY_NAME','',''),('MAIL_REPLY','',''),('MAIL_REPOSITORY','/home/asimina/tomcat/webapps/asimina_forms/mail_sms/mail',''),('MAIL_UPLOAD_PATH','/home/asimina/tomcat/webapps/asimina_forms/mail_sms/mail/',NULL),('PAGES_URL','/asimina_pages/',NULL),('PORTAL_DB','cleandb_portal',NULL),('SEMAPHORE','D003',NULL),('SHELL_DIR','/home/asimina/pjt/asimina_engines/forms/bin',''),('SMTP_DEBUG','true',NULL),('UPLOADED_FILES_REPOSITORY','/home/asimina/tomcat/webapps/asimina_forms/uploads/',''),('UPLOAD_IMG_PATH','/home/asimina/tomcat/webapps/asimina_forms/uploads/images/',NULL),('WAIT_TIMEOUT','300',''),('WITH_MAIL','Oui','');
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coordinates`
--

DROP TABLE IF EXISTS `coordinates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coordinates` (
  `topLeftX` int(11) NOT NULL,
  `topLeftY` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `process` varchar(75) DEFAULT NULL,
  `profile` varchar(30) NOT NULL,
  `phase` varchar(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordinates`
--

LOCK TABLES `coordinates` WRITE;
/*!40000 ALTER TABLE `coordinates` DISABLE KEYS */;
/*!40000 ALTER TABLE `coordinates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipement`
--

DROP TABLE IF EXISTS `equipement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipement` (
  `equip_id` int(11) NOT NULL,
  `libelle` varchar(200) NOT NULL DEFAULT '""',
  `ordre` int(11) NOT NULL DEFAULT -1,
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index 2` (`equip_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipement`
--

LOCK TABLES `equipement` WRITE;
/*!40000 ALTER TABLE `equipement` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `errcode`
--

DROP TABLE IF EXISTS `errcode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `errcode` (
  `id` int(11) NOT NULL,
  `errMessage` varchar(78) NOT NULL,
  `errNom` varchar(255) NOT NULL,
  `errType` varchar(25) NOT NULL,
  `errCouleur` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `errcode`
--

LOCK TABLES `errcode` WRITE;
/*!40000 ALTER TABLE `errcode` DISABLE KEYS */;
INSERT INTO `errcode` VALUES (0,'','OK','success','#35f500'),(10,'','Success','success','#35f500'),(19,'','Error','error','#ff0000'),(20,'User is already exists','Error','error','#ff0000'),(30,'User created from orange authentication','Success','success','#35f500');
/*!40000 ALTER TABLE `errcode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_phases`
--

DROP TABLE IF EXISTS `external_phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_phases` (
  `start_proc` varchar(75) NOT NULL DEFAULT '',
  `next_proc` varchar(75) NOT NULL DEFAULT '',
  `next_phase` varchar(32) NOT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `topLeftX` int(11) DEFAULT NULL,
  `topLeftY` int(11) DEFAULT NULL,
  PRIMARY KEY (`start_proc`,`next_proc`,`next_phase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_phases`
--

LOCK TABLES `external_phases` WRITE;
/*!40000 ALTER TABLE `external_phases` DISABLE KEYS */;
/*!40000 ALTER TABLE `external_phases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_result_fields`
--

DROP TABLE IF EXISTS `form_result_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_result_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_result_fields`
--

LOCK TABLES `form_result_fields` WRITE;
/*!40000 ALTER TABLE `form_result_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_result_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_result_fields_unpublished`
--

DROP TABLE IF EXISTS `form_result_fields_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_result_fields_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_result_fields_unpublished`
--

LOCK TABLES `form_result_fields_unpublished` WRITE;
/*!40000 ALTER TABLE `form_result_fields_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_result_fields_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_search_fields`
--

DROP TABLE IF EXISTS `form_search_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_search_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `show_range` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_search_fields`
--

LOCK TABLES `form_search_fields` WRITE;
/*!40000 ALTER TABLE `form_search_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_search_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_search_fields_unpublished`
--

DROP TABLE IF EXISTS `form_search_fields_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_search_fields_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `show_range` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_search_fields_unpublished`
--

LOCK TABLES `form_search_fields_unpublished` WRITE;
/*!40000 ALTER TABLE `form_search_fields_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_search_fields_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freq_rules`
--

DROP TABLE IF EXISTS `freq_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `freq_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(50) NOT NULL DEFAULT '',
  `field_id` varchar(50) NOT NULL DEFAULT '',
  `frequency` varchar(50) NOT NULL DEFAULT '',
  `period` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freq_rules`
--

LOCK TABLES `freq_rules` WRITE;
/*!40000 ALTER TABLE `freq_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `freq_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freq_rules_unpublished`
--

DROP TABLE IF EXISTS `freq_rules_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `freq_rules_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(50) NOT NULL DEFAULT '',
  `field_id` varchar(50) NOT NULL DEFAULT '',
  `frequency` varchar(50) NOT NULL DEFAULT '',
  `period` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freq_rules_unpublished`
--

LOCK TABLES `freq_rules_unpublished` WRITE;
/*!40000 ALTER TABLE `freq_rules_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `freq_rules_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game_prize`
--

DROP TABLE IF EXISTS `game_prize`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `game_prize` (
  `id` varchar(36) NOT NULL,
  `game_uuid` varchar(36) NOT NULL,
  `cart_rule_id` varchar(36) DEFAULT NULL,
  `prize` varchar(255) DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_on` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` varchar(36) DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` varchar(36) DEFAULT NULL,
  `to_publish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` varchar(36) DEFAULT NULL,
  `to_unpublish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` enum('Coupon','Prize') DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game_prize`
--

LOCK TABLES `game_prize` WRITE;
/*!40000 ALTER TABLE `game_prize` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_prize` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `game_prize_unpublished`
--

DROP TABLE IF EXISTS `game_prize_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `game_prize_unpublished` (
  `id` varchar(36) NOT NULL,
  `game_uuid` varchar(36) NOT NULL,
  `cart_rule_id` varchar(36) DEFAULT NULL,
  `prize` varchar(255) DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_on` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` varchar(36) DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` varchar(36) DEFAULT NULL,
  `to_publish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` varchar(36) DEFAULT NULL,
  `to_unpublish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` enum('Coupon','Prize') DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `game_prize_unpublished`
--

LOCK TABLES `game_prize_unpublished` WRITE;
/*!40000 ALTER TABLE `game_prize_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_prize_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `games`
--

DROP TABLE IF EXISTS `games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `games` (
  `nid` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `attempts_per_user` int(12) NOT NULL,
  `launch_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` varchar(36) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` varchar(36) DEFAULT NULL,
  `to_publish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `version` int(10) NOT NULL DEFAULT 0,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` varchar(36) DEFAULT NULL,
  `to_unpublish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `win_type` enum('Draw','Instant') DEFAULT NULL,
  `can_lose` tinyint(1) NOT NULL DEFAULT 1,
  `play_game_column` varchar(255) NOT NULL DEFAULT '_etn_phone',
  PRIMARY KEY (`nid`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `uq_kys` (`site_id`,`is_deleted`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `games`
--

LOCK TABLES `games` WRITE;
/*!40000 ALTER TABLE `games` DISABLE KEYS */;
/*!40000 ALTER TABLE `games` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `games_unpublished`
--

DROP TABLE IF EXISTS `games_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `games_unpublished` (
  `nid` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `attempts_per_user` int(12) NOT NULL,
  `launch_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_by` varchar(36) NOT NULL,
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` varchar(36) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` varchar(36) DEFAULT NULL,
  `to_publish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `version` int(10) NOT NULL DEFAULT 0,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` varchar(36) DEFAULT NULL,
  `to_unpublish_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `win_type` enum('Draw','Instant') DEFAULT NULL,
  `can_lose` tinyint(1) NOT NULL DEFAULT 1,
  `play_game_column` varchar(255) NOT NULL DEFAULT '_etn_phone',
  PRIMARY KEY (`nid`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `uq_kys` (`site_id`,`is_deleted`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `games_unpublished`
--

LOCK TABLES `games_unpublished` WRITE;
/*!40000 ALTER TABLE `games_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `games_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generic_actions`
--

DROP TABLE IF EXISTS `generic_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_actions` (
  `action_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` varchar(50) DEFAULT NULL,
  `type_action` varchar(50) DEFAULT NULL,
  `equipement` varchar(50) DEFAULT NULL,
  `test_todo` varchar(50) DEFAULT NULL,
  `idmodel` varchar(50) DEFAULT NULL,
  `ident` varchar(50) DEFAULT NULL,
  `mail_to` varchar(50) DEFAULT NULL,
  `share_link` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`action_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generic_actions`
--

LOCK TABLES `generic_actions` WRITE;
/*!40000 ALTER TABLE `generic_actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `generic_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generic_table`
--

DROP TABLE IF EXISTS `generic_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_table` (
  `generic_table_id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) NOT NULL,
  `form_id` varchar(50) NOT NULL,
  `created_on` datetime DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `email` text DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `file_upload` text DEFAULT NULL,
  `name` text DEFAULT NULL,
  `lastid` int(10) unsigned DEFAULT NULL,
  `menu_lang` varchar(20) DEFAULT NULL,
  `mid` varchar(20) DEFAULT NULL,
  `portalurl` varchar(20) DEFAULT NULL,
  `userip` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`generic_table_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generic_table`
--

LOCK TABLES `generic_table` WRITE;
/*!40000 ALTER TABLE `generic_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `generic_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `has_action`
--

DROP TABLE IF EXISTS `has_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `has_action` (
  `start_proc` varchar(75) NOT NULL DEFAULT '',
  `start_phase` varchar(32) NOT NULL,
  `cle` int(10) unsigned NOT NULL,
  `action` varchar(64) NOT NULL,
  PRIMARY KEY (`start_proc`,`start_phase`),
  UNIQUE KEY `cle` (`cle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `has_action`
--

LOCK TABLES `has_action` WRITE;
/*!40000 ALTER TABLE `has_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `has_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `htmlformelement`
--

DROP TABLE IF EXISTS `htmlformelement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `htmlformelement` (
  `htmlformelement_id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) NOT NULL,
  `form_id` varchar(50) NOT NULL,
  `created_on` datetime DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `lastid` int(10) unsigned DEFAULT 0,
  `menu_lang` varchar(20) DEFAULT NULL,
  `mid` varchar(20) DEFAULT NULL,
  `portalurl` varchar(20) DEFAULT NULL,
  `userip` varchar(20) DEFAULT NULL,
  `_etn_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`htmlformelement_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `htmlformelement`
--

LOCK TABLES `htmlformelement` WRITE;
/*!40000 ALTER TABLE `htmlformelement` DISABLE KEYS */;
/*!40000 ALTER TABLE `htmlformelement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `language`
--

DROP TABLE IF EXISTS `language`;
/*!50001 DROP VIEW IF EXISTS `language`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `language` (
  `langue_id` tinyint NOT NULL,
  `langue` tinyint NOT NULL,
  `langue_code` tinyint NOT NULL,
  `og_local` tinyint NOT NULL,
  `direction` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `langue_msg`
--

DROP TABLE IF EXISTS `langue_msg`;
/*!50001 DROP VIEW IF EXISTS `langue_msg`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `langue_msg` (
  `LANGUE_REF` tinyint NOT NULL,
  `LANGUE_1` tinyint NOT NULL,
  `LANGUE_2` tinyint NOT NULL,
  `LANGUE_3` tinyint NOT NULL,
  `LANGUE_4` tinyint NOT NULL,
  `LANGUE_5` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `login`
--

DROP TABLE IF EXISTS `login`;
/*!50001 DROP VIEW IF EXISTS `login`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `login` (
  `pid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `language` tinyint NOT NULL,
  `pass` tinyint NOT NULL,
  `updated_date` tinyint NOT NULL,
  `access_time` tinyint NOT NULL,
  `access_id` tinyint NOT NULL,
  `email_verification_code` tinyint NOT NULL,
  `sms_verification_code` tinyint NOT NULL,
  `sso_id` tinyint NOT NULL,
  `last_site_id` tinyint NOT NULL,
  `puid` tinyint NOT NULL,
  `pass_expiry` tinyint NOT NULL,
  `is_two_auth_enabled` tinyint NOT NULL,
  `send_email` tinyint NOT NULL,
  `secret_key` tinyint NOT NULL,
  `allowed_ips` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mail_config`
--

DROP TABLE IF EXISTS `mail_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_config` (
  `id` int(10) unsigned NOT NULL,
  `ordertype` varchar(75) NOT NULL DEFAULT '',
  `email_to` mediumtext DEFAULT NULL,
  `where_clause` mediumtext DEFAULT NULL,
  `attach` varchar(255) DEFAULT NULL,
  `email_cc` mediumtext DEFAULT NULL,
  `email_ci` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`,`ordertype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_config`
--

LOCK TABLES `mail_config` WRITE;
/*!40000 ALTER TABLE `mail_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_config_unpublished`
--

DROP TABLE IF EXISTS `mail_config_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_config_unpublished` (
  `id` int(10) unsigned NOT NULL,
  `ordertype` varchar(75) NOT NULL DEFAULT '',
  `email_to` mediumtext DEFAULT NULL,
  `where_clause` mediumtext DEFAULT NULL,
  `attach` varchar(255) DEFAULT NULL,
  `email_cc` mediumtext DEFAULT NULL,
  `email_ci` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`,`ordertype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_config_unpublished`
--

LOCK TABLES `mail_config_unpublished` WRITE;
/*!40000 ALTER TABLE `mail_config_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_config_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mailing_list`
--

DROP TABLE IF EXISTS `mailing_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailing_list` (
  `mailing_list_id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) NOT NULL,
  `form_id` varchar(50) NOT NULL,
  `created_on` datetime DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `lastid` int(10) unsigned DEFAULT 0,
  `menu_lang` varchar(20) DEFAULT NULL,
  `mid` varchar(50) DEFAULT NULL,
  `portalurl` varchar(255) DEFAULT NULL,
  `userip` varchar(50) DEFAULT NULL,
  `_etn_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`mailing_list_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mailing_list`
--

LOCK TABLES `mailing_list` WRITE;
/*!40000 ALTER TABLE `mailing_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `mailing_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mails`
--

DROP TABLE IF EXISTS `mails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mails` (
  `sujet` varchar(128) NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `de` varchar(128) DEFAULT NULL,
  `type` varchar(256) DEFAULT NULL,
  `attachs` text DEFAULT NULL,
  `seq` int(11) NOT NULL DEFAULT 0,
  `sujet_lang_2` varchar(255) DEFAULT NULL,
  `sujet_lang_3` varchar(255) DEFAULT NULL,
  `sujet_lang_4` varchar(255) DEFAULT NULL,
  `sujet_lang_5` varchar(255) DEFAULT NULL,
  `template_type` char(15) DEFAULT 'text',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mails`
--

LOCK TABLES `mails` WRITE;
/*!40000 ALTER TABLE `mails` DISABLE KEYS */;
/*!40000 ALTER TABLE `mails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mails_unpublished`
--

DROP TABLE IF EXISTS `mails_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mails_unpublished` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sujet` varchar(128) NOT NULL,
  `de` varchar(128) DEFAULT NULL,
  `type` varchar(256) DEFAULT NULL,
  `attachs` text DEFAULT NULL,
  `seq` int(11) NOT NULL DEFAULT 0,
  `sujet_lang_2` varchar(255) DEFAULT NULL,
  `sujet_lang_3` varchar(255) DEFAULT NULL,
  `sujet_lang_4` varchar(255) DEFAULT NULL,
  `sujet_lang_5` varchar(255) DEFAULT NULL,
  `template_type` char(15) DEFAULT 'text',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mails_unpublished`
--

LOCK TABLES `mails_unpublished` WRITE;
/*!40000 ALTER TABLE `mails_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `mails_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!50001 DROP VIEW IF EXISTS `menu`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `menu` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `url` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `original_forms_names`
--

DROP TABLE IF EXISTS `original_forms_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `original_forms_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `table_name` varchar(255) NOT NULL,
  `table_new_name` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `original_forms_names`
--

LOCK TABLES `original_forms_names` WRITE;
/*!40000 ALTER TABLE `original_forms_names` DISABLE KEYS */;
/*!40000 ALTER TABLE `original_forms_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `osql`
--

DROP TABLE IF EXISTS `osql`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `osql` (
  `id` varchar(30) NOT NULL,
  `nextOnErr` char(1) DEFAULT NULL,
  `throwErr` char(1) DEFAULT NULL,
  `sqltext` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `osql`
--

LOCK TABLES `osql` WRITE;
/*!40000 ALTER TABLE `osql` DISABLE KEYS */;
INSERT INTO `osql` VALUES ('processNow','1',NULL,'select 0'),('waitProcessNow','1',NULL,'select case when flag > 0 then 0 else 120000 end from post_work where id =  $wkid');
/*!40000 ALTER TABLE `osql` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `page`
--

DROP TABLE IF EXISTS `page`;
/*!50001 DROP VIEW IF EXISTS `page`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `page` (
  `name` tinyint NOT NULL,
  `url` tinyint NOT NULL,
  `parent` tinyint NOT NULL,
  `rang` tinyint NOT NULL,
  `new_tab` tinyint NOT NULL,
  `icon` tinyint NOT NULL,
  `parent_icon` tinyint NOT NULL,
  `requires_ecommerce` tinyint NOT NULL,
  `menu_badge` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `page_profil`
--

DROP TABLE IF EXISTS `page_profil`;
/*!50001 DROP VIEW IF EXISTS `page_profil`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `page_profil` (
  `url` tinyint NOT NULL,
  `profil_id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `page_sub_urls`
--

DROP TABLE IF EXISTS `page_sub_urls`;
/*!50001 DROP VIEW IF EXISTS `page_sub_urls`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `page_sub_urls` (
  `url` tinyint NOT NULL,
  `sub_url` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `person`
--

DROP TABLE IF EXISTS `person`;
/*!50001 DROP VIEW IF EXISTS `person`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `person` (
  `person_id` tinyint NOT NULL,
  `first_name` tinyint NOT NULL,
  `last_name` tinyint NOT NULL,
  `address` tinyint NOT NULL,
  `zip_code` tinyint NOT NULL,
  `telephone` tinyint NOT NULL,
  `e_mail` tinyint NOT NULL,
  `country_id` tinyint NOT NULL,
  `fax` tinyint NOT NULL,
  `grade` tinyint NOT NULL,
  `ag_post` tinyint NOT NULL,
  `archive` tinyint NOT NULL,
  `home_page` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `person_sites`
--

DROP TABLE IF EXISTS `person_sites`;
/*!50001 DROP VIEW IF EXISTS `person_sites`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `person_sites` (
  `person_id` tinyint NOT NULL,
  `site_id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `phases`
--

DROP TABLE IF EXISTS `phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phases` (
  `process` varchar(75) NOT NULL DEFAULT '',
  `phase` varchar(32) NOT NULL,
  `topLeftX` int(11) DEFAULT NULL,
  `topLeftY` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `type` varchar(45) NOT NULL DEFAULT '',
  `text` varchar(45) NOT NULL DEFAULT '',
  `stepNb` varchar(45) NOT NULL DEFAULT '',
  `actors` text NOT NULL,
  `activities` varchar(45) NOT NULL DEFAULT '',
  `priority` int(11) DEFAULT NULL,
  `execute` varchar(64) DEFAULT NULL,
  `visc` tinyint(1) NOT NULL DEFAULT 1,
  `isManual` tinyint(1) NOT NULL DEFAULT 1,
  `displayName` varchar(100) NOT NULL,
  `rulesVisibleTo` varchar(200) DEFAULT NULL,
  `reverse` enum('R','S') NOT NULL DEFAULT 'R',
  `oprType` enum('T','O') NOT NULL DEFAULT 'O',
  PRIMARY KEY (`process`,`phase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phases`
--

LOCK TABLES `phases` WRITE;
/*!40000 ALTER TABLE `phases` DISABLE KEYS */;
/*!40000 ALTER TABLE `phases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_work`
--

DROP TABLE IF EXISTS `post_work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_work` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `proces` varchar(75) DEFAULT NULL,
  `phase` varchar(32) NOT NULL DEFAULT '',
  `priority` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'now par defaut',
  `instance_agent` varchar(8) DEFAULT NULL COMMENT 'for multi-agent gizmo',
  `status` int(1) NOT NULL DEFAULT 0,
  `errCode` int(11) NOT NULL DEFAULT 0,
  `errMessage` mediumtext DEFAULT NULL,
  `attempt` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'attempt counter for exemple',
  `insertion_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'now ',
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `client_key` int(11) NOT NULL,
  `class` varchar(64) DEFAULT NULL COMMENT 'action to run',
  `flag` int(10) unsigned NOT NULL DEFAULT 0,
  `operador` varchar(30) DEFAULT NULL,
  `nextid` int(11) NOT NULL DEFAULT 0,
  `form_table_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `post_work_search` (`proces`,`phase`,`status`,`priority`),
  KEY `client_key` (`client_key`,`status`),
  KEY `ix_phase` (`phase`),
  KEY `ix_nextid` (`nextid`),
  KEY `cur` (`status`),
  KEY `ix_todo` (`priority`,`status`),
  KEY `ix_cur` (`insertion_date`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_work`
--

LOCK TABLES `post_work` WRITE;
/*!40000 ALTER TABLE `post_work` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_work` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_descriptions`
--

DROP TABLE IF EXISTS `process_form_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_descriptions` (
  `form_id` varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT '',
  `success_msg` text DEFAULT '',
  `submit_btn_lbl` varchar(255) DEFAULT '',
  `cancel_btn_lbl` varchar(255) DEFAULT '',
  PRIMARY KEY (`form_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_descriptions`
--

LOCK TABLES `process_form_descriptions` WRITE;
/*!40000 ALTER TABLE `process_form_descriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_descriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_descriptions_unpublished`
--

DROP TABLE IF EXISTS `process_form_descriptions_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_descriptions_unpublished` (
  `form_id` varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT '',
  `success_msg` text DEFAULT NULL,
  `submit_btn_lbl` varchar(255) DEFAULT '',
  `cancel_btn_lbl` varchar(255) DEFAULT '',
  PRIMARY KEY (`form_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_descriptions_unpublished`
--

LOCK TABLES `process_form_descriptions_unpublished` WRITE;
/*!40000 ALTER TABLE `process_form_descriptions_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_descriptions_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_field_descriptions`
--

DROP TABLE IF EXISTS `process_form_field_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_field_descriptions` (
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `label` text DEFAULT '',
  `placeholder` varchar(50) DEFAULT '',
  `err_msg` varchar(255) DEFAULT '',
  `value` varchar(1052) DEFAULT NULL,
  `options` text DEFAULT NULL,
  `option_query` text DEFAULT NULL,
  PRIMARY KEY (`form_id`,`field_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_field_descriptions`
--

LOCK TABLES `process_form_field_descriptions` WRITE;
/*!40000 ALTER TABLE `process_form_field_descriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_field_descriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_field_descriptions_unpublished`
--

DROP TABLE IF EXISTS `process_form_field_descriptions_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_field_descriptions_unpublished` (
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `label` text DEFAULT NULL,
  `placeholder` varchar(50) DEFAULT '',
  `err_msg` varchar(255) DEFAULT '',
  `value` varchar(1052) DEFAULT NULL,
  `options` text DEFAULT NULL,
  `option_query` text DEFAULT NULL,
  PRIMARY KEY (`form_id`,`field_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_field_descriptions_unpublished`
--

LOCK TABLES `process_form_field_descriptions_unpublished` WRITE;
/*!40000 ALTER TABLE `process_form_field_descriptions_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_field_descriptions_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_fields`
--

DROP TABLE IF EXISTS `process_form_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `seq_order` int(5) DEFAULT 0,
  `label_id` varchar(50) DEFAULT NULL,
  `field_type` char(5) DEFAULT NULL,
  `db_column_name` varchar(50) DEFAULT NULL,
  `font_weight` varchar(50) DEFAULT NULL,
  `font_size` varchar(50) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `maxlength` varchar(50) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `rule_field` tinyint(1) NOT NULL DEFAULT 0,
  `add_no_of_days` varchar(50) DEFAULT NULL,
  `start_time` varchar(50) DEFAULT NULL,
  `end_time` varchar(50) DEFAULT NULL,
  `time_slice` varchar(50) DEFAULT NULL,
  `default_time_value` varchar(50) DEFAULT NULL,
  `autocomplete_char_after` char(5) DEFAULT NULL,
  `element_autocomplete_query` text DEFAULT NULL,
  `element_trigger` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `element_id` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `element_option_class` varchar(50) DEFAULT NULL,
  `element_option_others` varchar(50) DEFAULT NULL,
  `element_option_query` tinyint(1) NOT NULL DEFAULT 0,
  `resizable_col_class` varchar(50) DEFAULT NULL,
  `always_visible` tinyint(1) NOT NULL DEFAULT 1,
  `regx_exp` varchar(50) DEFAULT NULL,
  `group_of_fields` int(5) DEFAULT NULL,
  `file_extension` varchar(256) DEFAULT '',
  `img_width` varchar(20) DEFAULT '100px',
  `img_height` varchar(20) DEFAULT '100px',
  `img_alt` varchar(100) DEFAULT NULL,
  `img_murl` varchar(255) DEFAULT NULL,
  `href_chckbx` tinyint(1) NOT NULL DEFAULT 0,
  `href_target` varchar(20) DEFAULT NULL,
  `img_href_url` varchar(255) DEFAULT NULL,
  `btn_id` varchar(255) DEFAULT NULL,
  `container_bkcolor` varchar(255) DEFAULT NULL,
  `text_align` varchar(50) DEFAULT NULL,
  `text_border` varchar(50) DEFAULT NULL,
  `site_key` varchar(255) DEFAULT NULL,
  `theme` varchar(50) DEFAULT NULL,
  `recaptcha_data_size` varchar(50) DEFAULT NULL,
  `custom_css` text DEFAULT NULL,
  `line_id` varchar(36) NOT NULL,
  `min_range` int(10) DEFAULT 0,
  `max_range` int(10) DEFAULT 0,
  `step_range` int(10) DEFAULT 0,
  `img_url` varchar(255) DEFAULT NULL,
  `default_country_code` char(2) DEFAULT '',
  `allow_country_code` varchar(100) DEFAULT '',
  `allow_national_mode` char(1) DEFAULT '1',
  `local_country_name` char(1) DEFAULT '0',
  `hidden` char(1) DEFAULT '0',
  `custom_classes` varchar(255) DEFAULT '',
  `date_format` varchar(25) DEFAULT 'm/d/Y',
  `is_deletable` char(1) DEFAULT '1',
  `file_browser_val` varchar(100) DEFAULT '',
  `auto_format_tel_number` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_id` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_fields`
--

LOCK TABLES `process_form_fields` WRITE;
/*!40000 ALTER TABLE `process_form_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_fields_temp`
--

DROP TABLE IF EXISTS `process_form_fields_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_fields_temp` (
  `id` int(11) NOT NULL DEFAULT 0,
  `form_id` varchar(36) CHARACTER SET utf8 NOT NULL,
  `field_id` varchar(36) CHARACTER SET utf8 NOT NULL,
  `seq_order` int(5) DEFAULT 0,
  `label_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `field_type` char(5) CHARACTER SET utf8 DEFAULT NULL,
  `db_column_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `label` varchar(1020) CHARACTER SET utf8 DEFAULT NULL,
  `font_weight` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `font_size` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `color` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `placeholder` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `value` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `maxlength` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `rule_field` tinyint(1) NOT NULL DEFAULT 0,
  `add_no_of_days` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `start_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `end_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `time_slice` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `default_time_value` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `autocomplete_char_after` char(5) CHARACTER SET utf8 DEFAULT NULL,
  `element_autocomplete_query` text CHARACTER SET utf8 DEFAULT NULL,
  `element_trigger` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `label_name` varchar(1020) CHARACTER SET utf8 DEFAULT NULL,
  `element_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `element_option_class` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `element_option_others` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `element_option_query` tinyint(1) NOT NULL DEFAULT 0,
  `element_option_query_value` text CHARACTER SET utf8 DEFAULT NULL,
  `resizable_col_class` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `options` text CHARACTER SET utf8 DEFAULT NULL,
  `always_visible` tinyint(1) NOT NULL DEFAULT 1,
  `regx_exp` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `group_of_fields` int(5) DEFAULT NULL,
  `file_extension` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `img_width` varchar(20) CHARACTER SET utf8 DEFAULT '100px',
  `img_height` varchar(20) CHARACTER SET utf8 DEFAULT '100px',
  `img_alt` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `img_murl` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `href_chckbx` tinyint(1) NOT NULL DEFAULT 0,
  `err_msg` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `href_target` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `img_href_url` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `btn_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `container_bkcolor` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `text_align` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `text_border` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `site_key` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `theme` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `recaptcha_data_size` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `custom_css` text CHARACTER SET utf8 DEFAULT NULL,
  `line_id` varchar(36) CHARACTER SET utf8 NOT NULL,
  `min_range` int(10) DEFAULT 0,
  `max_range` int(10) DEFAULT 0,
  `step_range` int(10) DEFAULT 0,
  `img_url` varchar(20) CHARACTER SET utf8 DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_fields_temp`
--

LOCK TABLES `process_form_fields_temp` WRITE;
/*!40000 ALTER TABLE `process_form_fields_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_fields_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_fields_unpublished`
--

DROP TABLE IF EXISTS `process_form_fields_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_fields_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `seq_order` int(5) DEFAULT 0,
  `label_id` varchar(50) DEFAULT NULL,
  `field_type` char(5) DEFAULT NULL,
  `db_column_name` varchar(50) DEFAULT NULL,
  `font_weight` varchar(50) DEFAULT NULL,
  `font_size` varchar(50) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `maxlength` varchar(50) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `rule_field` tinyint(1) NOT NULL DEFAULT 0,
  `add_no_of_days` varchar(50) DEFAULT NULL,
  `start_time` varchar(50) DEFAULT NULL,
  `end_time` varchar(50) DEFAULT NULL,
  `time_slice` varchar(50) DEFAULT NULL,
  `default_time_value` varchar(50) DEFAULT NULL,
  `autocomplete_char_after` char(5) DEFAULT NULL,
  `element_autocomplete_query` text DEFAULT NULL,
  `element_trigger` longtext DEFAULT NULL,
  `element_id` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `element_option_class` varchar(50) DEFAULT NULL,
  `element_option_others` varchar(50) DEFAULT NULL,
  `element_option_query` tinyint(1) NOT NULL DEFAULT 0,
  `resizable_col_class` varchar(50) DEFAULT NULL,
  `always_visible` tinyint(1) NOT NULL DEFAULT 1,
  `regx_exp` varchar(50) DEFAULT NULL,
  `group_of_fields` int(5) DEFAULT NULL,
  `file_extension` varchar(256) DEFAULT '',
  `img_width` varchar(20) DEFAULT '100px',
  `img_height` varchar(20) DEFAULT '100px',
  `img_alt` varchar(100) DEFAULT NULL,
  `img_murl` varchar(255) DEFAULT NULL,
  `href_chckbx` tinyint(1) NOT NULL DEFAULT 0,
  `href_target` varchar(20) DEFAULT NULL,
  `img_href_url` varchar(255) DEFAULT NULL,
  `btn_id` varchar(255) DEFAULT NULL,
  `container_bkcolor` varchar(255) DEFAULT NULL,
  `text_align` varchar(50) DEFAULT NULL,
  `text_border` varchar(50) DEFAULT NULL,
  `site_key` varchar(255) DEFAULT NULL,
  `theme` varchar(50) DEFAULT NULL,
  `recaptcha_data_size` varchar(50) DEFAULT NULL,
  `custom_css` text DEFAULT NULL,
  `line_id` varchar(36) NOT NULL,
  `min_range` int(10) DEFAULT 0,
  `max_range` int(10) DEFAULT 0,
  `step_range` int(10) DEFAULT 0,
  `img_url` varchar(255) DEFAULT NULL,
  `default_country_code` char(2) DEFAULT '',
  `allow_country_code` varchar(100) DEFAULT '',
  `allow_national_mode` char(1) DEFAULT '1',
  `local_country_name` char(1) DEFAULT '0',
  `hidden` char(1) DEFAULT '0',
  `custom_classes` varchar(255) DEFAULT '',
  `is_deletable` char(1) DEFAULT '1',
  `date_format` varchar(25) DEFAULT 'm/d/Y',
  `file_browser_val` varchar(100) DEFAULT '',
  `auto_format_tel_number` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_id` (`form_id`,`field_id`),
  KEY `idx_line_id` (`line_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_fields_unpublished`
--

LOCK TABLES `process_form_fields_unpublished` WRITE;
/*!40000 ALTER TABLE `process_form_fields_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_fields_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_lines`
--

DROP TABLE IF EXISTS `process_form_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_lines` (
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `line_id` varchar(50) DEFAULT '',
  `line_class` varchar(50) DEFAULT '',
  `line_width` char(10) DEFAULT '',
  `line_seq` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`form_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_lines`
--

LOCK TABLES `process_form_lines` WRITE;
/*!40000 ALTER TABLE `process_form_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_form_lines_unpublished`
--

DROP TABLE IF EXISTS `process_form_lines_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_form_lines_unpublished` (
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `line_id` varchar(50) DEFAULT '',
  `line_class` varchar(50) DEFAULT '',
  `line_width` char(10) DEFAULT '',
  `line_seq` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`form_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_form_lines_unpublished`
--

LOCK TABLES `process_form_lines_unpublished` WRITE;
/*!40000 ALTER TABLE `process_form_lines_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_form_lines_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_forms`
--

DROP TABLE IF EXISTS `process_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_forms` (
  `form_id` varchar(36) NOT NULL,
  `process_name` varchar(50) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `is_email_cust` char(1) DEFAULT '0',
  `is_email_bk_ofc` char(1) DEFAULT '0',
  `cust_eid` int(10) DEFAULT NULL,
  `bk_ofc_eid` int(10) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
  `variant` char(12) NOT NULL,
  `template` char(15) NOT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `form_class` text DEFAULT NULL,
  `html_form_id` varchar(25) DEFAULT '',
  `form_method` char(10) DEFAULT '',
  `form_enctype` varchar(50) DEFAULT '',
  `form_autocomplete` char(10) DEFAULT '',
  `redirect_url` varchar(255) DEFAULT '',
  `btn_align` char(1) DEFAULT 'r',
  `label_display` char(3) DEFAULT 'tal',
  `form_width` char(10) DEFAULT '',
  `form_js` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `form_css` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type` varchar(25) NOT NULL DEFAULT 'simple',
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` int(11) DEFAULT NULL,
  `to_publish_ts` datetime DEFAULT NULL,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` int(11) DEFAULT NULL,
  `to_unpublish_ts` datetime DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `is_sms` tinyint(1) DEFAULT 0,
  `cust_sms_id` int(11) DEFAULT NULL,
  `delete_uploads` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`form_id`),
  UNIQUE KEY `process_name` (`process_name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_forms`
--

LOCK TABLES `process_forms` WRITE;
/*!40000 ALTER TABLE `process_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `process_forms_unpublished`
--

DROP TABLE IF EXISTS `process_forms_unpublished`;
/*!50001 DROP VIEW IF EXISTS `process_forms_unpublished`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `process_forms_unpublished` (
  `form_id` tinyint NOT NULL,
  `process_name` tinyint NOT NULL,
  `table_name` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_email_cust` tinyint NOT NULL,
  `is_email_bk_ofc` tinyint NOT NULL,
  `cust_eid` tinyint NOT NULL,
  `bk_ofc_eid` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `variant` tinyint NOT NULL,
  `template` tinyint NOT NULL,
  `meta_description` tinyint NOT NULL,
  `meta_keywords` tinyint NOT NULL,
  `form_class` tinyint NOT NULL,
  `html_form_id` tinyint NOT NULL,
  `form_method` tinyint NOT NULL,
  `form_enctype` tinyint NOT NULL,
  `form_autocomplete` tinyint NOT NULL,
  `redirect_url` tinyint NOT NULL,
  `btn_align` tinyint NOT NULL,
  `label_display` tinyint NOT NULL,
  `form_width` tinyint NOT NULL,
  `form_js` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `form_css` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `to_publish_by` tinyint NOT NULL,
  `to_publish_ts` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `to_unpublish` tinyint NOT NULL,
  `to_unpublish_by` tinyint NOT NULL,
  `to_unpublish_ts` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `is_sms` tinyint NOT NULL,
  `cust_sms_id` tinyint NOT NULL,
  `delete_uploads` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `process_forms_unpublished_tbl`
--

DROP TABLE IF EXISTS `process_forms_unpublished_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_forms_unpublished_tbl` (
  `form_id` varchar(36) NOT NULL,
  `process_name` varchar(50) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `is_email_cust` char(1) NOT NULL DEFAULT '0',
  `is_email_bk_ofc` char(1) NOT NULL DEFAULT '0',
  `cust_eid` int(10) DEFAULT NULL,
  `bk_ofc_eid` int(10) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
  `variant` char(12) NOT NULL,
  `template` char(15) NOT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `form_class` text DEFAULT NULL,
  `html_form_id` varchar(25) DEFAULT '',
  `form_method` char(10) DEFAULT '',
  `form_enctype` varchar(50) DEFAULT '',
  `form_autocomplete` char(10) DEFAULT '',
  `redirect_url` varchar(255) DEFAULT '',
  `btn_align` char(1) NOT NULL DEFAULT 'r',
  `label_display` char(3) NOT NULL DEFAULT 'tal',
  `form_width` char(10) DEFAULT '',
  `form_js` longtext DEFAULT NULL,
  `type` varchar(25) NOT NULL DEFAULT 'simple',
  `form_css` longtext DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` int(11) DEFAULT NULL,
  `to_publish_ts` datetime DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` int(11) DEFAULT NULL,
  `to_unpublish_ts` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `is_sms` tinyint(1) DEFAULT 0,
  `cust_sms_id` int(11) DEFAULT NULL,
  `delete_uploads` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`form_id`),
  UNIQUE KEY `process_name` (`is_deleted`,`process_name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_forms_unpublished_tbl`
--

LOCK TABLES `process_forms_unpublished_tbl` WRITE;
/*!40000 ALTER TABLE `process_forms_unpublished_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_forms_unpublished_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_rule_fields`
--

DROP TABLE IF EXISTS `process_rule_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_rule_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) DEFAULT NULL,
  `field_id` varchar(50) DEFAULT NULL,
  `field_type` char(5) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `required` varchar(50) DEFAULT NULL,
  `add_no_of_days` varchar(50) DEFAULT NULL,
  `start_time` varchar(50) DEFAULT NULL,
  `end_time` varchar(50) DEFAULT NULL,
  `time_slice` varchar(50) DEFAULT NULL,
  `default_time_value` varchar(50) DEFAULT NULL,
  `element_trigger` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `options` text DEFAULT NULL,
  `element_option_query` tinyint(1) NOT NULL DEFAULT 0,
  `element_option_query_value` text DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_rule_fields`
--

LOCK TABLES `process_rule_fields` WRITE;
/*!40000 ALTER TABLE `process_rule_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_rule_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `process_rules`
--

DROP TABLE IF EXISTS `process_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_rules` (
  `rule_id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_name` varchar(50) DEFAULT NULL,
  `group_id` varchar(50) DEFAULT NULL,
  `form_id` varchar(36) DEFAULT NULL,
  `rule_combination` blob DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`rule_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `process_rules`
--

LOCK TABLES `process_rules` WRITE;
/*!40000 ALTER TABLE `process_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `process_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `profil`
--

DROP TABLE IF EXISTS `profil`;
/*!50001 DROP VIEW IF EXISTS `profil`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `profil` (
  `profil_id` tinyint NOT NULL,
  `profil` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `Archive` tinyint NOT NULL,
  `bannedPhases` tinyint NOT NULL,
  `home_page` tinyint NOT NULL,
  `color` tinyint NOT NULL,
  `assign_site` tinyint NOT NULL,
  `is_webmaster` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `profilemenu`
--

DROP TABLE IF EXISTS `profilemenu`;
/*!50001 DROP VIEW IF EXISTS `profilemenu`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `profilemenu` (
  `id` tinyint NOT NULL,
  `idMenu` tinyint NOT NULL,
  `profile` tinyint NOT NULL,
  `displaySeqNum` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `profilperson`
--

DROP TABLE IF EXISTS `profilperson`;
/*!50001 DROP VIEW IF EXISTS `profilperson`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `profilperson` (
  `profil_id` tinyint NOT NULL,
  `person_id` tinyint NOT NULL,
  `date_debut_valid` tinyint NOT NULL,
  `profilperson_id` tinyint NOT NULL,
  `date_fin_valid` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `relation`
--

DROP TABLE IF EXISTS `relation`;
/*!50001 DROP VIEW IF EXISTS `relation`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `relation` (
  `pid1` tinyint NOT NULL,
  `Etn_function_id` tinyint NOT NULL,
  `pid2` tinyint NOT NULL,
  `Date_debut_Valid` tinyint NOT NULL,
  `relation_id` tinyint NOT NULL,
  `Date_Fin_Valid` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resources` (
  `name` varchar(255) NOT NULL,
  `phone_no` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `rtype` enum('primary','secondary') NOT NULL,
  PRIMARY KEY (`name`,`rtype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `responsibility`
--

DROP TABLE IF EXISTS `responsibility`;
/*!50001 DROP VIEW IF EXISTS `responsibility`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `responsibility` (
  `Person_id` tinyint NOT NULL,
  `Etn_function_id` tinyint NOT NULL,
  `Entity_id` tinyint NOT NULL,
  `Date_debut_Valid` tinyint NOT NULL,
  `responsibility_id` tinyint NOT NULL,
  `Date_Fin_Valid` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rlock`
--

DROP TABLE IF EXISTS `rlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rlock` (
  `customerId` int(10) unsigned NOT NULL,
  `csr` varchar(50) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`customerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rlock`
--

LOCK TABLES `rlock` WRITE;
/*!40000 ALTER TABLE `rlock` DISABLE KEYS */;
/*!40000 ALTER TABLE `rlock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rules`
--

DROP TABLE IF EXISTS `rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules` (
  `start_proc` varchar(75) DEFAULT NULL,
  `start_phase` varchar(32) NOT NULL DEFAULT 'INC',
  `errCode` int(11) NOT NULL DEFAULT 0,
  `next_proc` varchar(75) DEFAULT NULL,
  `next_phase` varchar(32) NOT NULL DEFAULT '',
  `nextestado` int(11) NOT NULL DEFAULT 0,
  `action` varchar(64) NOT NULL DEFAULT '',
  `priorite` int(11) NOT NULL DEFAULT 0,
  `cle` int(10) NOT NULL AUTO_INCREMENT,
  `tipo` int(11) DEFAULT 0,
  `rdv` enum('And','Or','Custom') NOT NULL,
  `nstate` varchar(11) NOT NULL DEFAULT '0',
  `type` enum('Cancelled','Closed','Abort') NOT NULL,
  PRIMARY KEY (`cle`),
  UNIQUE KEY `unk` (`start_proc`,`start_phase`,`errCode`,`next_phase`),
  KEY `ix_nextestado` (`nextestado`),
  KEY `ix_sel` (`start_proc`,`start_phase`,`priorite`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules`
--

LOCK TABLES `rules` WRITE;
/*!40000 ALTER TABLE `rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `shortcuts`
--

DROP TABLE IF EXISTS `shortcuts`;
/*!50001 DROP VIEW IF EXISTS `shortcuts`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `shortcuts` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `url` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `site_id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sms`
--

DROP TABLE IF EXISTS `sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms`
--

LOCK TABLES `sms` WRITE;
/*!40000 ALTER TABLE `sms` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_unpublished`
--

DROP TABLE IF EXISTS `sms_unpublished`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_unpublished`
--

LOCK TABLES `sms_unpublished` WRITE;
/*!40000 ALTER TABLE `sms_unpublished` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_unpublished` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supported_files`
--

DROP TABLE IF EXISTS `supported_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supported_files` (
  `extension` varchar(250) NOT NULL DEFAULT '',
  `type` varchar(250) NOT NULL DEFAULT '',
  `icon` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`extension`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supported_files`
--

LOCK TABLES `supported_files` WRITE;
/*!40000 ALTER TABLE `supported_files` DISABLE KEYS */;
INSERT INTO `supported_files` VALUES ('jpg','image/jpeg','Camera.png'),('jpeg','image/jpeg','Camera.png'),('png','image/png','Camera.png'),('pdf','application/pdf','PDF.png'),('doc','application/msword','Word.png'),('docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document','Word.png'),('ppt','application/vnd.ms-powerpoint','Powerpoint.png'),('pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation','Powerpoint.png'),('mov','video/quicktime','Video.png'),('avi','video/x-msvideo','Video.png'),('mp4','video/mp4','Video.png'),('3gp','video/3gpp','Video.png');
/*!40000 ALTER TABLE `supported_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `check_rights`
--

/*!50001 DROP TABLE IF EXISTS `check_rights`*/;
/*!50001 DROP VIEW IF EXISTS `check_rights`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `check_rights` AS select `cleandb_catalog`.`check_rights`.`url` AS `url` from `cleandb_catalog`.`check_rights` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `language`
--

/*!50001 DROP TABLE IF EXISTS `language`*/;
/*!50001 DROP VIEW IF EXISTS `language`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `language` AS select `cleandb_catalog`.`language`.`langue_id` AS `langue_id`,`cleandb_catalog`.`language`.`langue` AS `langue`,`cleandb_catalog`.`language`.`langue_code` AS `langue_code`,`cleandb_catalog`.`language`.`og_local` AS `og_local`,`cleandb_catalog`.`language`.`direction` AS `direction` from `cleandb_catalog`.`language` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `langue_msg`
--

/*!50001 DROP TABLE IF EXISTS `langue_msg`*/;
/*!50001 DROP VIEW IF EXISTS `langue_msg`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `langue_msg` AS select `cleandb_catalog`.`langue_msg`.`LANGUE_REF` AS `LANGUE_REF`,`cleandb_catalog`.`langue_msg`.`LANGUE_1` AS `LANGUE_1`,`cleandb_catalog`.`langue_msg`.`LANGUE_2` AS `LANGUE_2`,`cleandb_catalog`.`langue_msg`.`LANGUE_3` AS `LANGUE_3`,`cleandb_catalog`.`langue_msg`.`LANGUE_4` AS `LANGUE_4`,`cleandb_catalog`.`langue_msg`.`LANGUE_5` AS `LANGUE_5`,`cleandb_catalog`.`langue_msg`.`updated_on` AS `updated_on`,`cleandb_catalog`.`langue_msg`.`updated_by` AS `updated_by` from `cleandb_catalog`.`langue_msg` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `login`
--

/*!50001 DROP TABLE IF EXISTS `login`*/;
/*!50001 DROP VIEW IF EXISTS `login`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `login` AS select `cleandb_catalog`.`login`.`pid` AS `pid`,`cleandb_catalog`.`login`.`name` AS `name`,`cleandb_catalog`.`login`.`language` AS `language`,`cleandb_catalog`.`login`.`pass` AS `pass`,`cleandb_catalog`.`login`.`updated_date` AS `updated_date`,`cleandb_catalog`.`login`.`access_time` AS `access_time`,`cleandb_catalog`.`login`.`access_id` AS `access_id`,`cleandb_catalog`.`login`.`email_verification_code` AS `email_verification_code`,`cleandb_catalog`.`login`.`sms_verification_code` AS `sms_verification_code`,`cleandb_catalog`.`login`.`sso_id` AS `sso_id`,`cleandb_catalog`.`login`.`last_site_id` AS `last_site_id`,`cleandb_catalog`.`login`.`puid` AS `puid`,`cleandb_catalog`.`login`.`pass_expiry` AS `pass_expiry`,`cleandb_catalog`.`login`.`is_two_auth_enabled` AS `is_two_auth_enabled`,`cleandb_catalog`.`login`.`send_email` AS `send_email`,`cleandb_catalog`.`login`.`secret_key` AS `secret_key`,`cleandb_catalog`.`login`.`allowed_ips` AS `allowed_ips` from `cleandb_catalog`.`login` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `menu`
--

/*!50001 DROP TABLE IF EXISTS `menu`*/;
/*!50001 DROP VIEW IF EXISTS `menu`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `menu` AS select `cleandb_catalog`.`menu`.`id` AS `id`,`cleandb_catalog`.`menu`.`name` AS `name`,`cleandb_catalog`.`menu`.`url` AS `url` from `cleandb_catalog`.`menu` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `page`
--

/*!50001 DROP TABLE IF EXISTS `page`*/;
/*!50001 DROP VIEW IF EXISTS `page`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `page` AS select `cleandb_catalog`.`page`.`name` AS `name`,`cleandb_catalog`.`page`.`url` AS `url`,`cleandb_catalog`.`page`.`parent` AS `parent`,`cleandb_catalog`.`page`.`rang` AS `rang`,`cleandb_catalog`.`page`.`new_tab` AS `new_tab`,`cleandb_catalog`.`page`.`icon` AS `icon`,`cleandb_catalog`.`page`.`parent_icon` AS `parent_icon`,`cleandb_catalog`.`page`.`requires_ecommerce` AS `requires_ecommerce`,`cleandb_catalog`.`page`.`menu_badge` AS `menu_badge` from `cleandb_catalog`.`page` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `page_profil`
--

/*!50001 DROP TABLE IF EXISTS `page_profil`*/;
/*!50001 DROP VIEW IF EXISTS `page_profil`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `page_profil` AS select `cleandb_catalog`.`page_profil`.`url` AS `url`,`cleandb_catalog`.`page_profil`.`profil_id` AS `profil_id` from `cleandb_catalog`.`page_profil` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `page_sub_urls`
--

/*!50001 DROP TABLE IF EXISTS `page_sub_urls`*/;
/*!50001 DROP VIEW IF EXISTS `page_sub_urls`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `page_sub_urls` AS select `cleandb_catalog`.`page_sub_urls`.`url` AS `url`,`cleandb_catalog`.`page_sub_urls`.`sub_url` AS `sub_url` from `cleandb_catalog`.`page_sub_urls` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `person`
--

/*!50001 DROP TABLE IF EXISTS `person`*/;
/*!50001 DROP VIEW IF EXISTS `person`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `person` AS select `cleandb_catalog`.`person`.`person_id` AS `person_id`,`cleandb_catalog`.`person`.`first_name` AS `first_name`,`cleandb_catalog`.`person`.`last_name` AS `last_name`,`cleandb_catalog`.`person`.`address` AS `address`,`cleandb_catalog`.`person`.`zip_code` AS `zip_code`,`cleandb_catalog`.`person`.`telephone` AS `telephone`,`cleandb_catalog`.`person`.`e_mail` AS `e_mail`,`cleandb_catalog`.`person`.`country_id` AS `country_id`,`cleandb_catalog`.`person`.`fax` AS `fax`,`cleandb_catalog`.`person`.`grade` AS `grade`,`cleandb_catalog`.`person`.`ag_post` AS `ag_post`,`cleandb_catalog`.`person`.`archive` AS `archive`,`cleandb_catalog`.`person`.`home_page` AS `home_page` from `cleandb_catalog`.`person` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `person_sites`
--

/*!50001 DROP TABLE IF EXISTS `person_sites`*/;
/*!50001 DROP VIEW IF EXISTS `person_sites`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `person_sites` AS select `cleandb_catalog`.`person_sites`.`person_id` AS `person_id`,`cleandb_catalog`.`person_sites`.`site_id` AS `site_id` from `cleandb_catalog`.`person_sites` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `process_forms_unpublished`
--

/*!50001 DROP TABLE IF EXISTS `process_forms_unpublished`*/;
/*!50001 DROP VIEW IF EXISTS `process_forms_unpublished`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `process_forms_unpublished` AS select `process_forms_unpublished_tbl`.`form_id` AS `form_id`,`process_forms_unpublished_tbl`.`process_name` AS `process_name`,`process_forms_unpublished_tbl`.`table_name` AS `table_name`,`process_forms_unpublished_tbl`.`created_by` AS `created_by`,`process_forms_unpublished_tbl`.`created_on` AS `created_on`,`process_forms_unpublished_tbl`.`updated_on` AS `updated_on`,`process_forms_unpublished_tbl`.`updated_by` AS `updated_by`,`process_forms_unpublished_tbl`.`is_email_cust` AS `is_email_cust`,`process_forms_unpublished_tbl`.`is_email_bk_ofc` AS `is_email_bk_ofc`,`process_forms_unpublished_tbl`.`cust_eid` AS `cust_eid`,`process_forms_unpublished_tbl`.`bk_ofc_eid` AS `bk_ofc_eid`,`process_forms_unpublished_tbl`.`site_id` AS `site_id`,`process_forms_unpublished_tbl`.`variant` AS `variant`,`process_forms_unpublished_tbl`.`template` AS `template`,`process_forms_unpublished_tbl`.`meta_description` AS `meta_description`,`process_forms_unpublished_tbl`.`meta_keywords` AS `meta_keywords`,`process_forms_unpublished_tbl`.`form_class` AS `form_class`,`process_forms_unpublished_tbl`.`html_form_id` AS `html_form_id`,`process_forms_unpublished_tbl`.`form_method` AS `form_method`,`process_forms_unpublished_tbl`.`form_enctype` AS `form_enctype`,`process_forms_unpublished_tbl`.`form_autocomplete` AS `form_autocomplete`,`process_forms_unpublished_tbl`.`redirect_url` AS `redirect_url`,`process_forms_unpublished_tbl`.`btn_align` AS `btn_align`,`process_forms_unpublished_tbl`.`label_display` AS `label_display`,`process_forms_unpublished_tbl`.`form_width` AS `form_width`,`process_forms_unpublished_tbl`.`form_js` AS `form_js`,`process_forms_unpublished_tbl`.`type` AS `type`,`process_forms_unpublished_tbl`.`form_css` AS `form_css`,`process_forms_unpublished_tbl`.`to_publish` AS `to_publish`,`process_forms_unpublished_tbl`.`to_publish_by` AS `to_publish_by`,`process_forms_unpublished_tbl`.`to_publish_ts` AS `to_publish_ts`,`process_forms_unpublished_tbl`.`version` AS `version`,`process_forms_unpublished_tbl`.`to_unpublish` AS `to_unpublish`,`process_forms_unpublished_tbl`.`to_unpublish_by` AS `to_unpublish_by`,`process_forms_unpublished_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,`process_forms_unpublished_tbl`.`is_deleted` AS `is_deleted`,`process_forms_unpublished_tbl`.`is_sms` AS `is_sms`,`process_forms_unpublished_tbl`.`cust_sms_id` AS `cust_sms_id`,`process_forms_unpublished_tbl`.`delete_uploads` AS `delete_uploads` from `process_forms_unpublished_tbl` where `process_forms_unpublished_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `profil`
--

/*!50001 DROP TABLE IF EXISTS `profil`*/;
/*!50001 DROP VIEW IF EXISTS `profil`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `profil` AS select `cleandb_catalog`.`profil`.`profil_id` AS `profil_id`,`cleandb_catalog`.`profil`.`profil` AS `profil`,`cleandb_catalog`.`profil`.`description` AS `description`,`cleandb_catalog`.`profil`.`Archive` AS `Archive`,`cleandb_catalog`.`profil`.`bannedPhases` AS `bannedPhases`,`cleandb_catalog`.`profil`.`home_page` AS `home_page`,`cleandb_catalog`.`profil`.`color` AS `color`,`cleandb_catalog`.`profil`.`assign_site` AS `assign_site`,`cleandb_catalog`.`profil`.`is_webmaster` AS `is_webmaster` from `cleandb_catalog`.`profil` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `profilemenu`
--

/*!50001 DROP TABLE IF EXISTS `profilemenu`*/;
/*!50001 DROP VIEW IF EXISTS `profilemenu`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `profilemenu` AS select `cleandb_catalog`.`profilemenu`.`id` AS `id`,`cleandb_catalog`.`profilemenu`.`idMenu` AS `idMenu`,`cleandb_catalog`.`profilemenu`.`profile` AS `profile`,`cleandb_catalog`.`profilemenu`.`displaySeqNum` AS `displaySeqNum` from `cleandb_catalog`.`profilemenu` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `profilperson`
--

/*!50001 DROP TABLE IF EXISTS `profilperson`*/;
/*!50001 DROP VIEW IF EXISTS `profilperson`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `profilperson` AS select `cleandb_catalog`.`profilperson`.`profil_id` AS `profil_id`,`cleandb_catalog`.`profilperson`.`person_id` AS `person_id`,`cleandb_catalog`.`profilperson`.`date_debut_valid` AS `date_debut_valid`,`cleandb_catalog`.`profilperson`.`profilperson_id` AS `profilperson_id`,`cleandb_catalog`.`profilperson`.`date_fin_valid` AS `date_fin_valid` from `cleandb_catalog`.`profilperson` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `relation`
--

/*!50001 DROP TABLE IF EXISTS `relation`*/;
/*!50001 DROP VIEW IF EXISTS `relation`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `relation` AS select `cleandb_catalog`.`relation`.`pid1` AS `pid1`,`cleandb_catalog`.`relation`.`Etn_function_id` AS `Etn_function_id`,`cleandb_catalog`.`relation`.`pid2` AS `pid2`,`cleandb_catalog`.`relation`.`Date_debut_Valid` AS `Date_debut_Valid`,`cleandb_catalog`.`relation`.`relation_id` AS `relation_id`,`cleandb_catalog`.`relation`.`Date_Fin_Valid` AS `Date_Fin_Valid` from `cleandb_catalog`.`relation` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `responsibility`
--

/*!50001 DROP TABLE IF EXISTS `responsibility`*/;
/*!50001 DROP VIEW IF EXISTS `responsibility`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `responsibility` AS select `cleandb_catalog`.`responsibility`.`Person_id` AS `Person_id`,`cleandb_catalog`.`responsibility`.`Etn_function_id` AS `Etn_function_id`,`cleandb_catalog`.`responsibility`.`Entity_id` AS `Entity_id`,`cleandb_catalog`.`responsibility`.`Date_debut_Valid` AS `Date_debut_Valid`,`cleandb_catalog`.`responsibility`.`responsibility_id` AS `responsibility_id`,`cleandb_catalog`.`responsibility`.`Date_Fin_Valid` AS `Date_Fin_Valid` from `cleandb_catalog`.`responsibility` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `shortcuts`
--

/*!50001 DROP TABLE IF EXISTS `shortcuts`*/;
/*!50001 DROP VIEW IF EXISTS `shortcuts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `shortcuts` AS select `cleandb_catalog`.`shortcuts`.`id` AS `id`,`cleandb_catalog`.`shortcuts`.`name` AS `name`,`cleandb_catalog`.`shortcuts`.`url` AS `url`,`cleandb_catalog`.`shortcuts`.`created_by` AS `created_by`,`cleandb_catalog`.`shortcuts`.`site_id` AS `site_id` from `cleandb_catalog`.`shortcuts` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-05 20:21:43
