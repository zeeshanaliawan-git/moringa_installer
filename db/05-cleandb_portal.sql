-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_portal
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
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `name` varchar(25) NOT NULL,
  `paramTableName` varchar(50) DEFAULT NULL,
  `paramTableIdColumn` varchar(50) DEFAULT NULL,
  `className` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
INSERT INTO `actions` VALUES ('shell',NULL,NULL,'Shell'),('sql',NULL,NULL,'Sql'),('publish',NULL,NULL,'Publish'),('remove',NULL,NULL,'Remove');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `additional_menu_items`
--

DROP TABLE IF EXISTS `additional_menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additional_menu_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `menu_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `order_seq` int(10) DEFAULT NULL,
  `link_type` enum('social_media','language') DEFAULT NULL,
  `label` varchar(30) DEFAULT NULL,
  `default_selected` tinyint(1) NOT NULL DEFAULT 0,
  `prod_url` varchar(255) DEFAULT NULL,
  `to_menu_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `additional_menu_items`
--

LOCK TABLES `additional_menu_items` WRITE;
/*!40000 ALTER TABLE `additional_menu_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `additional_menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `algolia_indexation`
--

DROP TABLE IF EXISTS `algolia_indexation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `algolia_indexation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) NOT NULL,
  `ctype` enum('page','structuredpage','structuredcontent','offer','product','store','forum','new_product') DEFAULT NULL,
  `cid` varchar(50) NOT NULL COMMENT 'for page, product and offer this will contain the cached_page_id, for rest this column contains the content id',
  `algolia_index` varchar(255) DEFAULT NULL,
  `algolia_json` mediumtext DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `variant_id` int(11) DEFAULT NULL,
  `is_failed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `menu_id` (`menu_id`,`ctype`,`cid`,`algolia_index`,`variant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `algolia_indexation`
--

LOCK TABLES `algolia_indexation` WRITE;
/*!40000 ALTER TABLE `algolia_indexation` DISABLE KEYS */;
/*!40000 ALTER TABLE `algolia_indexation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_fields_settings`
--

DROP TABLE IF EXISTS `api_fields_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_fields_settings` (
  `api_name` varchar(25) NOT NULL,
  `field_name` varchar(75) NOT NULL,
  `field_type` varchar(25) NOT NULL,
  `is_required` tinyint(1) NOT NULL,
  PRIMARY KEY (`api_name`,`field_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_fields_settings`
--

LOCK TABLES `api_fields_settings` WRITE;
/*!40000 ALTER TABLE `api_fields_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_fields_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_tokens`
--

DROP TABLE IF EXISTS `auth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tokens` (
  `id` varchar(36) NOT NULL,
  `validator` varchar(64) NOT NULL,
  `client_uuid` varchar(36) NOT NULL,
  `expiry` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_tokens`
--

LOCK TABLES `auth_tokens` WRITE;
/*!40000 ALTER TABLE `auth_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_viewers`
--

DROP TABLE IF EXISTS `bloc_viewers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_viewers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bloc_id` int(11) unsigned NOT NULL,
  `page_uuid` varchar(36) NOT NULL,
  `client_id` varchar(50) DEFAULT NULL,
  `session_j` varchar(100) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_viewers`
--

LOCK TABLES `bloc_viewers` WRITE;
/*!40000 ALTER TABLE `bloc_viewers` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_viewers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_tasks`
--

DROP TABLE IF EXISTS `cache_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(10) NOT NULL,
  `content_type` enum('freemarker','structured','catalog','product','form','resources','cachesync') NOT NULL,
  `content_id` varchar(75) NOT NULL,
  `task` enum('generate','publish','unpublish') NOT NULL DEFAULT 'publish',
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `priority` datetime NOT NULL DEFAULT current_timestamp(),
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `attempt` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx1` (`site_id`,`content_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_tasks`
--

LOCK TABLES `cache_tasks` WRITE;
/*!40000 ALTER TABLE `cache_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cached_content`
--

DROP TABLE IF EXISTS `cached_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_content` (
  `cached_page_id` int(11) NOT NULL,
  `published_url` varchar(500) DEFAULT NULL,
  `content_type` varchar(25) DEFAULT NULL,
  `content_id` varchar(50) DEFAULT NULL,
  `published_menu_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`cached_page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cached_content`
--

LOCK TABLES `cached_content` WRITE;
/*!40000 ALTER TABLE `cached_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `cached_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `cached_content_view`
--

DROP TABLE IF EXISTS `cached_content_view`;
/*!50001 DROP VIEW IF EXISTS `cached_content_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `cached_content_view` (
  `cached_page_id` tinyint NOT NULL,
  `published_url` tinyint NOT NULL,
  `content_type` tinyint NOT NULL,
  `content_id` tinyint NOT NULL,
  `published_menu_path` tinyint NOT NULL,
  `menu_id` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `lang` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cached_pages`
--

DROP TABLE IF EXISTS `cached_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_pages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `encoded_url` text DEFAULT NULL,
  `url` text DEFAULT NULL,
  `cached` tinyint(1) NOT NULL DEFAULT 0,
  `last_loaded_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `content_type` varchar(255) DEFAULT NULL,
  `status` int(1) NOT NULL DEFAULT 0,
  `menu_id` int(11) NOT NULL DEFAULT 0,
  `filename` varchar(255) DEFAULT NULL,
  `refresh_now` tinyint(1) NOT NULL DEFAULT 0,
  `hex_eurl` varchar(100) NOT NULL,
  `menuclicked` varchar(255) DEFAULT NULL,
  `pagetype` varchar(255) DEFAULT NULL,
  `is_404_page` tinyint(1) NOT NULL DEFAULT 0,
  `crawled_attempts` int(11) DEFAULT 0,
  `is_url_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_time_url_active` tinyint(1) NOT NULL DEFAULT 0,
  `refresh_minutes` int(11) NOT NULL DEFAULT 0,
  `ptitle` varchar(255) DEFAULT NULL,
  `res_file_extension` varchar(15) DEFAULT NULL,
  `sub_level_1` varchar(255) DEFAULT NULL,
  `sub_level_2` varchar(255) DEFAULT NULL,
  `cache_uuid` varchar(36) NOT NULL DEFAULT uuid(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `url_menu` (`hex_eurl`,`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cached_pages`
--

LOCK TABLES `cached_pages` WRITE;
/*!40000 ALTER TABLE `cached_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `cached_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cached_pages_path`
--

DROP TABLE IF EXISTS `cached_pages_path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_pages_path` (
  `id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `breadcrumb` varchar(2000) DEFAULT NULL,
  `breadcrumb_changed` tinyint(1) NOT NULL DEFAULT 0,
  `file_url` varchar(500) DEFAULT NULL,
  `published_url` varchar(500) DEFAULT NULL,
  `published_menu_path` varchar(500) DEFAULT NULL,
  `content_type` varchar(25) DEFAULT NULL,
  `content_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `file_path` (`file_path`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cached_pages_path`
--

LOCK TABLES `cached_pages_path` WRITE;
/*!40000 ALTER TABLE `cached_pages_path` DISABLE KEYS */;
/*!40000 ALTER TABLE `cached_pages_path` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `call_us`
--

DROP TABLE IF EXISTS `call_us`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `call_us` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_id` varchar(50) DEFAULT NULL,
  `representative_number` varchar(45) DEFAULT NULL,
  `customer_number` varchar(45) DEFAULT NULL,
  `status` tinyint(1) NOT NULL COMMENT '0 - To be called, 1 - Call done, 2 - Not a whitelisted, 3 - Blacklised, 4 - In progress, 5 - Discarded',
  `response` varchar(255) DEFAULT NULL,
  `no_of_entries` int(1) DEFAULT 0,
  `date` datetime DEFAULT NULL,
  `priority` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `call_us`
--

LOCK TABLES `call_us` WRITE;
/*!40000 ALTER TABLE `call_us` DISABLE KEYS */;
/*!40000 ALTER TABLE `call_us` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL DEFAULT uuid(),
  `client_id` varchar(50) DEFAULT NULL,
  `session_id` varchar(100) NOT NULL,
  `identityId` varchar(25) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `surnames` varchar(100) DEFAULT NULL,
  `contactPhoneNumber1` varchar(15) NOT NULL,
  `email` varchar(64) DEFAULT NULL,
  `identityType` varchar(255) DEFAULT NULL,
  `baline1` varchar(128) DEFAULT NULL,
  `baline2` varchar(128) DEFAULT NULL,
  `batowncity` varchar(64) DEFAULT NULL,
  `bapostalCode` varchar(5) DEFAULT NULL,
  `salutation` char(4) DEFAULT '',
  `identityPhoto` varchar(50) DEFAULT NULL,
  `newPhoneNumber` varchar(15) DEFAULT NULL,
  `delivery_method` varchar(25) DEFAULT NULL,
  `selected_boutique` text DEFAULT NULL,
  `rdv_boutique` varchar(5) DEFAULT NULL,
  `rdv_date` datetime DEFAULT NULL,
  `delivery_type` varchar(50) DEFAULT NULL,
  `payment_method` varchar(25) DEFAULT NULL,
  `daline1` varchar(128) DEFAULT NULL,
  `daline2` varchar(128) DEFAULT NULL,
  `datowncity` varchar(64) DEFAULT NULL,
  `dapostalCode` varchar(5) DEFAULT NULL,
  `site_id` int(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `keepEmail` varchar(64) DEFAULT NULL,
  `sendKeepEmail` tinyint(1) DEFAULT NULL,
  `keepEmailMuid` varchar(50) DEFAULT NULL,
  `newsletter` tinyint(1) DEFAULT 0,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `promo_code` varchar(255) DEFAULT NULL,
  `session_token` varchar(50) DEFAULT NULL,
  `session_access_time` datetime NOT NULL DEFAULT current_timestamp(),
  `order_uuid` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `visited_cart_page` tinyint(1) NOT NULL DEFAULT 0,
  `incomplete_cart_mail_sent` tinyint(4) NOT NULL DEFAULT 0,
  `cart_type` enum('normal','topup','card2wallet') NOT NULL DEFAULT 'normal',
  `lang` varchar(5) DEFAULT NULL,
  `cart_step` varchar(50) DEFAULT NULL,
  `additional_info` mediumtext DEFAULT NULL,
  `idnow_uuid` varchar(36) DEFAULT NULL,
  `keepPhone` varchar(64) DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `delivery_start_hour` int(2) DEFAULT NULL,
  `delivery_start_min` int(2) DEFAULT NULL,
  `delivery_end_hour` int(2) DEFAULT NULL,
  `delivery_end_min` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_n_session` (`session_id`,`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cart_id` int(11) NOT NULL,
  `variant_id` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  `comewith_excluded` varchar(100) DEFAULT NULL,
  `delivery_fee_per_item` varchar(32) DEFAULT '',
  `comewith_variant_id` varchar(100) DEFAULT '',
  `price_per_item` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_id` (`cart_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
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
-- Table structure for table `checkout_add_info_fields`
--

DROP TABLE IF EXISTS `checkout_add_info_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkout_add_info_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `section_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'This must be lower case, without french characters or any special charactes and no white spaces. This column is important to be used in the email templates later',
  `display_name` varchar(255) NOT NULL,
  `ftype` enum('hidden','text','file') NOT NULL DEFAULT 'text',
  `file_allowed_types` varchar(500) DEFAULT NULL COMMENT 'Provide semi-colon sepearate content types allowed if field is a file',
  PRIMARY KEY (`id`),
  UNIQUE KEY `section_id` (`section_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checkout_add_info_fields`
--

LOCK TABLES `checkout_add_info_fields` WRITE;
/*!40000 ALTER TABLE `checkout_add_info_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `checkout_add_info_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `checkout_add_info_sections`
--

DROP TABLE IF EXISTS `checkout_add_info_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkout_add_info_sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'This must be lower case, without french characters or any special charactes and no white spaces. This column is important to be used in the email templates later',
  `display_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checkout_add_info_sections`
--

LOCK TABLES `checkout_add_info_sections` WRITE;
/*!40000 ALTER TABLE `checkout_add_info_sections` DISABLE KEYS */;
/*!40000 ALTER TABLE `checkout_add_info_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_favorites`
--

DROP TABLE IF EXISTS `client_favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_favorites` (
  `source_id` varchar(36) NOT NULL,
  `source_type` enum('page','product','forum') NOT NULL,
  `client_id` varchar(36) NOT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`source_id`,`source_type`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_favorites`
--

LOCK TABLES `client_favorites` WRITE;
/*!40000 ALTER TABLE `client_favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_lines`
--

DROP TABLE IF EXISTS `client_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_lines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `orange_id` varchar(100) DEFAULT NULL,
  `orange_pass` text DEFAULT NULL,
  `line_type` char(1) NOT NULL,
  `line_number` varchar(50) NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_lines`
--

LOCK TABLES `client_lines` WRITE;
/*!40000 ALTER TABLE `client_lines` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_lines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_lines_temp`
--

DROP TABLE IF EXISTS `client_lines_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_lines_temp` (
  `client_id` int(11) NOT NULL,
  `orange_id` varchar(100) DEFAULT NULL,
  `orange_pass` text DEFAULT NULL,
  `line_type` char(1) NOT NULL,
  `line_number` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_lines_temp`
--

LOCK TABLES `client_lines_temp` WRITE;
/*!40000 ALTER TABLE `client_lines_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_lines_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_prices`
--

DROP TABLE IF EXISTS `client_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_prices` (
  `product_id` int(11) NOT NULL,
  `product_variant_id` int(11) unsigned NOT NULL,
  `client_id` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_variant_id`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_prices`
--

LOCK TABLES `client_prices` WRITE;
/*!40000 ALTER TABLE `client_prices` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_profils`
--

DROP TABLE IF EXISTS `client_profils`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_profils` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profil` varchar(50) NOT NULL,
  `homepage` varchar(500) DEFAULT NULL,
  `menu_id` int(10) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_profils`
--

LOCK TABLES `client_profils` WRITE;
/*!40000 ALTER TABLE `client_profils` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_profils` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_programs`
--

DROP TABLE IF EXISTS `client_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_programs` (
  `id_client` int(11) NOT NULL,
  `program_name` varchar(255) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_client`,`program_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_programs`
--

LOCK TABLES `client_programs` WRITE;
/*!40000 ALTER TABLE `client_programs` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_reactions`
--

DROP TABLE IF EXISTS `client_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_reactions` (
  `source_id` varchar(36) NOT NULL,
  `source_type` enum('page','product','forum','form') NOT NULL,
  `client_id` varchar(36) NOT NULL,
  `is_like` tinyint(1) NOT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  `field_id` int(11) DEFAULT NULL,
  `session_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`source_id`,`source_type`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_reactions`
--

LOCK TABLES `client_reactions` WRITE;
/*!40000 ALTER TABLE `client_reactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_review_flag`
--

DROP TABLE IF EXISTS `client_review_flag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_review_flag` (
  `post_id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`post_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_review_flag`
--

LOCK TABLES `client_review_flag` WRITE;
/*!40000 ALTER TABLE `client_review_flag` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_review_flag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_review_reactions`
--

DROP TABLE IF EXISTS `client_review_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_review_reactions` (
  `post_id` varchar(36) NOT NULL,
  `client_id` varchar(36) NOT NULL,
  `is_like` tinyint(1) NOT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`post_id`,`client_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_review_reactions`
--

LOCK TABLES `client_review_reactions` WRITE;
/*!40000 ALTER TABLE `client_review_reactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_review_reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_review_tags`
--

DROP TABLE IF EXISTS `client_review_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_review_tags` (
  `tag_id` varchar(36) NOT NULL,
  `post_id` varchar(36) NOT NULL,
  PRIMARY KEY (`tag_id`,`post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_review_tags`
--

LOCK TABLES `client_review_tags` WRITE;
/*!40000 ALTER TABLE `client_review_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_review_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_reviews`
--

DROP TABLE IF EXISTS `client_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_reviews` (
  `post_id` varchar(36) NOT NULL DEFAULT uuid(),
  `source_id` varchar(36) DEFAULT NULL,
  `source_type` enum('page','product','forum') NOT NULL,
  `post_parent_id` varchar(36) DEFAULT NULL,
  `client_id` varchar(36) NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  `type` enum('comment','forum','review') NOT NULL DEFAULT 'comment',
  `category` text DEFAULT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  `rating` int(11) DEFAULT 0,
  `content` text DEFAULT NULL,
  `org_reply` text DEFAULT NULL,
  `org_reply_date` datetime DEFAULT NULL,
  `org_reply_by` varchar(36) DEFAULT NULL,
  `moderation_score` decimal(6,2) DEFAULT NULL,
  `sentiment_score` decimal(6,2) DEFAULT NULL,
  `nb_likes` int(11) NOT NULL DEFAULT 0,
  `nb_dislikes` int(11) NOT NULL DEFAULT 0,
  `is_pinned` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `verification_type` varchar(255) DEFAULT NULL,
  `verified_transection` varchar(255) DEFAULT NULL,
  `verification_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `forum_topic` text DEFAULT NULL,
  `last_coment_date` datetime DEFAULT NULL,
  `last_coment_by` varchar(36) DEFAULT NULL,
  `is_signaled` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`post_id`),
  UNIQUE KEY `post_id` (`post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_reviews`
--

LOCK TABLES `client_reviews` WRITE;
/*!40000 ALTER TABLE `client_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_usage_logs`
--

DROP TABLE IF EXISTS `client_usage_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `user_agent` text DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `site_id` int(10) DEFAULT NULL,
  KEY `activity_from` (`activity_from`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_usage_logs`
--

LOCK TABLES `client_usage_logs` WRITE;
/*!40000 ALTER TABLE `client_usage_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_usage_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  `mobile_number` varchar(25) DEFAULT NULL,
  `pass` text DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `last_login_on` datetime DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_super_user` tinyint(1) NOT NULL DEFAULT 0,
  `first_time_pass` varchar(15) DEFAULT NULL,
  `first_pass_sent` tinyint(1) NOT NULL DEFAULT 0,
  `client_uuid` varchar(75) DEFAULT NULL,
  `profil` varchar(50) DEFAULT NULL,
  `forgot_password` tinyint(1) NOT NULL DEFAULT 0,
  `forgot_pass_token` varchar(36) DEFAULT NULL,
  `forgot_pass_token_expiry` datetime DEFAULT NULL,
  `forgot_pass_muid` varchar(36) DEFAULT NULL,
  `client_profil_id` int(11) DEFAULT NULL,
  `additional_info` mediumtext DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `verification_token` varchar(36) DEFAULT NULL,
  `verification_token_expiry` datetime DEFAULT NULL,
  `send_verification_email` tinyint(1) NOT NULL DEFAULT 0,
  `signup_menu_uuid` varchar(36) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `form_row_id` int(11) DEFAULT NULL,
  `avatar` text DEFAULT NULL,
  `civility` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_client` (`username`,`site_id`),
  UNIQUE KEY `client_uuid` (`client_uuid`),
  KEY `idx1` (`site_id`,`form_row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `co_form_fields`
--

DROP TABLE IF EXISTS `co_form_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `co_form_fields` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `co_form_id` int(11) DEFAULT NULL,
  `co_field_name` varchar(255) DEFAULT NULL,
  `co_field_display_name` varchar(255) DEFAULT NULL,
  `co_field_type` varchar(15) DEFAULT NULL,
  `co_field_length` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `co_form_fields`
--

LOCK TABLES `co_form_fields` WRITE;
/*!40000 ALTER TABLE `co_form_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `co_form_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `co_form_settings`
--

DROP TABLE IF EXISTS `co_form_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `co_form_settings` (
  `site_id` varchar(255) NOT NULL DEFAULT '',
  `co_field_json` text DEFAULT NULL,
  `co_msg_receipt` varchar(255) DEFAULT NULL,
  `co_order_ref_label` varchar(255) DEFAULT NULL,
  `co_order_date_label` varchar(255) DEFAULT NULL,
  `co_total_amount_label` varchar(255) DEFAULT NULL,
  `co_show_order_detail` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `co_form_settings`
--

LOCK TABLES `co_form_settings` WRITE;
/*!40000 ALTER TABLE `co_form_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `co_form_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) NOT NULL,
  `val` mediumtext DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('AUTO_REFRESH_SYNC_SCRIPT','/home/asimina/pjt/asimina_engines/portal/copyautorefreshcontent.sh',''),('BASE_DIR','/home/asimina/tomcat/webapps/asimina_portal/','This is used in cleandb_portal so do not update for cleandb_menu'),('BASE_DIR_MENU_DESIGNER','/home/asimina/tomcat/webapps/asimina_menu/','This is used in cleandb_portal so do not update for cleandb_menu'),('basic_auth_realm','asimina-test-site',NULL),('BILL_TRACKING_JSP','/cart/defaultTrackingBill.jsp','Set appropriate path for each country if required'),('CACHE_EXTERNAL_LINK','/asimina_portal/sites/',NULL),('CACHE_FOLDER','/home/asimina/tomcat/webapps/asimina_portal/sites/',NULL),('CACHE_REDIRECT_URL','http://127.0.0.1/asimina_portal/sites/',''),('CALL_BACK_API_SHELL_SCRIPT','/home/asimina/tomcat/webapps/asimina_portal/APICallBack/',NULL),('CART_COOKIE','asimina_catalogCartItems',NULL),('CART_EXTERNAL_LINK','/asimina_portal/cart/',NULL),('CART_URL','/asimina_portal/',NULL),('CATALOG_DB','cleandb_catalog',NULL),('CATALOG_LINK','/asimina_catalog/',NULL),('CATALOG_ROOT','/asimina_catalog',NULL),('CATALOG_WEBAPP_URL','/asimina_catalog/',''),('CHECKOUT_JSP','/cart/personalinfo.jsp',NULL),('COMMONS_DB','cleandb_commons',NULL),('COMMON_RESOURCES_PATH','/home/asimina/tomcat/webapps/asimina_pages/uploads/',''),('COMMON_RESOURCES_URL','/asimina_pages/uploads/','Path where all local resources are uploaded. Cache will not cache these'),('COPY_FOLDER_CONTENTS_SCRIPT','/home/asimina/pjt/asimina_engines/portal/copyfoldercontents.sh',''),('COPY_SCRIPT','/home/asimina/pjt/asimina_engines/portal/copyfile.sh',''),('CRAWLER_SCRIPT','/home/asimina/pjt/asimina_engines/portal/preprodcrawler.sh',NULL),('CROSS_SITE_APPS_URL','/asimina_pages/pages/;/asimina_forms/;/asimina_catalog/;/asimina_prodcatalog/',NULL),('CSS_CUSTOMIZER_SCRIPT','/home/asimina/tomcat/webapps/asimina_menu/pages/customcss/customizecss.sh',NULL),('CUSTOM_CSS_TEMPLATE_PATH','/home/asimina/tomcat/webapps/asimina_menu/pages/customcss/',NULL),('DEBUG','Oui',''),('DELETE_FILE_SCRIPT','/home/asimina/pjt/asimina_engines/portal/deletefile.sh',''),('DELETE_INACTIVE_HTML_FILES_SCRIPT','/home/asimina/pjt/asimina_engines/portal/deleteinactivefiles.sh',''),('DEPTH_CONSTRAINT','','Example : 5,http://www.view360client.com;3,https://www.view360client.com'),('DOWNLOAD_PAGES_FOLDER','sites/',NULL),('DYNAMIC_PAGES','',NULL),('empty_service_id','',NULL),('ESHOP_FRAUD_JSP','/cart/default_error_fraud.jsp','configure this for your shop'),('ESHOP_SERVER_ERROR_JSP','/cart/default_error_server.jsp','configure this for your shop'),('EXTERNAL_LINK','/asimina_portal/',NULL),('FORMS_WEBAPP_URL','/asimina_forms/',''),('funnel_documents_base_dir','/home/asimina/tomcat/webapps/asimina_shop/uploads/',NULL),('funnel_documents_base_url','/asimina_shop/uploads/',NULL),('GENERIC_FORM_DEFAULT_PHASE','formsubmitted',NULL),('GENERIC_FORM_DEFAULT_PROCESS','genericforms',NULL),('GOTO_MENU_APP_URL','/asimina_catalog/admin/gotomenuapp.jsp',NULL),('IDCHECK_BROKER','',NULL),('IDCHECK_CLIENT_ID','',NULL),('IDCHECK_END_POINT','',NULL),('IDCHECK_GET_TOKEN_END_POINT','',NULL),('IDCHECK_GRANT_TYPE','',NULL),('IDCHECK_PASSWORD','',NULL),('IDCHECK_USERNAME','',NULL),('IDNOW_CIS_BASE_URL','https://api-test.ariadnext.com/gw/cis/',NULL),('IGNORE_RELATIVE_URLS','/asimina_ckeditor/sites/;/asimina_pages/pages/','This is used by process.jsp to know which relative url must go through the process.jsp'),('ignore_urls_for_encode','http://90.84.199.234',NULL),('INTERNAL_API_URLS','/api/;/asimina_portal/api/','Semi colon separated list of internal api urls. Internal APIs is always in portal and not in prodportal'),('INTERNAL_CALL_LINK','http://127.0.0.1',''),('IS_PRODUCTION_ENV','0',NULL),('LOCAL_LINK','http://127.0.0.1/asimina_portal/',NULL),('LOGGER_LEVEL','info',NULL),('MAIL_FROM','noreply@eboutique.com',''),('MAIL_FROM_DISPLAY_NAME','Asimina',''),('MAIL_REPLY','noreply@eboutique.com',''),('MENU_IMAGES_FOLDER','/home/asimina/tomcat/webapps/asimina_portal/menu_resources/uploads/',NULL),('MENU_IMAGES_PATH','/menu_resources/uploads/',NULL),('MORINGA_MENU_EXTERNAL_LINK','/asimina_menu/',NULL),('NO_CACHE_JS','/asimina_portal/js/contactus.js',NULL),('NO_PROCESS_JS','/asimina_pages/;/asimina_catalog/js/o_share_bar.js;/asimina_forms/js/html_form_template.js;/asimina_forms/js/triggers.js;/asimina_catalog/js/nocache/;/asimina_catalog/js/fullcalendar.min.js;/asimina_catalog/js/newui/',NULL),('PAGES_WEBAPP_URL','/asimina_pages/',''),('PASS_LANG_URLS','http://127.0.0.1/asimina_catalog/;http://127.0.0.1/asimina_forms/',NULL),('payment_return_jsp','payment.jsp','configure this for your shop'),('PORTAL_CONTEXTPATH','/asimina_portal/',NULL),('PORTAL_LINK','/asimina_portal',NULL),('PORTAL_SEARCH_SHELL_SCRIPT','/home/asimina/tomcat/webapps/asimina_portal/script/',NULL),('PREPROD_CART_URL','https://portail-moringa.com/asimina_portal/cart/cart.jsp','External url of cart'),('PREPROD_CSS_FINAL_PATH','/home/asimina/tomcat/webapps/asimina_portal/menu_resources/css/',NULL),('PREPROD_FORGOT_PASS_URL','http://90.84.199.234/asimina_portal/pages/resetpass.jsp',''),('PREPROD_MENU_RESOURCES_URL','/asimina_portal/menu_resources/',''),('PRODUCTS_IMG_PATH','/asimina_catalog/uploads/products/',NULL),('PRODUCTS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/products/',NULL),('PROD_CACHE_EXTERNAL_LINK','/asimina_prodportal/sites/',NULL),('PROD_CACHE_FOLDER','/home/asimina/tomcat/webapps/asimina_prodportal/sites/',NULL),('PROD_CACHE_REDIRECT_URL','http://127.0.0.1/asimina_prodportal/sites/',''),('PROD_CART_URL','https://portail-moringa.com/asimina_prodportal/cart/cart.jsp','External url of cart'),('PROD_CATALOG_DB','cleandb_prod_catalog',''),('PROD_CATALOG_WEBAPP_URL','/asimina_prodcatalog/',''),('PROD_CSS_FINAL_PATH','/home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/css/',NULL),('PROD_DB','cleandb_prod_portal',NULL),('PROD_DOWNLOAD_PAGES_FOLDER','sites/',''),('PROD_EXTERNAL_LINK','/asimina_prodportal/',NULL),('PROD_FORGOT_PASS_URL','http://90.84.199.234/asimina_prodportal/pages/resetpass.jsp',''),('PROD_MENU_IMAGES_FOLDER','/home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/uploads/',''),('PROD_MENU_JS_PATH','/home/asimina/tomcat/webapps/asimina_prodportal/mjs/',''),('PROD_MENU_PHOTO_URL','/asimina_prodportal/menu_resources/uploads/',''),('PROD_MENU_RESOURCES_IMG_URL','/asimina_prodportal/menu_resources/img/',''),('PROD_MENU_RESOURCES_PATH','/home/asimina/tomcat/webapps/asimina_prodportal/menu_resources/',''),('PROD_MENU_RESOURCES_URL','/asimina_prodportal/menu_resources/',''),('PROD_PORTAL_ENTRY_URL','/','Its the url set in ____portalurl2 at time of caching'),('PROD_PUBLISHER_SEND_REDIRECT_LINK','/asimina_prodportal/publishsites/',''),('PROD_RELOAD_SINGLETONS_INTERNAL_URL','http://127.0.0.1/asimina_prodportal/reloadSingletons.jsp','Used by engine at time of publishing the site'),('PROD_SEND_REDIRECT_LINK','/',NULL),('PROD_SEPARATE_FOLDER_CACHE_REDIRECT_URL','http://127.0.0.1/asimina_prodportal/publishsites/',''),('PROD_SITEMAP_CALL_LINK','/asimina_prodportal/sites',''),('PROD_SITEMAP_XML_PATH','/home/asimina/tomcat/webapps/asimina_prodportal/generatedSitemap/',''),('PROD_USER_VERIFICATION_URL','http://90.84.199.234/asimina_prodportal/pages/verify.jsp',NULL),('PROXY_PREFIX','/asimina_prodportal/sites','When in production we have urls like /particuliars /business which are then routed to /2/sites/particuliar /2/sites/business ... so in that case the redirections added must be checked along with proxy prefix'),('PUBLISHER_BASE_DIR','/home/asimina/tomcat/webapps/asimina_portal/',NULL),('PUBLISHER_DOWNLOAD_PAGES_FOLDER','publishsites/',NULL),('PUBLISHER_PROD_BASE_DIR','/home/asimina/tomcat/webapps/asimina_prodportal/',''),('PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER','publishsites/',''),('PUBLISHER_SEND_REDIRECT_LINK','/asimina_portal/publishsites/',NULL),('PUBLISH_RESOURCES_FOLDER_SCRIPT','/home/asimina/pjt/asimina_engines/portal/copyresources.sh',NULL),('qrcodes_dir','/home/asimina/pjt/asimina_engines/selfcare/qrcodes/',NULL),('RENAME_FILE_SCRIPT','/home/asimina/pjt/asimina_engines/portal/renamefile.sh',''),('SELFCARE_DEBUG','Oui',''),('SELFCARE_WAIT_TIMEOUT','300',''),('SEMAPHORE','D002',NULL),('SEND_FORGOT_PASS_SMS','0',''),('SEND_REDIRECT_LINK','/asimina_portal/sites/',NULL),('SEND_SESSION_PARAMS','http://127.0.0.1/asimina_expert_system/',NULL),('SEPARATE_FOLDER_CACHE_REDIRECT_URL','http://127.0.0.1/asimina_portal/publishsites/',''),('SHELL_DIR','/home/asimina/pjt/asimina_engines/portal/bin',''),('SHOP_DB','cleandb_shop',NULL),('SHOP_SEMAPHORE','D005',NULL),('SITEMAP_SEND_REDIRECT_LINK','/asimina_portal/sites/',NULL),('SITE_MAP_RENAME_SCRIPT_PATH','/home/asimina/tomcat/webapps/asimina_menu/pages/sitemap/',NULL),('SMART_BANNER_ICON_URL','/asimina_prodportal/img/smartbanner/',NULL),('sso_app_id','',NULL),('SUPER_USER_REG_FORM_URL','',NULL),('SYNC_RESOURCES_FOLDER_SCRIPT','/home/asimina/pjt/asimina_engines/portal/syncresources.sh',NULL),('SYNC_SECOND_SERVER','0',''),('SYNC_TRIGGER_SCRIPT','',''),('UPLOADS_FOLDER','uploads/',NULL),('URL_GENERATOR','/asimina_catalog/admin/urlgenerator.jsp',NULL),('URL_REPLACE_SCRIPT','/home/asimina/pjt/asimina_engines/portal/replaceurl.sh',''),('USER_VERIFICATION_URL','/asimina_portal/pages/verify.jsp',NULL),('VALID_404_URLS','',NULL),('VARIANT_IMAGE_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_shop/variant_images/','for shop'),('WAIT_TIMEOUT','300','');
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_us`
--

DROP TABLE IF EXISTS `contact_us`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_us` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` char(4) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `surname` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `form_type` enum('b2c','b2b','vaspartner','sponsoring') NOT NULL DEFAULT 'b2c',
  `email_sent` tinyint(1) NOT NULL DEFAULT 0,
  `email_tries` int(10) NOT NULL DEFAULT 0,
  `lang` varchar(2) NOT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `partner_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `orig_filename` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_us`
--

LOCK TABLES `contact_us` WRITE;
/*!40000 ALTER TABLE `contact_us` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_us` ENABLE KEYS */;
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
  `process` varchar(16) NOT NULL,
  `profile` varchar(30) NOT NULL,
  `phase` varchar(32) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coordinates`
--

LOCK TABLES `coordinates` WRITE;
/*!40000 ALTER TABLE `coordinates` DISABLE KEYS */;
INSERT INTO `coordinates` VALUES (61,73,120,80,'menus','ADMIN','publish'),(11,11,738,500,'menus','ADMIN',NULL),(486,75,120,80,'menus','ADMIN','published'),(57,305,120,80,'menus','ADMIN','delete'),(514,303,120,80,'menus','ADMIN','deleted'),(292,372,120,80,'menus','ADMIN','cancel'),(732,538,300,500,'menus','PROD_CACHE_MGMT',NULL),(1151,540,300,500,'menus','PROD_PUBLISH',NULL),(61,73,120,80,'breadcrumbs','ADMIN','publish'),(11,11,738,500,'breadcrumbs','ADMIN',NULL),(486,75,120,80,'breadcrumbs','ADMIN','published'),(280,274,120,80,'breadcrumbs','ADMIN','cancel'),(732,538,300,500,'breadcrumbs','PROD_CACHE_MGMT',NULL),(1151,540,300,500,'breadcrumbs','PROD_PUBLISH',NULL);
/*!40000 ALTER TABLE `coordinates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crawler_audit`
--

DROP TABLE IF EXISTS `crawler_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crawler_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` int(1) NOT NULL DEFAULT 0,
  `action` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawler_audit`
--

LOCK TABLES `crawler_audit` WRITE;
/*!40000 ALTER TABLE `crawler_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `crawler_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crawler_errors`
--

DROP TABLE IF EXISTS `crawler_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crawler_errors` (
  `menu_id` int(11) NOT NULL,
  `err` varchar(255) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawler_errors`
--

LOCK TABLES `crawler_errors` WRITE;
/*!40000 ALTER TABLE `crawler_errors` DISABLE KEYS */;
/*!40000 ALTER TABLE `crawler_errors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crawler_indexation`
--

DROP TABLE IF EXISTS `crawler_indexation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crawler_indexation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) NOT NULL,
  `ctype` enum('page','structuredpage','structuredcontent','offer','product','store','forum','productv2','new_product') DEFAULT NULL,
  `cid` varchar(50) NOT NULL COMMENT 'for page, product and offer this will contain the cached_page_id, for rest this column contains the content id',
  `applicable_algolia_index` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawler_indexation`
--

LOCK TABLES `crawler_indexation` WRITE;
/*!40000 ALTER TABLE `crawler_indexation` DISABLE KEYS */;
/*!40000 ALTER TABLE `crawler_indexation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crawler_paths`
--

DROP TABLE IF EXISTS `crawler_paths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crawler_paths` (
  `menu_id` int(11) NOT NULL,
  `parent_page_id` int(11) NOT NULL,
  `page_id` int(11) NOT NULL,
  `is_menu_link` tinyint(1) NOT NULL DEFAULT 0,
  `is_homepage_link` tinyint(1) NOT NULL DEFAULT 0,
  `is_404` tinyint(1) NOT NULL DEFAULT 0,
  `page_level` int(10) NOT NULL,
  `react_page_id` varchar(10) DEFAULT NULL,
  `is_user_homepage` tinyint(1) NOT NULL DEFAULT 0,
  `is_page_link` tinyint(1) NOT NULL DEFAULT 0,
  KEY `menu_id` (`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crawler_paths`
--

LOCK TABLES `crawler_paths` WRITE;
/*!40000 ALTER TABLE `crawler_paths` DISABLE KEYS */;
/*!40000 ALTER TABLE `crawler_paths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_css`
--

DROP TABLE IF EXISTS `custom_css`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_css` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) NOT NULL,
  `element_id` varchar(100) NOT NULL,
  `tag` varchar(255) NOT NULL,
  `css` text DEFAULT NULL,
  `value` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_css`
--

LOCK TABLES `custom_css` WRITE;
/*!40000 ALTER TABLE `custom_css` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_css` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_pages`
--

DROP TABLE IF EXISTS `dynamic_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cached_page_id` int(11) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_pages`
--

LOCK TABLES `dynamic_pages` WRITE;
/*!40000 ALTER TABLE `dynamic_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_pages` ENABLE KEYS */;
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
INSERT INTO `errcode` VALUES (0,'','success','success','#00ff00');
/*!40000 ALTER TABLE `errcode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_phases`
--

DROP TABLE IF EXISTS `external_phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_phases` (
  `start_proc` varchar(16) NOT NULL,
  `next_proc` varchar(16) NOT NULL,
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
-- Table structure for table `failed_urls`
--

DROP TABLE IF EXISTS `failed_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_urls` (
  `domain` varchar(255) DEFAULT NULL,
  `encoded_url` varchar(255) NOT NULL,
  `failed_url` varchar(255) NOT NULL,
  `attempt` int(10) NOT NULL DEFAULT 1,
  `menu_id` int(10) unsigned NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_urls`
--

LOCK TABLES `failed_urls` WRITE;
/*!40000 ALTER TABLE `failed_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faq_stats`
--

DROP TABLE IF EXISTS `faq_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faq_stats` (
  `url` varchar(255) NOT NULL,
  `menu_uuid` varchar(36) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `ourl` varchar(255) DEFAULT NULL,
  `count_yes` int(11) DEFAULT 0,
  `count_no` int(11) DEFAULT 0,
  `update_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`url`,`menu_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faq_stats`
--

LOCK TABLES `faq_stats` WRITE;
/*!40000 ALTER TABLE `faq_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `faq_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(300) NOT NULL,
  `file_uuid` varchar(50) NOT NULL DEFAULT '',
  `file_extension` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` text DEFAULT NULL,
  `hex_name` varchar(255) DEFAULT NULL,
  `name2` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`hex_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders`
--

LOCK TABLES `folders` WRITE;
/*!40000 ALTER TABLE `folders` DISABLE KEYS */;
/*!40000 ALTER TABLE `folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generic_forms`
--

DROP TABLE IF EXISTS `generic_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_forms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_name` text DEFAULT NULL,
  `form_data` mediumtext DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(255) DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT 0,
  `email_tries` int(11) NOT NULL DEFAULT 0,
  `muid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generic_forms`
--

LOCK TABLES `generic_forms` WRITE;
/*!40000 ALTER TABLE `generic_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `generic_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `has_action`
--

DROP TABLE IF EXISTS `has_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `has_action` (
  `start_proc` varchar(16) NOT NULL,
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
INSERT INTO `has_action` VALUES ('menus','publish',1,'publish:menu'),('menus','delete',2,'remove:menu'),('breadcrumbs','publish',5,'publish:breadcrumbs');
/*!40000 ALTER TABLE `has_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idcheck_access_tokens`
--

DROP TABLE IF EXISTS `idcheck_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idcheck_access_tokens` (
  `token` varchar(255) NOT NULL,
  `access_token` text NOT NULL,
  `access_token_expires_in` datetime NOT NULL,
  `refresh_token` text NOT NULL,
  `refresh_token_expires_in` datetime NOT NULL,
  `token_type` varchar(100) NOT NULL,
  `link_sent` tinyint(1) NOT NULL DEFAULT 0,
  `idnow_uuid` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idcheck_access_tokens`
--

LOCK TABLES `idcheck_access_tokens` WRITE;
/*!40000 ALTER TABLE `idcheck_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `idcheck_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idcheck_config_wordings`
--

DROP TABLE IF EXISTS `idcheck_config_wordings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idcheck_config_wordings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_id` int(11) NOT NULL,
  `home_title` varchar(30) NOT NULL,
  `home_msg` varchar(150) NOT NULL,
  `auth_input_msg` varchar(30) DEFAULT NULL,
  `auth_help_msg` varchar(150) DEFAULT NULL,
  `error_msg` varchar(150) DEFAULT NULL,
  `onboarding_end_msg` varchar(150) DEFAULT NULL,
  `expired_msg` varchar(150) DEFAULT NULL,
  `link_email_subject` varchar(150) DEFAULT NULL,
  `link_email_msg` text DEFAULT NULL,
  `link_email_signat` text DEFAULT NULL,
  `link_sms_msg` varchar(120) DEFAULT NULL,
  `langue_code` varchar(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uc_key` (`config_id`,`langue_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idcheck_config_wordings`
--

LOCK TABLES `idcheck_config_wordings` WRITE;
/*!40000 ALTER TABLE `idcheck_config_wordings` DISABLE KEYS */;
/*!40000 ALTER TABLE `idcheck_config_wordings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idcheck_configurations`
--

DROP TABLE IF EXISTS `idcheck_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idcheck_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `site_id` int(10) unsigned NOT NULL,
  `path_name` varchar(20) NOT NULL,
  `support_email` varchar(100) DEFAULT NULL,
  `link_validity` varchar(100) DEFAULT NULL,
  `email_sender_name` varchar(30) DEFAULT NULL,
  `block_upload` tinyint(1) NOT NULL DEFAULT 0,
  `capture_desktop` enum('CAMERA','PROMPT','UPLOAD') DEFAULT NULL,
  `capture_mobile` enum('CAMERA','PROMPT','UPLOAD') DEFAULT NULL,
  `prompt_mobile` tinyint(1) NOT NULL DEFAULT 0,
  `image_blk_whe_chk` tinyint(1) NOT NULL DEFAULT 0,
  `image_qty_chk` tinyint(1) NOT NULL DEFAULT 0,
  `logo` varchar(255) DEFAULT NULL,
  `title_txt_color` varchar(7) DEFAULT NULL,
  `header_bg_color` varchar(7) DEFAULT NULL,
  `btn_bg_color` varchar(7) DEFAULT NULL,
  `btn_hover_bg_color` varchar(7) DEFAULT NULL,
  `btn_txt_color` varchar(7) DEFAULT NULL,
  `btn_border_rad` varchar(7) DEFAULT NULL,
  `hide_head_border` tinyint(1) NOT NULL DEFAULT 0,
  `head_logo_align` enum('LEFT','RIGHT','CENTER') DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `bloc_uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uc_site` (`site_id`),
  UNIQUE KEY `uc_code` (`code`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idcheck_configurations`
--

LOCK TABLES `idcheck_configurations` WRITE;
/*!40000 ALTER TABLE `idcheck_configurations` DISABLE KEYS */;
/*!40000 ALTER TABLE `idcheck_configurations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idcheck_doc_capture_conf`
--

DROP TABLE IF EXISTS `idcheck_doc_capture_conf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idcheck_doc_capture_conf` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idcheck_iframe_conf_id` int(11) NOT NULL,
  `capture_code` varchar(255) NOT NULL,
  `doc_type` varchar(255) DEFAULT NULL,
  `optional` tinyint(1) NOT NULL DEFAULT 0,
  `verso_handling` enum('DEFAULT','MANDATORY','OPTIONAL') DEFAULT NULL,
  `liveness_ref_location` enum('ONBOARDING','CIS') DEFAULT NULL,
  `liveness_ref_value` varchar(255) DEFAULT NULL,
  `with_doc_liveness` tinyint(1) NOT NULL DEFAULT 0,
  `liveness_label` varchar(255) DEFAULT NULL,
  `liveness_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `capture_code` (`capture_code`,`idcheck_iframe_conf_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idcheck_doc_capture_conf`
--

LOCK TABLES `idcheck_doc_capture_conf` WRITE;
/*!40000 ALTER TABLE `idcheck_doc_capture_conf` DISABLE KEYS */;
/*!40000 ALTER TABLE `idcheck_doc_capture_conf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idcheck_iframe_conf`
--

DROP TABLE IF EXISTS `idcheck_iframe_conf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idcheck_iframe_conf` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `site_id` int(10) NOT NULL,
  `success_redirect_url` varchar(255) DEFAULT NULL,
  `error_redirect_url` varchar(255) DEFAULT NULL,
  `auto_redirect` tinyint(1) NOT NULL DEFAULT 0,
  `notification_type` enum('EMAIL','PHONE','NONE') DEFAULT NULL,
  `notification_value` varchar(255) DEFAULT NULL,
  `realm` varchar(255) DEFAULT NULL,
  `fileUid` varchar(255) DEFAULT NULL,
  `file_launch_check` tinyint(1) NOT NULL DEFAULT 0,
  `file_check_wait` tinyint(1) NOT NULL DEFAULT 0,
  `file_tags` varchar(255) DEFAULT NULL,
  `ident_code` varchar(255) DEFAULT NULL,
  `iframe_display` tinyint(1) NOT NULL DEFAULT 0,
  `iframe_redirect_parent` tinyint(1) NOT NULL DEFAULT 0,
  `biometric_consent` tinyint(1) NOT NULL DEFAULT 0,
  `legal_hide_link` tinyint(1) NOT NULL DEFAULT 0,
  `legal_external_link` varchar(255) DEFAULT NULL,
  `iframe_capt_mode_desk` enum('CAMERA','UPLOAD','PROMPT') DEFAULT NULL,
  `iframe_capt_mode_mob` enum('CAMERA','UPLOAD','PROMPT') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idcheck_iframe_conf`
--

LOCK TABLES `idcheck_iframe_conf` WRITE;
/*!40000 ALTER TABLE `idcheck_iframe_conf` DISABLE KEYS */;
/*!40000 ALTER TABLE `idcheck_iframe_conf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idnow_sessions`
--

DROP TABLE IF EXISTS `idnow_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idnow_sessions` (
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `idnow_uid` varchar(36) NOT NULL,
  `resp` longtext DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `resp_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `iframe_url_json` mediumtext DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idnow_sessions`
--

LOCK TABLES `idnow_sessions` WRITE;
/*!40000 ALTER TABLE `idnow_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `idnow_sessions` ENABLE KEYS */;
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
-- Table structure for table `menu_apply_to`
--

DROP TABLE IF EXISTS `menu_apply_to`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_apply_to` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `menu_id` int(10) unsigned NOT NULL,
  `apply_type` enum('url','url_starting_with','drupal_pages','db_pages') NOT NULL,
  `apply_to` varchar(255) NOT NULL,
  `replace_tags` varchar(255) DEFAULT NULL,
  `prod_apply_to` varchar(255) DEFAULT NULL,
  `cache` int(1) NOT NULL DEFAULT 0,
  `cache_refresh_interval` int(11) NOT NULL DEFAULT 0,
  `cache_refresh_on` varchar(5) DEFAULT NULL,
  `add_gtm_script` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_apply_to`
--

LOCK TABLES `menu_apply_to` WRITE;
/*!40000 ALTER TABLE `menu_apply_to` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_apply_to` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_click_rules`
--

DROP TABLE IF EXISTS `menu_click_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_click_rules` (
  `menu_id` int(11) unsigned NOT NULL,
  `menu_apply_to_id` int(11) unsigned NOT NULL,
  `parent_tag` varchar(15) NOT NULL,
  `parent_tag_attr` varchar(255) DEFAULT NULL,
  `target_tag` varchar(15) NOT NULL,
  `target_tag_attr` varchar(100) DEFAULT NULL,
  `target_tag_word` varchar(255) DEFAULT NULL,
  `click_type` enum('new_tab','do_nothing') NOT NULL DEFAULT 'new_tab',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_click_rules`
--

LOCK TABLES `menu_click_rules` WRITE;
/*!40000 ALTER TABLE `menu_click_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_click_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `menu_id` int(10) unsigned NOT NULL,
  `menu_item_id` int(10) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `default_selected` tinyint(1) NOT NULL DEFAULT 0,
  `menu_photo` varchar(75) DEFAULT NULL,
  `menu_photo_text` varchar(255) DEFAULT NULL,
  `menu_photo_tag_line` varchar(255) DEFAULT NULL,
  `is_external_link` tinyint(1) NOT NULL DEFAULT 0,
  `order_seq` int(11) DEFAULT NULL,
  `seo_keywords` text DEFAULT NULL,
  `seo_description` text DEFAULT NULL,
  `prod_url` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `display_in_footer` tinyint(1) NOT NULL DEFAULT 1,
  `footer_display_name` varchar(255) DEFAULT NULL,
  `open_as` enum('new_tab','new_window','same_window') NOT NULL DEFAULT 'same_window',
  `visible_to` varchar(25) DEFAULT NULL,
  `display_in_header` tinyint(1) NOT NULL DEFAULT 1,
  `is_right_align` tinyint(1) DEFAULT 0 COMMENT 'This field will only be effective for header level 1 menu items. For languages rtl like arabic or urdu right_align means it will be left align actually',
  `link_label` varchar(255) DEFAULT NULL COMMENT 'This label will only be shown if a link is added to level -20 item or its immediate child so we will add special links for it in new ui',
  `menu_icon` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menus` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `template_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `variant` enum('all','logged','anonymous') NOT NULL,
  `template_data` mediumtext NOT NULL,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `published_ts` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `published_by` int(11) DEFAULT NULL,
  `to_generate` tinyint(1) NOT NULL DEFAULT 0,
  `to_generate_by` int(11) DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` int(11) DEFAULT NULL,
  `to_publish_ts` datetime DEFAULT NULL,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` int(11) DEFAULT NULL,
  `to_unpublish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
  `publish_log` mediumtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
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
  `process` varchar(16) NOT NULL,
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
INSERT INTO `phases` VALUES ('menus','publish',96,64,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('menus','published',314,89,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('menus','delete',117,268,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from prod','ADMIN','R','O'),('menus','deleted',303,259,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('menus','cancel',291,371,NULL,NULL,'','','','','',NULL,'',1,1,'cancel','ADMIN','R','O'),('breadcrumbs','cancel',291,371,NULL,NULL,'','','','','',NULL,'',1,1,'cancel','ADMIN','R','O'),('breadcrumbs','publish',96,64,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('breadcrumbs','published',314,89,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O');
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
  `proces` varchar(16) NOT NULL,
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
-- Table structure for table `purge_pages`
--

DROP TABLE IF EXISTS `purge_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purge_pages` (
  `page_path` varchar(500) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purge_pages`
--

LOCK TABLES `purge_pages` WRITE;
/*!40000 ALTER TABLE `purge_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `purge_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `redirects`
--

DROP TABLE IF EXISTS `redirects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `redirects` (
  `old_url` text DEFAULT NULL,
  `new_url` text DEFAULT NULL,
  `one_to_one` tinyint(1) NOT NULL DEFAULT 1,
  `menu_type` varchar(10) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `redirects`
--

LOCK TABLES `redirects` WRITE;
/*!40000 ALTER TABLE `redirects` DISABLE KEYS */;
/*!40000 ALTER TABLE `redirects` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `representative`
--

DROP TABLE IF EXISTS `representative`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `representative` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(45) DEFAULT NULL,
  `status` varchar(1) NOT NULL DEFAULT '0' COMMENT '0 - Free, 1 - Busy',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `representative`
--

LOCK TABLES `representative` WRITE;
/*!40000 ALTER TABLE `representative` DISABLE KEYS */;
/*!40000 ALTER TABLE `representative` ENABLE KEYS */;
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
  `start_proc` varchar(16) NOT NULL DEFAULT 'INC',
  `start_phase` varchar(32) NOT NULL DEFAULT 'INC',
  `errCode` int(11) NOT NULL DEFAULT 0,
  `next_proc` varchar(16) NOT NULL DEFAULT '',
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
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules`
--

LOCK TABLES `rules` WRITE;
/*!40000 ALTER TABLE `rules` DISABLE KEYS */;
INSERT INTO `rules` VALUES ('menus','publish',0,'menus','published',0,'publish:menu',0,1,0,'And','0','Cancelled'),('menus','delete',0,'menus','deleted',0,'remove:menu',0,2,0,'And','0','Cancelled'),('breadcrumbs','publish',0,'breadcrumbs','published',0,'publish:breadcrumbs',0,5,0,'And','0','Cancelled');
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
-- Table structure for table `site_config_process`
--

DROP TABLE IF EXISTS `site_config_process`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_config_process` (
  `site_id` int(11) NOT NULL,
  `action` enum('initpayment','confirmation') NOT NULL,
  `process` varchar(75) NOT NULL,
  `phase` varchar(75) NOT NULL,
  PRIMARY KEY (`site_id`,`action`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_config_process`
--

LOCK TABLES `site_config_process` WRITE;
/*!40000 ALTER TABLE `site_config_process` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_config_process` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_menu_htmls`
--

DROP TABLE IF EXISTS `site_menu_htmls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_menu_htmls` (
  `menu_id` int(11) unsigned NOT NULL,
  `header_html` mediumtext DEFAULT NULL,
  `footer_html` mediumtext DEFAULT NULL,
  `header_html_1` mediumtext DEFAULT NULL,
  `footer_html_1` mediumtext DEFAULT NULL,
  `tmp_header_html` mediumtext DEFAULT NULL,
  `tmp_footer_html` mediumtext DEFAULT NULL,
  PRIMARY KEY (`menu_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_menu_htmls`
--

LOCK TABLES `site_menu_htmls` WRITE;
/*!40000 ALTER TABLE `site_menu_htmls` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_menu_htmls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_menus`
--

DROP TABLE IF EXISTS `site_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_menus` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(10) NOT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` int(10) NOT NULL,
  `show_search_bar` tinyint(1) NOT NULL DEFAULT 0,
  `show_find_a_store` tinyint(1) NOT NULL DEFAULT 0,
  `find_a_store_url` varchar(255) DEFAULT NULL,
  `find_a_store_label` varchar(50) DEFAULT NULL,
  `follow_us_bar_label` varchar(50) DEFAULT NULL,
  `follow_us_bar_color` varchar(10) DEFAULT NULL,
  `follow_us_bar_layout` enum('horizontal','grid','vertical') DEFAULT NULL,
  `follow_us_bar_icon` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `show_contact_us` tinyint(1) NOT NULL DEFAULT 0,
  `search_bar_label` varchar(50) DEFAULT NULL,
  `contact_us_label` varchar(50) DEFAULT NULL,
  `contact_us_url` varchar(255) DEFAULT NULL,
  `homepage_url` varchar(255) DEFAULT NULL,
  `seo_keywords` text DEFAULT NULL,
  `seo_description` text DEFAULT NULL,
  `prod_homepage_url` varchar(255) DEFAULT NULL,
  `prod_find_a_store_url` varchar(255) DEFAULT NULL,
  `prod_contact_us_url` varchar(255) DEFAULT NULL,
  `preference` int(10) unsigned DEFAULT NULL,
  `search_bar_url` varchar(255) DEFAULT NULL,
  `lang` char(2) DEFAULT NULL,
  `show_login_bar` tinyint(1) NOT NULL DEFAULT 0,
  `login_username_label` varchar(75) DEFAULT NULL,
  `login_password_label` varchar(75) DEFAULT NULL,
  `login_button_label` varchar(75) DEFAULT NULL,
  `logout_button_label` varchar(75) DEFAULT NULL,
  `sign_up_label` varchar(75) DEFAULT NULL,
  `forgot_password_label` varchar(75) DEFAULT NULL,
  `register_url` text DEFAULT NULL,
  `register_prod_url` text DEFAULT NULL,
  `forgot_pass_url` text DEFAULT NULL,
  `forgot_pass_prod_url` text DEFAULT NULL,
  `my_account_url` text DEFAULT NULL,
  `my_account_prod_url` text DEFAULT NULL,
  `find_a_store_open_as` enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url') DEFAULT NULL,
  `contact_us_open_as` enum('new_tab','new_window','new_tab_original_url','new_window_original_url','same_window_original_url') DEFAULT NULL,
  `search_completion_url` varchar(500) DEFAULT NULL,
  `search_params` varchar(255) DEFAULT NULL,
  `logo_file` varchar(255) DEFAULT NULL,
  `favicon` varchar(255) DEFAULT NULL,
  `menu_uuid` varchar(50) NOT NULL,
  `javascript_filename` varchar(100) DEFAULT NULL,
  `search_api` enum('internal','external','url') DEFAULT NULL,
  `enable_cart` tinyint(4) NOT NULL DEFAULT 0,
  `404_url` varchar(255) DEFAULT NULL,
  `prod_404_url` varchar(255) DEFAULT NULL,
  `use_smart_banner` tinyint(1) NOT NULL DEFAULT 0,
  `logo_url` varchar(255) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  `version` int(10) NOT NULL DEFAULT 0,
  `smartbanner_days_hidden` int(10) NOT NULL DEFAULT 15,
  `smartbanner_days_reminder` int(10) NOT NULL DEFAULT 30,
  `smartbanner_position` enum('top','bottom') DEFAULT 'top',
  `small_logo_file` varchar(255) DEFAULT NULL,
  `hide_header` tinyint(1) NOT NULL DEFAULT 0,
  `hide_footer` tinyint(1) NOT NULL DEFAULT 0,
  `logo_text` varchar(255) DEFAULT NULL,
  `hide_top_nav` tinyint(4) NOT NULL DEFAULT 0,
  `animate_on_scroll` tinyint(4) NOT NULL DEFAULT 1,
  `default_size` enum('small','large') NOT NULL DEFAULT 'large',
  `enable_breadcrumbs` tinyint(1) NOT NULL DEFAULT 1,
  `production_path` varchar(255) DEFAULT NULL,
  `published_home_url` varchar(255) DEFAULT NULL,
  `published_404_url` varchar(255) DEFAULT NULL,
  `published_404_cached_id` varchar(255) DEFAULT NULL,
  `published_hp_cached_id` varchar(255) DEFAULT NULL,
  `menu_version` enum('V1','V2') NOT NULL DEFAULT 'V1',
  `extra_js_mjs` varchar(255) DEFAULT NULL COMMENT 'Semi colon separated list of extra js files to be loaded with js menu. This will not be required in block system js menu',
  `cart_footer_html` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `menu_uuid` (`menu_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_menus`
--

LOCK TABLES `site_menus` WRITE;
/*!40000 ALTER TABLE `site_menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sitemap_audit`
--

DROP TABLE IF EXISTS `sitemap_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitemap_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(75) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `action` text DEFAULT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sitemap_audit`
--

LOCK TABLES `sitemap_audit` WRITE;
/*!40000 ALTER TABLE `sitemap_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `sitemap_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `suid` varchar(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `portal_url` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(10) NOT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` int(10) DEFAULT NULL,
  `gtm_code` varchar(50) DEFAULT NULL,
  `country_code` varchar(3) DEFAULT NULL,
  `website_name` varchar(100) DEFAULT NULL,
  `domain` varchar(100) DEFAULT NULL,
  `default_menu_id` int(10) DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `enable_ecommerce` tinyint(1) NOT NULL DEFAULT 0,
  `datalayer_domain` varchar(255) DEFAULT NULL,
  `datalayer_brand` varchar(255) DEFAULT NULL,
  `datalayer_market` varchar(255) DEFAULT NULL,
  `enable_cache` tinyint(1) NOT NULL DEFAULT 0,
  `facebook_app_id` varchar(50) DEFAULT NULL,
  `twitter_account` varchar(50) DEFAULT NULL,
  `site_auth_login_page` text DEFAULT NULL,
  `site_auth_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `geocoding_api` varchar(100) DEFAULT NULL,
  `googlemap_api` varchar(100) DEFAULT NULL,
  `leadformance_api` varchar(100) DEFAULT NULL,
  `load_map` tinyint(1) DEFAULT 0,
  `datalayer_asset_type` varchar(75) DEFAULT NULL,
  `datalayer_orange_zone` varchar(75) DEFAULT NULL,
  `snap_pixel_code` varchar(75) DEFAULT NULL,
  `shop_location_type` varchar(255) DEFAULT '',
  `package_point_location_type` varchar(255) DEFAULT '',
  `auto_accept_signup` tinyint(1) NOT NULL DEFAULT 0,
  `authentication_type` enum('default','orange') NOT NULL DEFAULT 'default',
  `orange_authentication_api_url` varchar(500) DEFAULT NULL,
  `orange_token_api_url` varchar(500) DEFAULT NULL,
  `orange_authorization_code` varchar(500) DEFAULT NULL,
  `datalayer_moringa_perimeter` varchar(75) DEFAULT NULL,
  `partoo_activated` tinyint(1) NOT NULL DEFAULT 0,
  `partoo_organization_id` varchar(50) DEFAULT NULL,
  `partoo_country_code` varchar(2) DEFAULT NULL,
  `partoo_api_key` varchar(255) DEFAULT NULL,
  `partoo_main_group` varchar(255) DEFAULT NULL,
  `partoo_language_id` varchar(2) DEFAULT NULL COMMENT 'the language which will be used at time of calling partoo api',
  `voucher_api_implementation_cls` varchar(75) DEFAULT NULL,
  `algolia_stores_index` varchar(255) DEFAULT NULL,
  `form_boosted_version` varchar(10) NOT NULL DEFAULT '4.x',
  `open_only_in_iframe` tinyint(1) NOT NULL DEFAULT 0,
  `generate_breadcrumbs` tinyint(1) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_name` (`name`),
  UNIQUE KEY `suid` (`suid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites`
--

LOCK TABLES `sites` WRITE;
/*!40000 ALTER TABLE `sites` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites_apply_to`
--

DROP TABLE IF EXISTS `sites_apply_to`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites_apply_to` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(10) unsigned NOT NULL,
  `apply_type` enum('url','url_starting_with','drupal_pages','db_pages') NOT NULL,
  `apply_to` varchar(255) NOT NULL,
  `replace_tags` varchar(255) NOT NULL DEFAULT '',
  `cache` int(1) NOT NULL DEFAULT 0,
  `add_gtm_script` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unq1` (`site_id`,`apply_type`,`apply_to`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites_apply_to`
--

LOCK TABLES `sites_apply_to` WRITE;
/*!40000 ALTER TABLE `sites_apply_to` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites_apply_to` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites_config`
--

DROP TABLE IF EXISTS `sites_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites_config` (
  `site_id` int(11) NOT NULL,
  `code` varchar(100) NOT NULL,
  `val` mediumtext DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  PRIMARY KEY (`site_id`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites_config`
--

LOCK TABLES `sites_config` WRITE;
/*!40000 ALTER TABLE `sites_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites_details`
--

DROP TABLE IF EXISTS `sites_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites_details` (
  `site_id` int(10) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `production_path` varchar(300) NOT NULL DEFAULT '',
  `homepage_url` varchar(2000) NOT NULL DEFAULT '',
  `page_404_url` varchar(2000) NOT NULL DEFAULT '',
  `default_page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `login_page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `cart_page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `funnel_page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `login_page_url` varchar(500) DEFAULT NULL,
  `error_page_url` varchar(2000) DEFAULT NULL,
  `fraud_page_url` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`site_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites_details`
--

LOCK TABLES `sites_details` WRITE;
/*!40000 ALTER TABLE `sites_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_log`
--

DROP TABLE IF EXISTS `stat_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_log` (
  `date_l` datetime NOT NULL,
  `ip` varchar(50) NOT NULL DEFAULT '' COMMENT 'Countries with multiple servers might have multiple ips coming in due to load balancer',
  `session_j` varchar(70) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `screen_width` int(11) DEFAULT NULL,
  `screen_height` int(11) DEFAULT NULL,
  `page_c` varchar(255) DEFAULT NULL,
  `page_ref` varchar(255) DEFAULT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `document_title` varchar(255) DEFAULT NULL,
  `has_internet` tinyint(1) NOT NULL DEFAULT 1,
  `server_num` int(10) NOT NULL DEFAULT 1 COMMENT 'For multiple active servers its value will be filled accordingly at time of syncing otherwise its always 1 by default',
  `browser_session_id` varchar(70) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`date_l`,`ip`,`session_j`,`server_num`),
  KEY `idxDateL` (`date_l`),
  KEY `idx2` (`date_l`,`page_c`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stat_log`
--

LOCK TABLES `stat_log` WRITE;
/*!40000 ALTER TABLE `stat_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `stat_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_log_page_info`
--

DROP TABLE IF EXISTS `stat_log_page_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_log_page_info` (
  `page_c` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `eletype` varchar(100) DEFAULT NULL,
  `eleid` int(11) DEFAULT NULL,
  `site_uuid` varchar(50) NOT NULL,
  `lang` varchar(20) DEFAULT NULL,
  `creation_date` datetime NOT NULL DEFAULT current_timestamp(),
  `update_date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`page_c`,`site_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stat_log_page_info`
--

LOCK TABLES `stat_log_page_info` WRITE;
/*!40000 ALTER TABLE `stat_log_page_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `stat_log_page_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_log_page_ref`
--

DROP TABLE IF EXISTS `stat_log_page_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_log_page_ref` (
  `id` varchar(64) NOT NULL,
  `site_id` int(11) NOT NULL,
  `page_c` varchar(255) DEFAULT NULL,
  `page_ref` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stat_log_page_ref`
--

LOCK TABLES `stat_log_page_ref` WRITE;
/*!40000 ALTER TABLE `stat_log_page_ref` DISABLE KEYS */;
/*!40000 ALTER TABLE `stat_log_page_ref` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_sessions`
--

DROP TABLE IF EXISTS `web_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_sessions` (
  `id` varchar(50) NOT NULL,
  `access_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `params` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_date` (`access_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_sessions`
--

LOCK TABLES `web_sessions` WRITE;
/*!40000 ALTER TABLE `web_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `cached_content_view`
--

/*!50001 DROP TABLE IF EXISTS `cached_content_view`*/;
/*!50001 DROP VIEW IF EXISTS `cached_content_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cached_content_view` AS select `c`.`cached_page_id` AS `cached_page_id`,`c`.`published_url` AS `published_url`,`c`.`content_type` AS `content_type`,`c`.`content_id` AS `content_id`,`c`.`published_menu_path` AS `published_menu_path`,`p`.`menu_id` AS `menu_id`,`m`.`site_id` AS `site_id`,`m`.`lang` AS `lang` from ((`cached_content` `c` join `cached_pages` `p`) join `site_menus` `m`) where `c`.`cached_page_id` = `p`.`id` and `p`.`menu_id` = `m`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

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

-- Dump completed on 2024-12-05 20:21:53
