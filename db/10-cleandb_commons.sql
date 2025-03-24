-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_commons
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
-- Table structure for table `access_tokens`
--

DROP TABLE IF EXISTS `access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_tokens` (
  `token` varchar(255) NOT NULL,
  `api_key` varchar(100) NOT NULL,
  `issue_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expiration` datetime NOT NULL DEFAULT (current_timestamp() + interval 30 minute),
  `api_id` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_tokens`
--

LOCK TABLES `access_tokens` WRITE;
/*!40000 ALTER TABLE `access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_action_logs`
--

DROP TABLE IF EXISTS `api_action_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_action_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wkid` int(11) DEFAULT NULL,
  `clid` varchar(100) DEFAULT NULL,
  `appl_name` varchar(255) DEFAULT NULL,
  `procedure_name` varchar(255) DEFAULT NULL,
  `api_url` varchar(500) DEFAULT NULL,
  `request_method` varchar(10) DEFAULT NULL,
  `request_body` mediumtext DEFAULT NULL,
  `api_response` mediumtext DEFAULT NULL,
  `http_code` varchar(10) NOT NULL DEFAULT '0',
  `api_env` enum('prod','test') DEFAULT NULL,
  `response_time` varchar(75) DEFAULT NULL,
  `created_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  `cart_id` varchar(255) DEFAULT NULL,
  `msg` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_action_logs`
--

LOCK TABLES `api_action_logs` WRITE;
/*!40000 ALTER TABLE `api_action_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_action_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `id` varchar(100) NOT NULL DEFAULT '',
  `key` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL DEFAULT '',
  `is_prod` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`key`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) NOT NULL,
  `val` varchar(500) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('ADMIN_FORGOT_PASS_URL','/asimina_catalog/resetpass.jsp',NULL),('ADMIN_PASS_SALT','b1f3de80','Salt used for admin side passwords'),('allow_iframe_domains','','not used from here anymore. delete it in next version'),('APP_INSTANCE_NAME','asimina',NULL),('APP_NAME','asimina',NULL),('APP_PREFIX','asimina',''),('APP_VERSION','4.9.1',NULL),('AUTO_VERIFY_CLIENT','0','Value should be 0 or 1. 0 means we have to send an email to client to verify their email'),('AVATAR_HEIGHT','36',NULL),('AVATAR_WIDTH','36',NULL),('CACHESYNC_DB','cleandb_sync',''),('CATAPULTE_DB','cleandb_catapulte',''),('client_image_max_size','2000000','This size is in bytes'),('client_image_quality','0.7',''),('CLIENT_PASS_SALT','b204de7d','Salt used for client passwords'),('CSS_JS_VERSION','4.9.1.1','First three numbers are the app version number. Forth number is the iterations of css/js updates in that particular version. App version x.y.z will have css/js version as x.y.z.w'),('DANDELION_PROD_FORGOT_PASS_URL','/asimina_prodshop/resetpass.jsp',NULL),('DANDELION_TEST_FORGOT_PASS_URL','/asimina_shop/resetpass.jsp',NULL),('ENABLE_CATAPULTE','0',NULL),('ES_API_V2_URL','/asimina_expert_system/',''),('EXPERT_SYSTEM_DB','cleandb_expert_system',NULL),('EXP_SYS_EXTERNAL_URL','/asimina_expert_system/',NULL),('EXTERNAL_FORMS_LINK','/asimina_forms/',NULL),('FAQS_EXTERNAL_PATH','',NULL),('FORMS_DB','cleandb_forms',NULL),('FORMS_WEBAPP_URL','/asimina_forms/',NULL),('FORM_HTML_API_URL','http://127.0.0.1/asimina_forms/api/forms.jsp',''),('GESTION_URL','/asimina_catalog/admin/gestion.jsp',NULL),('HTML_TO_PDF_CMD','/home/asimina/pjt/asimina_engines/shop/wkhtmltopdf',NULL),('HTTP_PROXY_AUTH','',''),('HTTP_PROXY_HOST','',NULL),('HTTP_PROXY_PASSWD','',NULL),('HTTP_PROXY_PORT','',NULL),('HTTP_PROXY_USER','',NULL),('INCLUDE_CUSTOM_CSS','0','Flag to enable disable inclusion of custom css at time of caching pages'),('IS_ORANGE_APP','1',NULL),('LOGGER_LEVEL','debug',NULL),('mail.smtp.auth','',''),('mail.smtp.auth.pwd','',''),('mail.smtp.auth.user','',''),('mail.smtp.host','','127.0.0.1'),('mail.smtp.port','',''),('MAIL_FROM','',NULL),('MAIL_REPLY','',NULL),('MAIL_UPLOAD_PATH','',NULL),('MAX_TAG_FOLDER_LEVEL','1',NULL),('MEDIA_LIBRARY_UPLOADS_URL','/asimina_pages/uploads/',''),('MENU_APP_URL','/asimina_menu/',''),('MIN_ASIMINA_VERSION','3.2.0','Theme must have a min asimina version matching this config otherwise we dont allow to apply the theme'),('OBSERVER_ENGINES','Catalog,Pages,Forms,Shop,Portal,ProdShop,Partoo,ImportExport',NULL),('OBSERVER_ENGINE_TIME_MINS','10',NULL),('OBSERVER_SEND_EMAILS_TO','',NULL),('PAGES_APP_URL','/asimina_pages/',NULL),('PAGES_DB','cleandb_pages',NULL),('PAGES_FORM_UPDATE_API_URL','http://127.0.0.1/asimina_pages/api/formUpdate.jsp',''),('PAGES_INDEXED_DATA_API','http://127.0.0.1/asimina_pages/api/indexData.jsp',NULL),('PAGES_PUBLISH_FOLDER','pages/',NULL),('PAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_pages/uploads/',NULL),('PAGES_URL','http://127.0.0.1/asimina_pages/',NULL),('page_preview_api_url','/asimina_catalog/admin/testsitepagepreview.jsp',NULL),('partoo_api_base_url','https://api.sandbox.partoo.co/v2',NULL),('partoo_api_version','v2',NULL),('PHONES_DIRECTORY_API_URL','',NULL),('PHONES_DIRECTORY_COUNTRY','',NULL),('PHONES_DIRECTORY_COUNTRY_ID','',NULL),('PHONES_DIRECTORY_PASSWORD','',NULL),('PHONES_DIRECTORY_USER','',NULL),('PORTAL_APP','asimina_portal',NULL),('PORTAL_ENG_SEMA','D002',NULL),('POST_WORK_SPLIT_ITEMS','0',NULL),('PREPROD_CATALOG_DB','cleandb_catalog','This is used in com.etn.asimina.util.UrlReplacer class. That class will be almost in all apps so we add specific configs in commons db'),('PREPROD_PORTAL_DB','cleandb_portal',NULL),('PREPROD_SHOP_DB','cleandb_shop',NULL),('PROD_CATALOG_DB','cleandb_prod_catalog',NULL),('PROD_PORTAL_APP','asimina_prodportal',NULL),('PROD_PORTAL_DB','cleandb_prod_portal',NULL),('PROD_SHOP_DB','cleandb_prod_shop',NULL),('SELECT_DEFAULT_VARIANT','1',NULL),('SELFCARE_SEMAPHORE','D007',NULL),('SESSION_TIMEOUT_MINS','10',NULL),('SHOP_SESSION_TIMEOUT_MINS','180','Session time out in minutes used for client login and cart timeouts'),('SHOW_SMART_BANNER_OPTION','1',NULL),('SSO_APP_VERIFY_URL','http://127.0.0.1/asimina_sso/verify.jsp',NULL),('SSO_DB','cleandb_sso',NULL),('STRICT_CORS','0',NULL),('TEMP_DIRECTORY','/tmp/asimina_tmp/','This path should not be inside tomcat as we just need to upload files and use them for processing'),('TOMCAT_PATH','/home/asimina/tomcat/',NULL),('TRASH_FOLDER','/home/asimina/asimina/trash/','This should be outside webapps'),('URL_GEN_AJAX_URL','/asimina_catalog/js/urlgen/urlgeneratorAjax.jsp',''),('URL_GEN_JS_URL','/asimina_catalog/js/urlgen/etn.urlgenerator.js',''),('X_FORWARDED_FOR_IPS_CHAIN','',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `constants`
--

DROP TABLE IF EXISTS `constants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `constants` (
  `group` varchar(100) NOT NULL,
  `parent_key` varchar(100) NOT NULL DEFAULT '',
  `key` varchar(100) NOT NULL,
  `value` varchar(100) DEFAULT NULL,
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`group`,`parent_key`,`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `constants`
--

LOCK TABLES `constants` WRITE;
/*!40000 ALTER TABLE `constants` DISABLE KEYS */;
INSERT INTO `constants` VALUES ('product_variant_commitment','month','24','24 months',500),('product_variant_commitment','month','12','12 months',400),('product_variant_commitment','month','6','6 months',300),('product_variant_commitment','month','3','3 months',200),('product_variant_commitment','month','0','without commitment',100),('product_variant_frequency','','month','Month',100),('product_essentials_alignment','','zig_zag_right','Zig Zag - image start at right',100),('product_essentials_alignment','','zig_zag_left','Zig Zag - image start at left',200),('product_essentials_alignment','','aligned_right','Aligned - image at right',300),('product_essentials_alignment','','aligned_left','Aligned - image at left',400);
/*!40000 ALTER TABLE `constants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `content_urls`
--

DROP TABLE IF EXISTS `content_urls`;
/*!50001 DROP VIEW IF EXISTS `content_urls`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `content_urls` (
  `site_id` tinyint NOT NULL,
  `content_type` tinyint NOT NULL,
  `content_id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `langue_id` tinyint NOT NULL,
  `langue_code` tinyint NOT NULL,
  `page_path` tinyint NOT NULL,
  `internal_url` tinyint NOT NULL,
  `internal_prod_url` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cors_whitelist`
--

DROP TABLE IF EXISTS `cors_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cors_whitelist` (
  `w_domain` varchar(255) NOT NULL,
  PRIMARY KEY (`w_domain`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cors_whitelist`
--

LOCK TABLES `cors_whitelist` WRITE;
/*!40000 ALTER TABLE `cors_whitelist` DISABLE KEYS */;
/*!40000 ALTER TABLE `cors_whitelist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currencies` (
  `currency_code` varchar(10) NOT NULL,
  PRIMARY KEY (`currency_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_slots`
--

DROP TABLE IF EXISTS `delivery_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delivery_slots` (
  `site_id` int(11) NOT NULL,
  `n_day` int(1) NOT NULL,
  `start_hour` int(2) NOT NULL,
  `start_min` int(2) NOT NULL,
  `end_hour` int(2) NOT NULL,
  `end_min` int(2) NOT NULL,
  `create_by` int(11) NOT NULL,
  `create_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`site_id`,`n_day`,`start_hour`,`start_min`,`end_hour`,`end_min`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_slots`
--

LOCK TABLES `delivery_slots` WRITE;
/*!40000 ALTER TABLE `delivery_slots` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engines_status`
--

DROP TABLE IF EXISTS `engines_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engines_status` (
  `engine_name` varchar(100) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  PRIMARY KEY (`engine_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engines_status`
--

LOCK TABLES `engines_status` WRITE;
/*!40000 ALTER TABLE `engines_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `engines_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_tags`
--

DROP TABLE IF EXISTS `forum_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_tags` (
  `tag_id` varchar(36) NOT NULL,
  `site_id` int(11) NOT NULL,
  `tag_name` varchar(36) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`tag_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_tags`
--

LOCK TABLES `forum_tags` WRITE;
/*!40000 ALTER TABLE `forum_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fraud_rules_columns`
--

DROP TABLE IF EXISTS `fraud_rules_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fraud_rules_columns` (
  `name` varchar(255) NOT NULL,
  `display_name` varchar(255) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fraud_rules_columns`
--

LOCK TABLES `fraud_rules_columns` WRITE;
/*!40000 ALTER TABLE `fraud_rules_columns` DISABLE KEYS */;
INSERT INTO `fraud_rules_columns` VALUES ('identityId','Identity Id'),('email','Email'),('ip','IP Address'),('contactPhoneNumber1','Contact number');
/*!40000 ALTER TABLE `fraud_rules_columns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `installer_scripts`
--

DROP TABLE IF EXISTS `installer_scripts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `installer_scripts` (
  `script_version` varchar(10) NOT NULL,
  `db_name` varchar(255) NOT NULL,
  `script_text` longtext DEFAULT NULL,
  `script_result` mediumtext DEFAULT NULL,
  `script_text_minified` longtext DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `script_version` (`script_version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `installer_scripts`
--

LOCK TABLES `installer_scripts` WRITE;
/*!40000 ALTER TABLE `installer_scripts` DISABLE KEYS */;
/*!40000 ALTER TABLE `installer_scripts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_mail`
--

DROP TABLE IF EXISTS `inventory_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_mail` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `email_test` varchar(255) NOT NULL,
  `email_prod` varchar(255) NOT NULL,
  `test_email_sent_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `prod_email_sent_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `s_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_mail`
--

LOCK TABLES `inventory_mail` WRITE;
/*!40000 ALTER TABLE `inventory_mail` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_mail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `local_holidays`
--

DROP TABLE IF EXISTS `local_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `local_holidays` (
  `h_date` date NOT NULL,
  `holiday_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`h_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `local_holidays`
--

LOCK TABLES `local_holidays` WRITE;
/*!40000 ALTER TABLE `local_holidays` DISABLE KEYS */;
/*!40000 ALTER TABLE `local_holidays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reload_translations`
--

DROP TABLE IF EXISTS `reload_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reload_translations` (
  `id` varchar(100) NOT NULL,
  `updated_dt` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reload_translations`
--

LOCK TABLES `reload_translations` WRITE;
/*!40000 ALTER TABLE `reload_translations` DISABLE KEYS */;
/*!40000 ALTER TABLE `reload_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites_langs`
--

DROP TABLE IF EXISTS `sites_langs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites_langs` (
  `site_id` int(10) DEFAULT NULL,
  `langue_id` int(1) DEFAULT NULL,
  UNIQUE KEY `sites_langs_index` (`site_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites_langs`
--

LOCK TABLES `sites_langs` WRITE;
/*!40000 ALTER TABLE `sites_langs` DISABLE KEYS */;
/*!40000 ALTER TABLE `sites_langs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_actions`
--

DROP TABLE IF EXISTS `user_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_actions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `item_id` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `description` varchar(500) NOT NULL,
  `site_id` varchar(50) NOT NULL,
  `user_agent` text NOT NULL,
  `activity_on` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_actions`
--

LOCK TABLES `user_actions` WRITE;
/*!40000 ALTER TABLE `user_actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `catalog_session_id` varchar(32) NOT NULL,
  `menu_session_id` varchar(32) DEFAULT NULL,
  `ckeditor_session_id` varchar(32) DEFAULT NULL,
  `forms_session_id` varchar(32) DEFAULT NULL,
  `pages_session_id` varchar(32) DEFAULT NULL,
  `expsys_session_id` varchar(32) DEFAULT NULL,
  `selected_site_id` int(10) DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_updated_on` datetime DEFAULT NULL,
  `is_publish_prod_login` tinyint(1) NOT NULL DEFAULT 0,
  `pid` int(11) DEFAULT NULL,
  PRIMARY KEY (`catalog_session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webapps_auth_tokens`
--

DROP TABLE IF EXISTS `webapps_auth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `webapps_auth_tokens` (
  `id` varchar(75) NOT NULL,
  `expiry` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `access_id` varchar(75) NOT NULL,
  `catalog_session_id` varchar(75) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webapps_auth_tokens`
--

LOCK TABLES `webapps_auth_tokens` WRITE;
/*!40000 ALTER TABLE `webapps_auth_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `webapps_auth_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `content_urls`
--

/*!50001 DROP TABLE IF EXISTS `content_urls`*/;
/*!50001 DROP VIEW IF EXISTS `content_urls`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `content_urls` AS select `p`.`site_id` AS `site_id`,'page' AS `content_type`,`p`.`id` AS `content_id`,`p`.`name` AS `name`,`l`.`langue_id` AS `langue_id`,`p`.`langue_code` AS `langue_code`,lcase(replace(`p`.`html_file_path`,concat(`p`.`site_id`,'/',`p`.`langue_code`,'/',if(`p`.`variant` = 'logged','',concat(`p`.`variant`,'/'))),'')) AS `page_path`,concat(`c`.`val`,`c2`.`val`,`p`.`html_file_path`) AS `internal_url`,concat(`c`.`val`,`c2`.`val`,`p`.`html_file_path`) AS `internal_prod_url` from (((`cleandb_pages`.`pages` `p` join `cleandb_pages`.`language` `l`) join `cleandb_commons`.`config` `c`) join `cleandb_commons`.`config` `c2`) where `c`.`code` = 'PAGES_APP_URL' and `c2`.`code` = 'PAGES_PUBLISH_FOLDER' and `l`.`langue_code` = `p`.`langue_code` union all select `c`.`site_id` AS `site_id`,'catalog' AS `content_type`,`c`.`id` AS `content_id`,`c`.`name` AS `name`,`cd`.`langue_id` AS `langue_id`,`l`.`langue_code` AS `langue_code`,case when `c`.`html_variant` = 'logged' then lcase(concat(`c`.`html_variant`,'/',`cd`.`page_path`,'.html')) else lcase(concat(`cd`.`page_path`,'.html')) end AS `page_path`,concat(`cf`.`val`,'listproducts.jsp?cat=',`c`.`id`) AS `internal_url`,concat(`cf2`.`val`,'listproducts.jsp?cat=',`c`.`id`) AS `internal_prod_url` from ((((`cleandb_catalog`.`catalogs` `c` join `cleandb_catalog`.`catalog_descriptions` `cd`) join `cleandb_catalog`.`language` `l`) join `cleandb_catalog`.`config` `cf`) join `cleandb_prod_catalog`.`config` `cf2`) where coalesce(`cd`.`page_path`,'') <> '' and `c`.`id` = `cd`.`catalog_id` and `cf`.`code` = 'EXTERNAL_CATALOG_LINK' and `cf2`.`code` = 'EXTERNAL_CATALOG_LINK' and `l`.`langue_id` = `cd`.`langue_id` union all select `c`.`site_id` AS `site_id`,'product' AS `content_type`,`p`.`id` AS `content_id`,case when `l`.`langue_id` = 1 then `p`.`lang_1_name` when `l`.`langue_id` = 2 then `p`.`lang_2_name` when `l`.`langue_id` = 3 then `p`.`lang_3_name` when `l`.`langue_id` = 4 then `p`.`lang_4_name` when `l`.`langue_id` = 5 then `p`.`lang_5_name` else `p`.`lang_1_name` end AS `name`,`pd`.`langue_id` AS `langue_id`,`l`.`langue_code` AS `langue_code`,lcase(concat(concat_ws('/',if(`p`.`html_variant` = 'logged',`p`.`html_variant`,NULL),if(trim(ifnull(`cd`.`folder_name`,'')) <> '',`cd`.`folder_name`,NULL),if(trim(ifnull(`f`.`concat_path`,'')) <> '',`f`.`concat_path`,NULL),`pd`.`page_path`),'.html')) AS `page_path`,concat(`cf`.`val`,'product.jsp?id=',`p`.`id`) AS `internal_url`,concat(`cf2`.`val`,'product.jsp?id=',`p`.`id`) AS `internal_prod_url` from (((((((`cleandb_catalog`.`products` `p` join `cleandb_catalog`.`product_descriptions` `pd` on(`p`.`id` = `pd`.`product_id`)) join `cleandb_catalog`.`catalogs` `c` on(`c`.`id` = `p`.`catalog_id`)) join `cleandb_catalog`.`language` `l` on(`l`.`langue_id` = `pd`.`langue_id`)) join `cleandb_catalog`.`config` `cf`) join `cleandb_prod_catalog`.`config` `cf2`) left join `cleandb_catalog`.`catalog_descriptions` `cd` on(`cd`.`catalog_id` = `c`.`id` and `cd`.`langue_id` = `l`.`langue_id`)) left join `cleandb_catalog`.`products_folders_lang_path` `f` on(`f`.`folder_id` = `p`.`folder_id` and `f`.`langue_id` = `l`.`langue_id`)) where coalesce(`pd`.`page_path`,'') <> '' and `cf`.`code` = 'EXTERNAL_CATALOG_LINK' and `cf2`.`code` = 'EXTERNAL_CATALOG_LINK' union all select `f`.`site_id` AS `site_id`,'file' AS `content_type`,`f`.`id` AS `content_id`,`f`.`file_name` AS `name`,0 AS `langue_id`,'0' AS `langue_code`,concat(`c`.`val`,`c2`.`val`,`f`.`site_id`,'/',`f`.`type`,'/',`f`.`file_name`) AS `page_path`,concat(`c`.`val`,`c2`.`val`,`f`.`site_id`,'/',`f`.`type`,'/',`f`.`file_name`) AS `internal_url`,concat(`c`.`val`,`c2`.`val`,`f`.`site_id`,'/',`f`.`type`,'/',`f`.`file_name`) AS `internal_prod_url` from ((`cleandb_pages`.`files` `f` join `cleandb_pages`.`config` `c` on(`c`.`code` = 'EXTERNAL_LINK')) join `cleandb_pages`.`config` `c2` on(`c2`.`code` = 'UPLOADS_FOLDER')) where `f`.`type` in ('other','video') */;
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

-- Dump completed on 2024-12-05 20:21:35
