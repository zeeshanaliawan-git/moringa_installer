-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_shop
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
  `className` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
INSERT INTO `actions` VALUES ('sms','sms','sms_id',NULL),('mail','sample_email','seq',NULL),('shell','','','Shell'),('sql','','','Sql'),('payment',NULL,NULL,'Payment');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allowed_ips`
--

DROP TABLE IF EXISTS `allowed_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allowed_ips` (
  `ip_from` varchar(15) NOT NULL,
  `ip_to` varchar(15) DEFAULT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allowed_ips`
--

LOCK TABLES `allowed_ips` WRITE;
/*!40000 ALTER TABLE `allowed_ips` DISABLE KEYS */;
/*!40000 ALTER TABLE `allowed_ips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `check_rights`
--

DROP TABLE IF EXISTS `check_rights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `check_rights` (
  `url` varchar(150) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `check_rights`
--

LOCK TABLES `check_rights` WRITE;
/*!40000 ALTER TABLE `check_rights` DISABLE KEYS */;
INSERT INTO `check_rights` VALUES ('/admin/clientManagement.jsp'),('/admin/fieldSettings.jsp'),('/admin/genericFieldSettings.jsp'),('/admin/genericFormMapping.jsp'),('/admin/manageProfil.jsp'),('/admin/orderTrackingVisible.jsp'),('/admin/profilManagement.jsp'),('/admin/serviceColors.jsp'),('/admin/supplier.jsp'),('/admin/userManagement.jsp'),('/customCalendar.jsp'),('/ibo.jsp'),('/jeuneAfrique.jsp'),('/mail_sms/modele.jsp'),('/processStatus.jsp'),('/viewProcessNew.jsp');
/*!40000 ALTER TABLE `check_rights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_profil`
--

DROP TABLE IF EXISTS `client_profil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_profil` (
  `profil` varchar(50) NOT NULL,
  `discount_type` varchar(15) NOT NULL,
  `discount_value` decimal(10,0) NOT NULL DEFAULT 0,
  `catalog_id` int(11) NOT NULL DEFAULT 0,
  `product_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`profil`,`catalog_id`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_profil`
--

LOCK TABLES `client_profil` WRITE;
/*!40000 ALTER TABLE `client_profil` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_profil` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) DEFAULT NULL,
  `val` varchar(255) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('sso_app_id','',NULL),('empty_service_id','',NULL),('UPLOAD_FOLDER','/home/asimina/tomcat/webapps/asimina_shop/WEB-INF/upload_file',NULL),('EXEC_FOLDER','/home/asimina/tomcat/webapps/asimina_shop/WEB-INF/classes',NULL),('CATALOG_DB','cleandb_catalog',NULL),('MAIL_UPLOAD_PATH','',NULL),('CATALOG_URL','/asimina_catalog/',NULL),('SEMAPHORE','D005',NULL),('PORTAL_DB','cleandb_portal',NULL),('EXTERNAL_PORTAL_LINK','/asimina_portal/',NULL),('COOKIE_PREFIX','asimina_catalog',NULL),('ABSENCE_PRODUCT_NAME','Absence Product',NULL),('IS_PROD_SHOP','0',NULL),('APP_NAME','Test Shop',NULL),('COMMONS_DB','cleandb_commons',NULL),('URL_REQUETEUR','',NULL),('WAIT_TIMEOUT','300',''),('DEBUG','Oui',''),('SHELL_DIR','/home/asimina/pjt/asimina_engines/shop/bin',''),('WITH_MAIL','Oui',''),('MAIL_REPOSITORY','',''),('MAIL_DEBUG','',''),('MAIL_FROM','',''),('MAIL_REPLY','',''),('MAIL_FROM_DISPLAY_NAME','',''),('ORANGE_API_MSISDN','',NULL),('WKHTMLTOIMAGE_PATH','/home/asimina/pjt/asimina_engines/shop/wkhtmltoimage',''),('CALENDAR_DIR','/home/asimina/pjt/asimina_engines/shop/calfiles/',''),('CALENDAR_NAME','Dev Calendar',''),('INVOICE_DIR','/home/asimina/tomcat/webapps/asimina_catapulte/upload/invoices/',''),('ANSWERS_URL','/asimina_portal/pages/answerquestion.jsp',''),('PDF_REPO','/home/asimina/tomcat/webapps/asimina_portal/invoices',''),('HTML_TO_PDF_CMD','/home/asimina/pjt/asimina_engines/shop/wkhtmltopdf',''),('SMS_URL','',''),('DEFAULT_SMS_COLUMN','',''),('SMS_URL_PARAMS','',''),('SMTP_DEBUG','true',NULL),('VARIANT_IMAGES_URL','https://portail-moringa.com/asimina_shop/variant_images/','for emails'),('VARIANT_IMAGE_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_shop/variant_images/','for shop'),('CART_URL','/asimina_portal/cart/',NULL),('PRODUCTS_IMG_PATH','/asimina_catalog/uploads/products/',NULL),('PRODUCTS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/products/',NULL),('STOCK_ALERT_MAIL_ID','',NULL),('DASHBOARD_PDF_PATH','/home/asimina/tomcat/webapps/asimina_shop/custom/dashboard_pdfs/',NULL),('DASHBOARD_EXCEL_PATH','/home/asimina/tomcat/webapps/asimina_shop/custom/dashboard_excels/',NULL),('no_admin_bill_download','0','This flag is used in customer edit screen to configure the display of bill download button'),('SAVE_CART_EMAIL_MINS','3',NULL),('ENGINE_NAME','Shop',NULL),('use_process_as_order_type','','This flag determines if we have to use order type in shop as process names or fixed as Order. For all asimina shops it must be fixed as Orders so we dont have to change this. This was added for some orange requirement where they wanted process names loaded as order type in mail config screen drop down'),('SHOP_APP_URL','/asimina_shop',NULL),('funnel_documents_base_url','/asimina_shop/uploads/',NULL),('LOGS_DIRECTORY','/home/asimina/logs/shop/',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configs`
--

DROP TABLE IF EXISTS `configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(25) DEFAULT NULL,
  `val` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configs`
--

LOCK TABLES `configs` WRITE;
/*!40000 ALTER TABLE `configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consolidated_stat_urls_after`
--

DROP TABLE IF EXISTS `consolidated_stat_urls_after`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consolidated_stat_urls_after` (
  `date_l` date NOT NULL,
  `page_c` varchar(255) NOT NULL,
  `session_j` varchar(70) NOT NULL,
  `site_id` int(10) DEFAULT NULL,
  `eletype` varchar(100) DEFAULT NULL,
  `eleid` int(11) DEFAULT NULL,
  KEY `idx` (`page_c`,`date_l`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consolidated_stat_urls_after`
--

LOCK TABLES `consolidated_stat_urls_after` WRITE;
/*!40000 ALTER TABLE `consolidated_stat_urls_after` DISABLE KEYS */;
/*!40000 ALTER TABLE `consolidated_stat_urls_after` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consolidated_stat_urls_all`
--

DROP TABLE IF EXISTS `consolidated_stat_urls_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consolidated_stat_urls_all` (
  `date_l` date NOT NULL,
  `page_c` varchar(255) NOT NULL,
  `session_j` varchar(70) NOT NULL,
  `site_id` int(10) DEFAULT NULL,
  `eletype` varchar(100) DEFAULT NULL,
  `eleid` int(11) DEFAULT NULL,
  KEY `idx` (`page_c`,`date_l`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consolidated_stat_urls_all`
--

LOCK TABLES `consolidated_stat_urls_all` WRITE;
/*!40000 ALTER TABLE `consolidated_stat_urls_all` DISABLE KEYS */;
/*!40000 ALTER TABLE `consolidated_stat_urls_all` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consolidated_stat_urls_before`
--

DROP TABLE IF EXISTS `consolidated_stat_urls_before`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consolidated_stat_urls_before` (
  `date_l` date NOT NULL,
  `page_c` varchar(255) NOT NULL,
  `session_j` varchar(70) NOT NULL,
  `site_id` int(10) DEFAULT NULL,
  `eletype` varchar(100) DEFAULT NULL,
  `eleid` int(11) DEFAULT NULL,
  KEY `idx` (`page_c`,`date_l`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consolidated_stat_urls_before`
--

LOCK TABLES `consolidated_stat_urls_before` WRITE;
/*!40000 ALTER TABLE `consolidated_stat_urls_before` DISABLE KEYS */;
/*!40000 ALTER TABLE `consolidated_stat_urls_before` ENABLE KEYS */;
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
  `phase` varchar(75) DEFAULT NULL
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
-- Temporary table structure for view `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!50001 DROP VIEW IF EXISTS `customer`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `customer` (
  `customerid` tinyint NOT NULL,
  `orderid` tinyint NOT NULL,
  `parent_uuid` tinyint NOT NULL,
  `identityId` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `surnames` tinyint NOT NULL,
  `contactPhoneNumber1` tinyint NOT NULL,
  `nationality` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `IdentityType` tinyint NOT NULL,
  `total_price` tinyint NOT NULL,
  `tm` tinyint NOT NULL,
  `baline1` tinyint NOT NULL,
  `baline2` tinyint NOT NULL,
  `batowncity` tinyint NOT NULL,
  `bapostalCode` tinyint NOT NULL,
  `salutation` tinyint NOT NULL,
  `infoSup1` tinyint NOT NULL,
  `client_id` tinyint NOT NULL,
  `creationDate` tinyint NOT NULL,
  `orderRef` tinyint NOT NULL,
  `lang` tinyint NOT NULL,
  `order_snapshot` tinyint NOT NULL,
  `daline1` tinyint NOT NULL,
  `daline2` tinyint NOT NULL,
  `datowncity` tinyint NOT NULL,
  `dapostalCode` tinyint NOT NULL,
  `menu_uuid` tinyint NOT NULL,
  `currency` tinyint NOT NULL,
  `ip` tinyint NOT NULL,
  `spaymentmean` tinyint NOT NULL,
  `shipping_method_id` tinyint NOT NULL,
  `payment_ref_id` tinyint NOT NULL,
  `payment_id` tinyint NOT NULL,
  `payment_token` tinyint NOT NULL,
  `payment_url` tinyint NOT NULL,
  `payment_notif_token` tinyint NOT NULL,
  `payment_status` tinyint NOT NULL,
  `payment_txn_id` tinyint NOT NULL,
  `lastid` tinyint NOT NULL,
  `payment_fees` tinyint NOT NULL,
  `delivery_fees` tinyint NOT NULL,
  `orderType` tinyint NOT NULL,
  `transaction_code` tinyint NOT NULL,
  `tracking_number` tinyint NOT NULL,
  `promo_code` tinyint NOT NULL,
  `courier_name` tinyint NOT NULL,
  `identityPhoto` tinyint NOT NULL,
  `newPhoneNumber` tinyint NOT NULL,
  `selected_boutique` tinyint NOT NULL,
  `rdv_boutique` tinyint NOT NULL,
  `rdv_date` tinyint NOT NULL,
  `delivery_type` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `country` tinyint NOT NULL,
  `newsletter` tinyint NOT NULL,
  `comments` tinyint NOT NULL,
  `extra_field_1` tinyint NOT NULL,
  `extra_field_2` tinyint NOT NULL,
  `extra_field_3` tinyint NOT NULL,
  `extra_field_4` tinyint NOT NULL,
  `extra_field_5` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `dashboard_emails`
--

DROP TABLE IF EXISTS `dashboard_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_emails` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `subject` varchar(1000) NOT NULL,
  `message` mediumtext NOT NULL,
  `dashboard_pdf` varchar(100) NOT NULL,
  `email_sent` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_emails`
--

LOCK TABLES `dashboard_emails` WRITE;
/*!40000 ALTER TABLE `dashboard_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_filters`
--

DROP TABLE IF EXISTS `dashboard_filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filter_name` varchar(100) NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `created_on` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_filters`
--

LOCK TABLES `dashboard_filters` WRITE;
/*!40000 ALTER TABLE `dashboard_filters` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_filters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_filters_items`
--

DROP TABLE IF EXISTS `dashboard_filters_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_filters_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filter_id` varchar(100) NOT NULL,
  `filter_type` varchar(100) NOT NULL,
  `filter_on` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `created_on` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_filters` (`filter_id`,`filter_type`,`filter_on`) USING HASH
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_filters_items`
--

LOCK TABLES `dashboard_filters_items` WRITE;
/*!40000 ALTER TABLE `dashboard_filters_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_filters_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_phases_config`
--

DROP TABLE IF EXISTS `dashboard_phases_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_phases_config` (
  `site_id` int(11) NOT NULL,
  `ctype` varchar(50) NOT NULL,
  `process` varchar(75) NOT NULL,
  `phase` varchar(75) NOT NULL,
  PRIMARY KEY (`site_id`,`ctype`,`process`,`phase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_phases_config`
--

LOCK TABLES `dashboard_phases_config` WRITE;
/*!40000 ALTER TABLE `dashboard_phases_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_phases_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_urls`
--

DROP TABLE IF EXISTS `dashboard_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_urls` (
  `url_type` varchar(20) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `url_group` varchar(20) DEFAULT '',
  `color` varchar(20) DEFAULT '',
  `sort_order` int(11) DEFAULT NULL,
  `label` varchar(20) DEFAULT '',
  `table_name` varchar(50) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`url_type`,`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_urls`
--

LOCK TABLES `dashboard_urls` WRITE;
/*!40000 ALTER TABLE `dashboard_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynaction`
--

DROP TABLE IF EXISTS `dynaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynaction` (
  `tag` varchar(8) NOT NULL,
  `className` varchar(16) DEFAULT NULL,
  `eventSql` text DEFAULT NULL,
  PRIMARY KEY (`tag`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynaction`
--

LOCK TABLES `dynaction` WRITE;
/*!40000 ALTER TABLE `dynaction` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynaction` ENABLE KEYS */;
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
/*!40000 ALTER TABLE `errcode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `etn_function`
--

DROP TABLE IF EXISTS `etn_function`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `etn_function` (
  `Etn_Function_id` int(11) NOT NULL,
  `Etn_function` varchar(50) DEFAULT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Archive` int(11) DEFAULT NULL,
  `POS` varchar(255) DEFAULT '',
  `parent_function_id` int(11) DEFAULT NULL,
  `function_level` varchar(100) DEFAULT '',
  `Fils` varchar(100) DEFAULT '',
  PRIMARY KEY (`Etn_Function_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `etn_function`
--

LOCK TABLES `etn_function` WRITE;
/*!40000 ALTER TABLE `etn_function` DISABLE KEYS */;
/*!40000 ALTER TABLE `etn_function` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exclusion`
--

DROP TABLE IF EXISTS `exclusion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exclusion` (
  `osiris` int(1) NOT NULL DEFAULT 0,
  `db` varchar(16) NOT NULL DEFAULT '',
  `expr` varchar(128) DEFAULT NULL,
  `exclusion_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`exclusion_id`),
  KEY `Index_1` (`osiris`,`db`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exclusion`
--

LOCK TABLES `exclusion` WRITE;
/*!40000 ALTER TABLE `exclusion` DISABLE KEYS */;
/*!40000 ALTER TABLE `exclusion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_orders_logs`
--

DROP TABLE IF EXISTS `external_orders_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_orders_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_key_id` varchar(100) NOT NULL,
  `order_uuid` varchar(50) DEFAULT NULL,
  `req` longtext DEFAULT NULL,
  `resp` longtext DEFAULT NULL,
  `create_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_orders_logs`
--

LOCK TABLES `external_orders_logs` WRITE;
/*!40000 ALTER TABLE `external_orders_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `external_orders_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_phases`
--

DROP TABLE IF EXISTS `external_phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_phases` (
  `start_proc` varchar(75) NOT NULL,
  `next_proc` varchar(75) NOT NULL,
  `next_phase` varchar(75) NOT NULL,
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
-- Table structure for table `field_names`
--

DROP TABLE IF EXISTS `field_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `screenName` varchar(25) NOT NULL,
  `fieldName` varchar(35) NOT NULL,
  `displayName` varchar(75) NOT NULL,
  `isLabel` tinyint(1) NOT NULL DEFAULT 0,
  `section` varchar(50) NOT NULL,
  `sectionDisplaySeq` int(11) NOT NULL DEFAULT 0,
  `query` text DEFAULT NULL,
  `fieldDisplaySeq` int(11) NOT NULL DEFAULT 0,
  `fieldType` varchar(25) DEFAULT NULL,
  `tab` varchar(50) NOT NULL,
  `tabDisplaySeq` int(11) NOT NULL,
  `tabId` varchar(25) NOT NULL,
  `tableName` varchar(25) DEFAULT NULL,
  `input_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `screenName` (`screenName`,`fieldName`)
) ENGINE=MyISAM AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_names`
--

LOCK TABLES `field_names` WRITE;
/*!40000 ALTER TABLE `field_names` DISABLE KEYS */;
INSERT INTO `field_names` VALUES (1,'CUSTOMER_EDIT','delivery_type','Delivery Type',0,'Delivery Address',5,'',6,'','Customer Information',1,'','orders','text'),(2,'CUSTOMER_EDIT','rdv_boutique','Appointment',0,'Delivery Address',5,'select \'false\', \'No\' from dual union select \'true\', \'Yes\' from dual;',7,'','Customer Information',1,'','orders','select'),(3,'CUSTOMER_EDIT','rdv_date','Appointment Time',0,'Delivery Address',5,'',8,'','Customer Information',1,'','orders','text'),(4,'CUSTOMER_EDIT','tracking_number','Tracking Number',0,'Tracking Info',4,'',2,'','Order Information',2,'','orders','text'),(6,'CUSTOMER_EDIT','courier_name','Courier Name',0,'Tracking Info',4,'',1,'','Order Information',2,'','orders','text'),(7,'CUSTOMER_EDIT','email','Email',0,'Contact Info',3,'',2,'','Customer Information',1,'','orders','text'),(8,'CUSTOMER_EDIT','contactPhoneNumber1','Telephone',0,'Contact Info',3,'',1,'','Customer Information',1,'','orders','text'),(9,'CUSTOMER_EDIT','country','Country',0,'Billing Address',4,'',5,'','Customer Information',1,'','orders','text'),(10,'CUSTOMER_EDIT','batowncity','Town/City',0,'Billing Address',4,'',4,'','Customer Information',1,'','orders','text'),(11,'CUSTOMER_EDIT','bapostalCode','Postal Code',0,'Billing Address',4,'',3,'','Customer Information',1,'','orders','text'),(12,'CUSTOMER_EDIT','baline2','Address Line 2',0,'Billing Address',4,'',2,'','Customer Information',1,'','orders','text'),(13,'CUSTOMER_EDIT','baline1','Address Line 1',0,'Billing Address',4,'',1,'','Customer Information',1,'','orders','text'),(14,'CUSTOMER_EDIT','surnames','Surname',0,'Client Data',2,'',4,'','Customer Information',1,'','orders','text'),(15,'CUSTOMER_EDIT','name','First Name',0,'Client Data',2,'',3,'','Customer Information',1,'','orders','text'),(16,'CUSTOMER_EDIT','orderRef','Order Ref #',1,'Customer Info',1,'',2,'','Customer Information',1,'','orders','text'),(17,'CUSTOMER_EDIT','insertionDate','Phase Date',1,'Customer Info',1,'',3,'','Customer Information',1,'','orders','text'),(18,'CUSTOMER_EDIT','phase','Phase',1,'Customer Info',1,'',1,'','Customer Information',1,'','orders','text'),(19,'CUSTOMER_EDIT','creationDate','Order Date',1,'Customer Info',1,'',4,'','Customer Information',1,'','orders','text'),(20,'CUSTOMER_EDIT','orderId','Order Id',1,'Customer Info',1,'',5,'','Customer Information',1,'','orders','text'),(21,'CUSTOMER_EDIT','newPhoneNumber','Numéro Orange',0,'Contact Info',3,'',4,'','Customer Information',1,'','orders','text'),(22,'CUSTOMER_EDIT','supplier_id','Supplier',0,'Supplier Detail',1,'SELECT id, supplier FROM supplier GROUP BY 1, 2;',1,'','Supplier Detail',5,'','order_items','select'),(23,'CUSTOMER_EDIT','supplier','Supplier',1,'Supplier Detail',1,'',2,'','Supplier Detail',5,'','supplier','text'),(24,'CUSTOMER_EDIT','category','Category',1,'Supplier Detail',1,'',3,'','Supplier Detail',5,'','supplier','text'),(25,'CUSTOMER_EDIT','address','Address',1,'Supplier Detail',1,'',4,'','Supplier Detail',5,'','supplier','text'),(26,'CUSTOMER_EDIT','supplier_email','Email',1,'Supplier Detail',1,'',5,'','Supplier Detail',5,'','supplier','text'),(27,'CUSTOMER_EDIT','phone_number','Phone',1,'Supplier Detail',1,'',6,'','Supplier Detail',5,'','supplier','text'),(28,'CUSTOMER_EDIT','supplier_detail','Supplier Details',1,'Supplier Detail',1,'',7,'','Supplier Detail',5,'','supplier','text'),(29,'CUSTOMER_EDIT','identityPhoto','Identity Photo',0,'Client Data',2,'',7,'','Customer Information',1,'','orders','image'),(30,'CUSTOMER_EDIT','salutation','Civility',0,'Client Data',2,'',1,'','Customer Information',1,'','orders','text'),(31,'CUSTOMER_EDIT','IdentityType','Identity Type',0,'Client Data',2,'',5,'','Customer Information',1,'','orders','text'),(32,'CUSTOMER_EDIT','identityId','Identity ID',0,'Client Data',2,'',6,'','Customer Information',1,'','orders','text'),(33,'CUSTOMER_EDIT','newsletter','Newsletter',0,'Contact Info',3,'select 1, \'Yes\' from dual union select 0, \'No\' from dual;',3,'','Customer Information',1,'','orders','select'),(34,'CUSTOMER_EDIT','daline1','Address Line 1',0,'Delivery Address',5,'',3,'','Customer Information',1,'','orders','text'),(35,'CUSTOMER_EDIT','daline2','Address Line 2',0,'Delivery Address',5,'',4,'','Customer Information',1,'','orders','text'),(36,'CUSTOMER_EDIT','dapostalCode','Postal Code',0,'Delivery Address',5,'',5,'','Customer Information',1,'','orders','text'),(37,'CUSTOMER_EDIT','datowncity','Town/City',0,'Delivery Address',5,'',1,'','Customer Information',1,'','orders','text'),(38,'CUSTOMER_EDIT','shipping_method_id','Delivery Mode',0,'Delivery Address',5,'select method, displayName from GlobalParm_CATALOG_DB.delivery_methods where enable=1 and site_id=Orders_SITE_ID group by method;',2,'','Customer Information',1,'','orders','select'),(39,'CUSTOMER_EDIT','spaymentmean','Payment Method',0,'Payment Info',2,'select method, displayName from GlobalParm_CATALOG_DB.payment_methods where enable=1 and site_id=Orders_SITE_ID;',1,'','Order Information',2,'','orders','select'),(40,'CUSTOMER_EDIT','transaction_code','Transaction Code',0,'Payment Info',2,'',2,'','Order Information',2,'','orders','text'),(41,'CUSTOMER_EDIT','promo_code','Promo Code',0,'Payment Info',2,'',3,'','Order Information',2,'','orders','text'),(42,'CUSTOMER_EDIT','remaining_promo_value','Remaining Promo Value',1,'Payment Info',2,NULL,4,'','Order Information',2,'','orders','text'),(46,'CUSTOMER_EDIT','delivery_date','Preferred date',0,'Home delivery',6,NULL,1,'text','Customer Information',1,'','','text'),(47,'CUSTOMER_EDIT','delivery_slot','Preferred slot',0,'Home delivery',6,NULL,2,'text','Customer Information',1,'','','text');
/*!40000 ALTER TABLE `field_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_names_v2`
--

DROP TABLE IF EXISTS `field_names_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_names_v2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `screenId` int(11) NOT NULL,
  `sectionId` int(11) NOT NULL,
  `fieldType` varchar(25) CHARACTER SET utf8 NOT NULL,
  `columnName` varchar(35) NOT NULL,
  `fieldLabel` varchar(35) CHARACTER SET utf8 NOT NULL,
  `fieldSequence` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_names_v2`
--

LOCK TABLES `field_names_v2` WRITE;
/*!40000 ALTER TABLE `field_names_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_names_v2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_settings`
--

DROP TABLE IF EXISTS `field_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `phase` varchar(75) DEFAULT NULL,
  `screenName` varchar(25) DEFAULT NULL,
  `fieldName` varchar(35) DEFAULT NULL,
  `isMandatory` tinyint(1) NOT NULL DEFAULT 0,
  `isHidden` tinyint(1) NOT NULL DEFAULT 0,
  `isEditable` tinyint(1) NOT NULL DEFAULT 0,
  `process` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `process` (`process`,`phase`,`screenName`,`fieldName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_settings`
--

LOCK TABLES `field_settings` WRITE;
/*!40000 ALTER TABLE `field_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_screen`
--

DROP TABLE IF EXISTS `form_screen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_screen` (
  `id` int(11) NOT NULL,
  `screenName` varchar(25) NOT NULL,
  `tableName` varchar(25) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_screen`
--

LOCK TABLES `form_screen` WRITE;
/*!40000 ALTER TABLE `form_screen` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_screen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_section`
--

DROP TABLE IF EXISTS `form_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_section` (
  `id` int(11) NOT NULL,
  `section` varchar(35) NOT NULL,
  `sectionSequence` int(11) NOT NULL,
  `screenId` varchar(25) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_section`
--

LOCK TABLES `form_section` WRITE;
/*!40000 ALTER TABLE `form_section` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_section` ENABLE KEYS */;
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
  `muid` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `lastId` int(10) unsigned DEFAULT NULL,
  `lang` varchar(5) DEFAULT NULL,
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
-- Table structure for table `generic_forms_process_mapping`
--

DROP TABLE IF EXISTS `generic_forms_process_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic_forms_process_mapping` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_name` varchar(255) DEFAULT NULL,
  `process` varchar(75) DEFAULT NULL,
  `phase` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_name` (`form_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generic_forms_process_mapping`
--

LOCK TABLES `generic_forms_process_mapping` WRITE;
/*!40000 ALTER TABLE `generic_forms_process_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `generic_forms_process_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `has_action`
--

DROP TABLE IF EXISTS `has_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `has_action` (
  `start_proc` varchar(75) NOT NULL,
  `start_phase` varchar(75) NOT NULL,
  `cle` int(10) unsigned NOT NULL,
  `action` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`start_proc`,`start_phase`),
  UNIQUE KEY `cle` (`cle`),
  UNIQUE KEY `cle_2` (`cle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `has_action`
--

LOCK TABLES `has_action` WRITE;
/*!40000 ALTER TABLE `has_action` DISABLE KEYS */;
INSERT INTO `has_action` VALUES ('OBF','ColisRemisAuLivreur',4559,'sql:processNow'),('OBF','CommanceValidee',4576,'mail:9, sql:shippingType'),('OBF','LivraisonDomicile',4568,'sql:processNow'),('Order','OrderReceived',4575,'mail:7,sql:processNow'),('OBF','DisponibleEnBoutique',4552,'mail:5,sql:wait7days'),('OBF','RelanceDisponible',4554,'mail:6'),('OBF','ColisRemis',4556,'sql:wait2days'),('OrangeMoney','ApiError',4587,'sql:wait5minutes'),('OrangeMoney','ProcessPayment',4581,'ompayment:process'),('OrangeMoney','PaymentSuccess',4586,'sql:processNow'),('OrangeMoney','PaymentError',4585,'sql:wait5minutes'),('OrangeMoney','CheckCustWaitTime',4593,'sql:checkCustWaitTime'),('OrangeMoney','NotifyBackOffice',4589,'mail:8'),('OrangeMoney','NotifyNoWaitBackOffice',4595,'mail:9'),('Order','InitiatePayment',4598,'sql:waitPayment30mins'),('Order-9','InitiatePayment',4600,'sql:waitPayment30mins'),('DevOrder-9','ValidatePaymentAmount',4602,'sql:validatePaymentAmount'),('DevOrder-9','VerifyPayment',4604,'payment:verify'),('DevOrder-9','OrderConfirmed',4606,'sql:processNow'),('DevOrder-9','SendEmail',4607,'mail:10,sql:processNow'),('DevOrder-9','StockMinus',4608,'sql:stockMinus,sql:processNow'),('DevOrder-9','StartOrderProcessing',4609,'sql:processNow'),('Forms-9','Formsubmitted',4610,'mail:12,sql:processNow'),('SSO-9','OrderRecv',4613,'sso:signup'),('Payments-9','ProcessPayment',4614,'sql:checkPaymentMethod'),('Payments-9','PaymentError',4620,'sql:wait5mins'),('Payments-9','ApiError',4621,'sql:wait5mins'),('Order-9','OrderReceived',4622,'sql:processNow'),('PaymentProcess-9','ProcessPayment',4611,'sql:waitPayment30mins');
/*!40000 ALTER TABLE `has_action` ENABLE KEYS */;
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
-- Table structure for table `login`
--

DROP TABLE IF EXISTS `login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login` (
  `pid` int(11) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL DEFAULT '',
  `language` int(11) NOT NULL DEFAULT 0,
  `pass` varchar(75) NOT NULL,
  `sso_id` varchar(36) DEFAULT NULL,
  `access_time` datetime DEFAULT NULL,
  `access_id` varchar(50) DEFAULT NULL,
  `puid` varchar(36) NOT NULL,
  `pass_expiry` date NOT NULL,
  `is_two_auth_enabled` tinyint(1) DEFAULT 0,
  `send_email` tinyint(1) DEFAULT 0,
  `secret_key` varchar(100) DEFAULT NULL,
  `selected_site_id` int(11) NOT NULL DEFAULT 0,
  `allowed_ips` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `puid` (`puid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login`
--

LOCK TABLES `login` WRITE;
/*!40000 ALTER TABLE `login` DISABLE KEYS */;
/*!40000 ALTER TABLE `login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_tries`
--

DROP TABLE IF EXISTS `login_tries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_tries` (
  `ip` varchar(50) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  `attempt` int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_tries`
--

LOCK TABLES `login_tries` WRITE;
/*!40000 ALTER TABLE `login_tries` DISABLE KEYS */;
/*!40000 ALTER TABLE `login_tries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_config`
--

DROP TABLE IF EXISTS `mail_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_config` (
  `id` int(10) unsigned NOT NULL,
  `ordertype` varchar(24) NOT NULL,
  `email_to` mediumtext DEFAULT NULL,
  `where_clause` mediumtext DEFAULT NULL,
  `attach` varchar(255) DEFAULT NULL,
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
  `site_id` int(11) NOT NULL DEFAULT 0,
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
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `orderStatus` enum('IN PROGRESS','CLOSED','CANCELLED','HISTORY','INITIALISED','IN ORDER','SUSPENDED','REMOVED','ABORTED') DEFAULT NULL,
  `price` varchar(32) DEFAULT NULL,
  `product_name` varchar(128) NOT NULL,
  `product_type` varchar(32) NOT NULL,
  `catalog_name` varchar(255) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `parent_id` varchar(50) NOT NULL,
  `comments` text DEFAULT NULL,
  `updatedBy` varchar(50) DEFAULT NULL,
  `updatedDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `product_ref` varchar(50) DEFAULT NULL,
  `installment_duration_unit` varchar(32) DEFAULT NULL,
  `installment_duration` varchar(32) DEFAULT NULL,
  `installment_price` varchar(32) DEFAULT NULL,
  `installment_recurring_price` varchar(32) DEFAULT NULL,
  `business_type` varchar(25) DEFAULT NULL,
  `installment_plan` varchar(25) DEFAULT NULL,
  `attributes` text DEFAULT NULL,
  `service_start_time` int(11) DEFAULT NULL,
  `service_date` varchar(10) DEFAULT NULL,
  `product_snapshot` mediumtext DEFAULT NULL,
  `service_duration` int(11) DEFAULT NULL,
  `service_end_date` varchar(10) DEFAULT NULL,
  `lastid` int(11) DEFAULT NULL,
  `resource` varchar(255) DEFAULT NULL,
  `service_gap` int(11) DEFAULT NULL,
  `secondary_resource` varchar(255) DEFAULT NULL,
  `actual_amount_collected` varchar(32) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `product_rating` tinyint(4) DEFAULT NULL,
  `complaint` text DEFAULT NULL,
  `complaint_response` text DEFAULT NULL,
  `price_value` varchar(32) DEFAULT NULL,
  `tax_percentage` varchar(10) DEFAULT NULL,
  `brand_name` varchar(100) DEFAULT NULL,
  `product_full_name` varchar(255) DEFAULT NULL,
  `advance_duration` varchar(32) DEFAULT NULL,
  `advance_amount` varchar(32) DEFAULT NULL,
  `price_old_value` varchar(32) DEFAULT NULL,
  `installment_old_recurring_price` varchar(32) DEFAULT NULL,
  `installment_discount_duration` int(11) DEFAULT NULL,
  `comewiths` longtext DEFAULT NULL,
  `additionalfees` mediumtext DEFAULT NULL,
  `promotion` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id_index` (`parent_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_kyc_info`
--

DROP TABLE IF EXISTS `order_kyc_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_kyc_info` (
  `order_id` int(11) NOT NULL,
  `kyc_uid` varchar(50) NOT NULL,
  `kyc_resp` longtext DEFAULT NULL,
  `kyc_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `kyc_status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`kyc_uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_kyc_info`
--

LOCK TABLES `order_kyc_info` WRITE;
/*!40000 ALTER TABLE `order_kyc_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_kyc_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_uuid` varchar(50) NOT NULL,
  `identityId` varchar(25) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `surnames` varchar(100) DEFAULT NULL,
  `contactPhoneNumber1` varchar(15) NOT NULL,
  `nationality` varchar(30) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `identityType` varchar(500) DEFAULT NULL,
  `total_price` varchar(32) DEFAULT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  `baline1` varchar(128) DEFAULT NULL,
  `baline2` varchar(128) DEFAULT NULL,
  `batowncity` varchar(64) DEFAULT NULL,
  `bapostalCode` varchar(5) DEFAULT NULL,
  `salutation` char(4) DEFAULT '',
  `infoSup1` varchar(100) DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `creationDate` datetime NOT NULL,
  `orderRef` varchar(25) DEFAULT NULL,
  `lang` varchar(2) DEFAULT NULL,
  `order_snapshot` text DEFAULT NULL,
  `daline1` varchar(128) DEFAULT NULL,
  `daline2` varchar(128) DEFAULT NULL,
  `datowncity` varchar(64) DEFAULT NULL,
  `dapostalCode` varchar(5) DEFAULT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  `currency` varchar(25) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `spaymentmean` varchar(20) NOT NULL,
  `shipping_method_id` varchar(25) DEFAULT NULL,
  `payment_ref_id` varchar(50) NOT NULL DEFAULT '',
  `payment_id` varchar(100) NOT NULL DEFAULT '',
  `payment_token` varchar(1000) NOT NULL DEFAULT '',
  `payment_url` varchar(1000) NOT NULL DEFAULT '',
  `payment_notif_token` varchar(1000) NOT NULL DEFAULT '',
  `payment_status` varchar(100) NOT NULL DEFAULT '',
  `payment_txn_id` varchar(1000) NOT NULL DEFAULT '',
  `lastid` int(11) DEFAULT NULL,
  `payment_fees` varchar(32) DEFAULT NULL,
  `delivery_fees` varchar(32) DEFAULT NULL,
  `orderType` varchar(32) DEFAULT NULL,
  `transaction_code` varchar(255) DEFAULT NULL,
  `promo_code` varchar(50) DEFAULT NULL,
  `tracking_number` varchar(50) DEFAULT NULL,
  `courier_name` varchar(50) DEFAULT NULL,
  `identityPhoto` varchar(50) DEFAULT NULL,
  `newPhoneNumber` varchar(15) DEFAULT NULL,
  `selected_boutique` text DEFAULT NULL,
  `rdv_boutique` varchar(5) DEFAULT NULL,
  `rdv_date` datetime DEFAULT NULL,
  `delivery_type` varchar(50) DEFAULT NULL,
  `site_id` int(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `newsletter` tinyint(1) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `currency_code` varchar(5) NOT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `payment_ref_total_amount` varchar(32) DEFAULT NULL,
  `cart_type` varchar(50) DEFAULT NULL,
  `payment_is_success` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Client side payment flows like Group orange money and paypal insert order in db using initiatePayment flow. In these cases the value of this column must be set to true once payment is done as this flag is used in process flow',
  `additional_info` mediumtext DEFAULT NULL,
  `updated_ts` datetime DEFAULT NULL,
  `extra_field_1` varchar(255) DEFAULT NULL COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table',
  `extra_field_2` varchar(255) DEFAULT NULL COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table',
  `extra_field_3` varchar(255) DEFAULT NULL COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table',
  `extra_field_4` varchar(255) DEFAULT NULL COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table',
  `extra_field_5` varchar(255) DEFAULT NULL COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table',
  `is_external` tinyint(1) NOT NULL DEFAULT 0,
  `x_forwarded_for` varchar(255) DEFAULT NULL,
  `cart_id` int(11) NOT NULL,
  `delivery_date` date DEFAULT NULL,
  `delivery_start_hour` int(2) DEFAULT NULL,
  `delivery_start_min` int(2) DEFAULT NULL,
  `delivery_end_hour` int(2) DEFAULT NULL,
  `delivery_end_min` int(2) DEFAULT NULL,
  `forter_token` varchar(255) DEFAULT NULL,
  `forter_decision` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
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
INSERT INTO `osql` VALUES ('processNow','1',NULL,'select 0'),('waitProcessNow','1',NULL,'select case when flag > 0 then 0 else 120000 end from post_work where id =  $wkid'),('IdentifyOrderType','1',NULL,'select case when (product_type = \'subscription_webapp\' ) then 7 when (product_type = \'product\' and catalog_name = \'Montres\') then 3 when (product_type = \'service\' and product_name = \'absence product\') then 5 when product_type = \'service\' then 0 when product_type = \'product\' then 1 when product_type like \'%fiber%\' then 30001 end from order_items where id = $clid'),('shippingType','1',NULL,'select case when shipping_method_id=\'home_delivery\' then 0 else 1 end from orders where id = $clid'),('wait7days','1',NULL,'select case when adddate(insertion_date, interval 7 day) > now() then 120720 else 19 end from post_work where id = $wkid'),('wait2days','1','','select case when adddate(insertion_date, interval 2 day) > now() then 120360 else 0 end from post_work where id = $wkid'),('wait5minutes','1',NULL,'select case when adddate(insertion_date, interval 5 minute) > now() then 120005 else 0 end from post_work where id = $wkid'),('wait10minutes','1',NULL,'select case when adddate(insertion_date, interval 10 minute) > now() then 120010 else 0 end from post_work where id = $wkid'),('checkCustWaitTime','1',NULL,'select case when coalesce(payment_status,\'\') = \'CUSTOMER_TIMEOUT\' then 5 else 19 end from orders where id = $clid'),('CheckPayment','1',NULL,'select case when spaymentmean in (\'cash_on_pickup\',\'cash_on_delivery\') then 0 when payment_status = \'SUCCESS\' then 0 when payment_status = \'verify_payment\' then 15 else 19 end from orders where id = $clid'),('validatePaymentAmount','1',NULL,'select case when spaymentmean = \'cash_on_delivery\' or spaymentmean = \'cash_on_pickup\' then 0 when COALESCE(cast(total_price as double),0) = COALESCE(cast(payment_ref_total_amount as double),0) then 0 else 19 end from orders where id = $clid'),('waitPayment30mins','1',NULL,'select case when coalesce(payment_is_success,0) = 1 then 0 when adddate(tm, interval 30 minute) <= now() then 19 else 120005 end from orders where id = $clid');
/*!40000 ALTER TABLE `osql` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page` (
  `name` varchar(45) CHARACTER SET latin1 DEFAULT NULL,
  `url` varchar(150) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `parent` varchar(80) CHARACTER SET latin1 DEFAULT NULL,
  `rang` int(10) unsigned DEFAULT NULL,
  `new_tab` tinyint(1) DEFAULT 0,
  `icon` varchar(20) DEFAULT NULL,
  `parent_icon` varchar(20) DEFAULT NULL,
  `menu_badge` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page`
--

LOCK TABLES `page` WRITE;
/*!40000 ALTER TABLE `page` DISABLE KEYS */;
INSERT INTO `page` VALUES ('Orders','/asimina_shop/ibo.jsp','',1,0,'cui-home',NULL,NULL),('Supplier','/asimina_shop/admin/supplier.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('View Process','/asimina_shop/viewProcess.jsp','Processes',2,0,'cui-cursor','cui-graph',NULL),('Orders form field settings','/asimina_shop/admin/fieldSettings.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('User management','/asimina_shop/admin/userManagement.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Profile management','/asimina_shop/admin/manageProfil.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Asimina','/asimina_catalog/admin/gestion.jsp','',51,1,'cui-cart',NULL,NULL),('Profils','/asimina_shop/admin/profilManagement.jsp','Customers',52,0,'cui-user-follow','cui-people',NULL),('Order Tracking Visible','/asimina_shop/admin/orderTrackingVisible.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Edit Process','/asimina_shop/processStatus.jsp','Processes',2,0,'cui-note','cui-graph',NULL),('Dashboard','/asimina_shop/dashboard/dashboard.jsp','Analytics',1,0,'cui-speedometer','cui-speedometer','NEW'),('Notifications','/asimina_shop/mail_sms/modele.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Accounts Blocking','/asimina_shop/admin/blockedUserConfig.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Store emails management','/asimina_shop/admin/storeEmailsManagement.jsp','Admin',3,0,'cui-wrench','cui-settings',NULL),('Incomplete Carts','/asimina_shop/admin/pendingCartsInfo.jsp',NULL,6,0,'cui-cart',NULL,NULL),('Home','/asimina_shop/admin/gestion.jsp',NULL,0,0,'cui-home',NULL,''),('Dashboard Filters','/asimina_shop/dashboard/dashboardFiltersList.jsp','Analytics',1,0,'cui-speedometer','cui-speedometer','NEW'),('Logs','/asimina_shop/admin/logListing.jsp','Admin',4,0,'cui-file',NULL,'BETA'),('Ban rules','/asimina_shop/admin/bannedRules.jsp','Admin',10,0,'cui-wrench','cui-settings','NEW');
/*!40000 ALTER TABLE `page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_profil`
--

DROP TABLE IF EXISTS `page_profil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_profil` (
  `url` varchar(150) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `profil_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`url`,`profil_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_profil`
--

LOCK TABLES `page_profil` WRITE;
/*!40000 ALTER TABLE `page_profil` DISABLE KEYS */;
INSERT INTO `page_profil` VALUES ('/',5);
/*!40000 ALTER TABLE `page_profil` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_sub_urls`
--

DROP TABLE IF EXISTS `page_sub_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_sub_urls` (
  `url` varchar(150) NOT NULL DEFAULT '',
  `sub_url` varchar(150) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_sub_urls`
--

LOCK TABLES `page_sub_urls` WRITE;
/*!40000 ALTER TABLE `page_sub_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_sub_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_actions`
--

DROP TABLE IF EXISTS `payment_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_actions` (
  `payment_method` varchar(75) NOT NULL,
  `className` varchar(255) NOT NULL,
  `revalidation_required` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`payment_method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_actions`
--

LOCK TABLES `payment_actions` WRITE;
/*!40000 ALTER TABLE `payment_actions` DISABLE KEYS */;
INSERT INTO `payment_actions` VALUES ('orange_money','com.etn.eshop.payment.GroupOrangeMoney',0),('paypal','com.etn.eshop.payment.PayPal',0),('cash_on_pickup','com.etn.eshop.payment.Cash',0),('cash_on_delivery','com.etn.eshop.payment.Cash',0);
/*!40000 ALTER TABLE `payment_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_actions_logs`
--

DROP TABLE IF EXISTS `payment_actions_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_actions_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wkid` varchar(25) DEFAULT NULL,
  `clid` varchar(25) DEFAULT NULL,
  `http_code` varchar(25) DEFAULT NULL,
  `req` text DEFAULT NULL,
  `resp` text DEFAULT NULL,
  `payment_method` varchar(255) NOT NULL,
  `action_type` varchar(75) NOT NULL,
  `error_code` varchar(10) DEFAULT NULL,
  `error_msg` text DEFAULT NULL,
  `status` enum('success','error') NOT NULL DEFAULT 'error',
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_actions_logs`
--

LOCK TABLES `payment_actions_logs` WRITE;
/*!40000 ALTER TABLE `payment_actions_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_actions_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_log`
--

DROP TABLE IF EXISTS `payment_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `payment_ref_id` varchar(50) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `action` varchar(500) NOT NULL,
  `url` varchar(1000) NOT NULL,
  `request` text NOT NULL,
  `response` text NOT NULL,
  `created_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_log`
--

LOCK TABLES `payment_log` WRITE;
/*!40000 ALTER TABLE `payment_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments_ref`
--

DROP TABLE IF EXISTS `payments_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `cart_id` int(11) NOT NULL,
  `paypal_order_id` varchar(255) DEFAULT NULL,
  `return_url` varchar(255) DEFAULT NULL,
  `cancel_url` varchar(255) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `is_success` tinyint(1) NOT NULL DEFAULT 0,
  `updated_ts` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments_ref`
--

LOCK TABLES `payments_ref` WRITE;
/*!40000 ALTER TABLE `payments_ref` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments_ref` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `person_id` int(11) NOT NULL AUTO_INCREMENT,
  `First_name` varchar(50) CHARACTER SET latin1 DEFAULT '',
  `last_name` varchar(50) CHARACTER SET latin1 DEFAULT '',
  `adress` varchar(255) CHARACTER SET latin1 DEFAULT '',
  `zip_code` varchar(50) CHARACTER SET latin1 DEFAULT '',
  `telephone` varchar(20) CHARACTER SET latin1 DEFAULT '',
  `e_mail` varchar(50) CHARACTER SET latin1 DEFAULT '',
  `country_id` int(11) DEFAULT 0,
  `fax` varchar(50) CHARACTER SET latin1 DEFAULT '',
  `grade` varchar(100) CHARACTER SET latin1 DEFAULT '',
  `ag_post` int(11) DEFAULT 0,
  `archive` int(11) DEFAULT NULL,
  `home_page` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `forgot_password` tinyint(1) NOT NULL DEFAULT 0,
  `forgot_pass_token` varchar(36) DEFAULT NULL,
  `forgot_pass_token_expiry` datetime DEFAULT NULL,
  `forgot_password_referrer` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`person_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_sites`
--

DROP TABLE IF EXISTS `person_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_sites` (
  `person_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`person_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_sites`
--

LOCK TABLES `person_sites` WRITE;
/*!40000 ALTER TABLE `person_sites` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phases`
--

DROP TABLE IF EXISTS `phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phases` (
  `process` varchar(75) NOT NULL,
  `phase` varchar(75) NOT NULL,
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
  `orderTrackVisible` tinyint(1) NOT NULL DEFAULT 1,
  `color` varchar(7) DEFAULT '#000000',
  `displayName1` varchar(100) DEFAULT NULL,
  `displayName2` varchar(100) DEFAULT NULL,
  `displayName3` varchar(100) DEFAULT NULL,
  `displayName4` varchar(100) DEFAULT NULL,
  `displayName5` varchar(100) DEFAULT NULL,
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
  `phase` varchar(75) DEFAULT NULL,
  `priority` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'now par defaut',
  `instance_agent` varchar(8) DEFAULT NULL COMMENT 'for multi-agent gizmo',
  `status` int(1) NOT NULL DEFAULT 0 COMMENT 'running action status ; 0 - init ; 1 : pris en running ; 2 : end',
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
  `is_generic_form` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `post_work_search` (`proces`,`phase`,`status`,`priority`),
  KEY `client_key` (`client_key`,`status`),
  KEY `ix_phase` (`phase`),
  KEY `ix_nextid` (`nextid`),
  KEY `cur` (`status`),
  KEY `ix_todo` (`priority`,`status`),
  KEY `ix_cur` (`insertion_date`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_work`
--

LOCK TABLES `post_work` WRITE;
/*!40000 ALTER TABLE `post_work` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_work` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `processes`
--

DROP TABLE IF EXISTS `processes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processes` (
  `process_name` varchar(75) NOT NULL,
  `display_name` varchar(75) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`process_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `processes`
--

LOCK TABLES `processes` WRITE;
/*!40000 ALTER TABLE `processes` DISABLE KEYS */;
/*!40000 ALTER TABLE `processes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profil`
--

DROP TABLE IF EXISTS `profil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profil` (
  `profil_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `profil` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `description` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `Archive` int(10) unsigned DEFAULT NULL,
  `home_page` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `color` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `assign_site` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`profil_id`)
) ENGINE=MyISAM AUTO_INCREMENT=60 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profil`
--

LOCK TABLES `profil` WRITE;
/*!40000 ALTER TABLE `profil` DISABLE KEYS */;
INSERT INTO `profil` VALUES (5,'ADMIN','Administrator',NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `profil` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profil_banned_phases`
--

DROP TABLE IF EXISTS `profil_banned_phases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profil_banned_phases` (
  `profil_id` int(10) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `phases` text DEFAULT NULL,
  PRIMARY KEY (`profil_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profil_banned_phases`
--

LOCK TABLES `profil_banned_phases` WRITE;
/*!40000 ALTER TABLE `profil_banned_phases` DISABLE KEYS */;
/*!40000 ALTER TABLE `profil_banned_phases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profilemenu`
--

DROP TABLE IF EXISTS `profilemenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profilemenu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idMenu` int(11) NOT NULL,
  `profile` varchar(30) NOT NULL,
  `displaySeqNum` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profilemenu`
--

LOCK TABLES `profilemenu` WRITE;
/*!40000 ALTER TABLE `profilemenu` DISABLE KEYS */;
/*!40000 ALTER TABLE `profilemenu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profilperson`
--

DROP TABLE IF EXISTS `profilperson`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profilperson` (
  `profil_id` int(10) unsigned NOT NULL DEFAULT 0,
  `person_id` int(10) unsigned NOT NULL DEFAULT 0,
  `date_debut_valid` datetime DEFAULT NULL,
  `profilperson_id` int(11) NOT NULL AUTO_INCREMENT,
  `date_fin_valid` datetime DEFAULT NULL,
  PRIMARY KEY (`profilperson_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profilperson`
--

LOCK TABLES `profilperson` WRITE;
/*!40000 ALTER TABLE `profilperson` DISABLE KEYS */;
/*!40000 ALTER TABLE `profilperson` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provincia`
--

DROP TABLE IF EXISTS `provincia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provincia` (
  `name` varchar(24) NOT NULL DEFAULT '',
  `id` int(11) DEFAULT NULL,
  `zf` char(2) NOT NULL,
  `tva` int(2) DEFAULT NULL,
  `tipoImpuesto` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provincia`
--

LOCK TABLES `provincia` WRITE;
/*!40000 ALTER TABLE `provincia` DISABLE KEYS */;
/*!40000 ALTER TABLE `provincia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `public_urls`
--

DROP TABLE IF EXISTS `public_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `public_urls` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL DEFAULT '',
  `url_type` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `public_urls`
--

LOCK TABLES `public_urls` WRITE;
/*!40000 ALTER TABLE `public_urls` DISABLE KEYS */;
INSERT INTO `public_urls` VALUES (1,'/login.jsp','endsWith'),(2,'/logout.jsp','endsWith'),(4,'/forgotpassword.jsp','endsWith'),(5,'/resetpass.jsp','endsWith'),(6,'/resetpassbackend.jsp','endsWith'),(7,'/checkAuth.jsp','endsWith');
/*!40000 ALTER TABLE `public_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relation`
--

DROP TABLE IF EXISTS `relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relation` (
  `pid1` int(11) DEFAULT NULL,
  `Etn_function_id` int(11) DEFAULT NULL,
  `pid2` int(11) DEFAULT NULL,
  `Date_debut_Valid` datetime DEFAULT NULL,
  `relation_id` int(11) NOT NULL,
  `Date_Fin_Valid` datetime DEFAULT NULL,
  PRIMARY KEY (`relation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation`
--

LOCK TABLES `relation` WRITE;
/*!40000 ALTER TABLE `relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `responsibility`
--

DROP TABLE IF EXISTS `responsibility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `responsibility` (
  `Person_id` int(11) DEFAULT NULL,
  `Etn_function_id` int(11) DEFAULT NULL,
  `Entity_id` int(11) DEFAULT NULL,
  `Date_debut_Valid` datetime DEFAULT NULL,
  `responsibility_id` int(11) NOT NULL,
  `Date_Fin_Valid` datetime DEFAULT NULL,
  PRIMARY KEY (`responsibility_id`),
  KEY `ix_resp` (`Person_id`,`Entity_id`),
  KEY `ix_resp2` (`Person_id`,`Etn_function_id`,`Entity_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `responsibility`
--

LOCK TABLES `responsibility` WRITE;
/*!40000 ALTER TABLE `responsibility` DISABLE KEYS */;
/*!40000 ALTER TABLE `responsibility` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rlock`
--

DROP TABLE IF EXISTS `rlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rlock` (
  `id` int(10) unsigned NOT NULL,
  `is_generic_form` tinyint(1) NOT NULL DEFAULT 0,
  `csr` varchar(50) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`,`is_generic_form`)
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
  `start_phase` varchar(75) DEFAULT NULL,
  `errCode` int(11) NOT NULL DEFAULT 0,
  `next_proc` varchar(75) DEFAULT NULL,
  `next_phase` varchar(75) DEFAULT NULL,
  `nextestado` int(11) NOT NULL DEFAULT 0,
  `action` varchar(255) DEFAULT NULL,
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
-- Table structure for table `sms`
--

DROP TABLE IF EXISTS `sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms` (
  `sms_id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(50) DEFAULT NULL,
  `texte` text DEFAULT NULL,
  `where_clause` varchar(255) DEFAULT NULL,
  `lang_2_texte` text DEFAULT NULL,
  `lang_3_texte` text DEFAULT NULL,
  `lang_4_texte` text DEFAULT NULL,
  `lang_5_texte` text DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
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
-- Table structure for table `stock_mail`
--

DROP TABLE IF EXISTS `stock_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_mail` (
  `product_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  `variant_id` int(11) NOT NULL,
  `is_stock_alert` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`product_id`,`email`,`variant_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_mail`
--

LOCK TABLES `stock_mail` WRITE;
/*!40000 ALTER TABLE `stock_mail` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_mail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_emails`
--

DROP TABLE IF EXISTS `store_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `store_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(500) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `city` varchar(32) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_emails`
--

LOCK TABLES `store_emails` WRITE;
/*!40000 ALTER TABLE `store_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier` varchar(50) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `supplier_detail` varchar(250) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temporary_cart_items`
--

DROP TABLE IF EXISTS `temporary_cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temporary_cart_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) DEFAULT NULL,
  `product_id` varchar(50) DEFAULT NULL,
  `qty` int(11) DEFAULT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  `attributes` text DEFAULT NULL,
  `start_time` int(11) DEFAULT NULL,
  `date` varchar(10) DEFAULT NULL,
  `business_type` varchar(25) DEFAULT NULL,
  `installment_plan` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporary_cart_items`
--

LOCK TABLES `temporary_cart_items` WRITE;
/*!40000 ALTER TABLE `temporary_cart_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `temporary_cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uifilters`
--

DROP TABLE IF EXISTS `uifilters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uifilters` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user` varchar(50) DEFAULT NULL,
  `screen` varchar(10) DEFAULT NULL,
  `filter` mediumtext DEFAULT NULL,
  `defaultFilter` tinyint(1) NOT NULL DEFAULT 0,
  `createdOn` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `filter_user` (`user`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uifilters`
--

LOCK TABLES `uifilters` WRITE;
/*!40000 ALTER TABLE `uifilters` DISABLE KEYS */;
/*!40000 ALTER TABLE `uifilters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uipreferences`
--

DROP TABLE IF EXISTS `uipreferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uipreferences` (
  `user` varchar(50) NOT NULL,
  `screen` varchar(100) NOT NULL,
  `uiItem` varchar(100) NOT NULL,
  `value` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uipreferences`
--

LOCK TABLES `uipreferences` WRITE;
/*!40000 ALTER TABLE `uipreferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `uipreferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usage_logs`
--

DROP TABLE IF EXISTS `usage_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usage_logs` (
  `activity` varchar(25) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  `activity_from` varchar(15) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `user_agent` text DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usage_logs`
--

LOCK TABLES `usage_logs` WRITE;
/*!40000 ALTER TABLE `usage_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `usage_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_block_config`
--

DROP TABLE IF EXISTS `user_block_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_block_config` (
  `type` enum('user','ip') NOT NULL,
  `number_of_tries` varchar(50) NOT NULL DEFAULT '3',
  `block_time` varchar(50) NOT NULL DEFAULT '15',
  `block_time_unit` enum('minutes','hours','days','weeks') NOT NULL DEFAULT 'minutes'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_block_config`
--

LOCK TABLES `user_block_config` WRITE;
/*!40000 ALTER TABLE `user_block_config` DISABLE KEYS */;
INSERT INTO `user_block_config` VALUES ('user','3','15','minutes'),('ip','3','15','minutes');
/*!40000 ALTER TABLE `user_block_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_login_tries`
--

DROP TABLE IF EXISTS `user_login_tries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_login_tries` (
  `username` varchar(50) NOT NULL,
  `tm` timestamp NOT NULL DEFAULT current_timestamp(),
  `attempt` int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_login_tries`
--

LOCK TABLES `user_login_tries` WRITE;
/*!40000 ALTER TABLE `user_login_tries` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_login_tries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `customer`
--

/*!50001 DROP TABLE IF EXISTS `customer`*/;
/*!50001 DROP VIEW IF EXISTS `customer`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `customer` AS select `orders`.`id` AS `customerid`,`orders`.`id` AS `orderid`,`orders`.`parent_uuid` AS `parent_uuid`,`orders`.`identityId` AS `identityId`,`orders`.`name` AS `name`,`orders`.`surnames` AS `surnames`,`orders`.`contactPhoneNumber1` AS `contactPhoneNumber1`,`orders`.`nationality` AS `nationality`,`orders`.`email` AS `email`,`orders`.`identityType` AS `IdentityType`,`orders`.`total_price` AS `total_price`,`orders`.`tm` AS `tm`,`orders`.`baline1` AS `baline1`,`orders`.`baline2` AS `baline2`,`orders`.`batowncity` AS `batowncity`,`orders`.`bapostalCode` AS `bapostalCode`,`orders`.`salutation` AS `salutation`,`orders`.`infoSup1` AS `infoSup1`,`orders`.`client_id` AS `client_id`,`orders`.`creationDate` AS `creationDate`,`orders`.`orderRef` AS `orderRef`,`orders`.`lang` AS `lang`,`orders`.`order_snapshot` AS `order_snapshot`,`orders`.`daline1` AS `daline1`,`orders`.`daline2` AS `daline2`,`orders`.`datowncity` AS `datowncity`,`orders`.`dapostalCode` AS `dapostalCode`,`orders`.`menu_uuid` AS `menu_uuid`,`orders`.`currency` AS `currency`,`orders`.`ip` AS `ip`,`orders`.`spaymentmean` AS `spaymentmean`,`orders`.`shipping_method_id` AS `shipping_method_id`,`orders`.`payment_ref_id` AS `payment_ref_id`,`orders`.`payment_id` AS `payment_id`,`orders`.`payment_token` AS `payment_token`,`orders`.`payment_url` AS `payment_url`,`orders`.`payment_notif_token` AS `payment_notif_token`,`orders`.`payment_status` AS `payment_status`,`orders`.`payment_txn_id` AS `payment_txn_id`,`orders`.`lastid` AS `lastid`,`orders`.`payment_fees` AS `payment_fees`,`orders`.`delivery_fees` AS `delivery_fees`,`orders`.`orderType` AS `orderType`,`orders`.`transaction_code` AS `transaction_code`,`orders`.`tracking_number` AS `tracking_number`,`orders`.`promo_code` AS `promo_code`,`orders`.`courier_name` AS `courier_name`,`orders`.`identityPhoto` AS `identityPhoto`,`orders`.`newPhoneNumber` AS `newPhoneNumber`,`orders`.`selected_boutique` AS `selected_boutique`,`orders`.`rdv_boutique` AS `rdv_boutique`,`orders`.`rdv_date` AS `rdv_date`,`orders`.`delivery_type` AS `delivery_type`,`orders`.`site_id` AS `site_id`,`orders`.`country` AS `country`,`orders`.`newsletter` AS `newsletter`,`orders`.`comments` AS `comments`,`orders`.`extra_field_1` AS `extra_field_1`,`orders`.`extra_field_2` AS `extra_field_2`,`orders`.`extra_field_3` AS `extra_field_3`,`orders`.`extra_field_4` AS `extra_field_4`,`orders`.`extra_field_5` AS `extra_field_5` from `orders` */;
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-05 20:22:06
