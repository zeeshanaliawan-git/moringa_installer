-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_pages
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
-- Table structure for table `batch_export`
--

DROP TABLE IF EXISTS `batch_export`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_export` (
  `batch_id` varchar(255) NOT NULL DEFAULT uuid(),
  `target_ids` text DEFAULT NULL,
  `lang_ids` varchar(255) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `export_type` varchar(255) DEFAULT NULL,
  `excel_export` tinyint(1) DEFAULT 0,
  `process` enum('waiting','processing','exported','export_error') DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `error_msg` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`batch_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_export`
--

LOCK TABLES `batch_export` WRITE;
/*!40000 ALTER TABLE `batch_export` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch_export` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch_imports`
--

DROP TABLE IF EXISTS `batch_imports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(100) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `site_id` varchar(100) DEFAULT NULL,
  `status` enum('waiting','processing','loaded','importing','imported','import error','ignored','load error') DEFAULT 'waiting',
  `info` text DEFAULT NULL,
  `message` text DEFAULT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) DEFAULT NULL,
  `updated_items` text DEFAULT NULL,
  `skipped_items` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_imports`
--

LOCK TABLES `batch_imports` WRITE;
/*!40000 ALTER TABLE `batch_imports` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch_imports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch_imports_items`
--

DROP TABLE IF EXISTS `batch_imports_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_imports_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_table_id` varchar(36) NOT NULL,
  `site_id` varchar(100) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `item_id` varchar(100) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `error` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  `process` enum('validated','import','importing','imported','import error','ignored','load error') DEFAULT 'validated',
  `item_data` mediumtext DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `batch_table_id` (`batch_table_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_imports_items`
--

LOCK TABLES `batch_imports_items` WRITE;
/*!40000 ALTER TABLE `batch_imports_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch_imports_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_field_selected_templates`
--

DROP TABLE IF EXISTS `bloc_field_selected_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_field_selected_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `selected_template_id` int(11) NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_templates` (`template_id`,`selected_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_field_selected_templates`
--

LOCK TABLES `bloc_field_selected_templates` WRITE;
/*!40000 ALTER TABLE `bloc_field_selected_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_field_selected_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_template_description`
--

DROP TABLE IF EXISTS `bloc_template_description`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_template_description` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bloc_template_id` int(11) NOT NULL,
  `lang_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image_info` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_template_description`
--

LOCK TABLES `bloc_template_description` WRITE;
/*!40000 ALTER TABLE `bloc_template_description` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_template_description` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `bloc_templates`
--

DROP TABLE IF EXISTS `bloc_templates`;
/*!50001 DROP VIEW IF EXISTS `bloc_templates`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `bloc_templates` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `custom_id` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `template_code` tinyint NOT NULL,
  `css_code` tinyint NOT NULL,
  `js_code` tinyint NOT NULL,
  `jsonld_code` tinyint NOT NULL,
  `theme_id` tinyint NOT NULL,
  `theme_version` tinyint NOT NULL,
  `is_system` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bloc_templates_libraries`
--

DROP TABLE IF EXISTS `bloc_templates_libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_templates_libraries` (
  `bloc_template_id` int(11) unsigned NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `library_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_lib_id` (`library_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_templates_libraries`
--

LOCK TABLES `bloc_templates_libraries` WRITE;
/*!40000 ALTER TABLE `bloc_templates_libraries` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_templates_libraries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_templates_sections`
--

DROP TABLE IF EXISTS `bloc_templates_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_templates_sections` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bloc_template_id` int(11) unsigned NOT NULL,
  `parent_section_id` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(100) NOT NULL,
  `custom_id` varchar(100) NOT NULL,
  `sort_order` int(11) unsigned NOT NULL DEFAULT 0,
  `nb_items` int(11) unsigned NOT NULL DEFAULT 1 COMMENT '0 = unlimited',
  `is_system` tinyint(1) DEFAULT 0,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_collapse` tinyint(1) NOT NULL DEFAULT 1,
  `description` text DEFAULT NULL,
  `is_new_product_item` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_tempalte_id` (`bloc_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_templates_sections`
--

LOCK TABLES `bloc_templates_sections` WRITE;
/*!40000 ALTER TABLE `bloc_templates_sections` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_templates_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_templates_tbl`
--

DROP TABLE IF EXISTS `bloc_templates_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_templates_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `custom_id` varchar(100) NOT NULL,
  `type` enum('block','feed_view','structured_content','structured_page','store','menu','simple_product','simple_virtual_product','configurable_product','configurable_virtual_product') DEFAULT NULL,
  `description` varchar(500) NOT NULL DEFAULT '',
  `template_code` mediumtext NOT NULL,
  `css_code` mediumtext NOT NULL,
  `js_code` mediumtext NOT NULL,
  `jsonld_code` mediumtext NOT NULL,
  `theme_id` int(11) unsigned NOT NULL DEFAULT 0,
  `theme_version` varchar(10) NOT NULL DEFAULT '0',
  `is_system` tinyint(1) DEFAULT 0,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_blocs_name` (`is_deleted`,`site_id`,`custom_id`),
  FULLTEXT KEY `template_code_full_text` (`template_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_templates_tbl`
--

LOCK TABLES `bloc_templates_tbl` WRITE;
/*!40000 ALTER TABLE `bloc_templates_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_templates_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloc_tree`
--

DROP TABLE IF EXISTS `bloc_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bloc_tree` (
  `parent_bloc_id` int(11) NOT NULL,
  `bloc_id` int(11) NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  PRIMARY KEY (`parent_bloc_id`,`bloc_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloc_tree`
--

LOCK TABLES `bloc_tree` WRITE;
/*!40000 ALTER TABLE `bloc_tree` DISABLE KEYS */;
/*!40000 ALTER TABLE `bloc_tree` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocs`
--

DROP TABLE IF EXISTS `blocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `template_id` int(11) unsigned NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `refresh_interval` int(11) NOT NULL DEFAULT 0 COMMENT 'interval in minutes, 0 = never',
  `start_date` varchar(20) NOT NULL DEFAULT '',
  `end_date` varchar(20) NOT NULL DEFAULT '',
  `visible_to` enum('all','anonymous','logged') NOT NULL DEFAULT 'all',
  `margin_top` int(11) NOT NULL DEFAULT 0 COMMENT 'margin in px',
  `margin_bottom` int(11) NOT NULL DEFAULT 0 COMMENT 'margin in px',
  `description` varchar(500) NOT NULL DEFAULT '',
  `template_data_old` mediumtext NOT NULL DEFAULT '',
  `rss_feed_ids` varchar(1000) NOT NULL DEFAULT '',
  `rss_feed_sort` varchar(1000) NOT NULL DEFAULT '',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `unique_id` varchar(250) DEFAULT NULL,
  `triggers` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bloc_siteid_uuid` (`site_id`,`uuid`),
  FULLTEXT KEY `bloc_data_full_text` (`template_data_old`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocs`
--

LOCK TABLES `blocs` WRITE;
/*!40000 ALTER TABLE `blocs` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocs_details`
--

DROP TABLE IF EXISTS `blocs_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocs_details` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bloc_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `template_data` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bloc_lang` (`bloc_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocs_details`
--

LOCK TABLES `blocs_details` WRITE;
/*!40000 ALTER TABLE `blocs_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocs_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocs_tags`
--

DROP TABLE IF EXISTS `blocs_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocs_tags` (
  `bloc_id` int(11) unsigned NOT NULL,
  `tag_id` varchar(100) NOT NULL,
  PRIMARY KEY (`bloc_id`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocs_tags`
--

LOCK TABLES `blocs_tags` WRITE;
/*!40000 ALTER TABLE `blocs_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `blocs_tags` ENABLE KEYS */;
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
-- Table structure for table `component_dependencies`
--

DROP TABLE IF EXISTS `component_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `component_dependencies` (
  `dependant_component_id` int(11) unsigned NOT NULL,
  `main_component_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`dependant_component_id`,`main_component_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_dependencies`
--

LOCK TABLES `component_dependencies` WRITE;
/*!40000 ALTER TABLE `component_dependencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `component_dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component_libraries`
--

DROP TABLE IF EXISTS `component_libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `component_libraries` (
  `component_id` int(11) unsigned NOT NULL,
  `library_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`component_id`,`library_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_libraries`
--

LOCK TABLES `component_libraries` WRITE;
/*!40000 ALTER TABLE `component_libraries` DISABLE KEYS */;
/*!40000 ALTER TABLE `component_libraries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component_packages`
--

DROP TABLE IF EXISTS `component_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `component_packages` (
  `component_id` int(11) unsigned NOT NULL,
  `package_name` varchar(100) NOT NULL,
  PRIMARY KEY (`component_id`,`package_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_packages`
--

LOCK TABLES `component_packages` WRITE;
/*!40000 ALTER TABLE `component_packages` DISABLE KEYS */;
/*!40000 ALTER TABLE `component_packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component_properties`
--

DROP TABLE IF EXISTS `component_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `component_properties` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `component_id` int(11) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('json','string','number','boolean','image') NOT NULL,
  `is_required` tinyint(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_comp_property_name` (`component_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_properties`
--

LOCK TABLES `component_properties` WRITE;
/*!40000 ALTER TABLE `component_properties` DISABLE KEYS */;
/*!40000 ALTER TABLE `component_properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components`
--

DROP TABLE IF EXISTS `components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `components` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `file_path` varchar(500) NOT NULL,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `thumbnail_status` enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
  `thumbnail_file_name` varchar(100) NOT NULL DEFAULT '',
  `thumbnail_log` mediumtext NOT NULL,
  `html` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components`
--

LOCK TABLES `components` WRITE;
/*!40000 ALTER TABLE `components` DISABLE KEYS */;
/*!40000 ALTER TABLE `components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) NOT NULL DEFAULT '',
  `val` varchar(255) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('allow_domains_load_menu','',NULL),('BASE_DIR','/home/asimina/tomcat/webapps/asimina_pages/',NULL),('CATALOG_DB','cleandb_catalog',NULL),('CATALOG_ROOT','/asimina_catalog',NULL),('COMMONS_DB','cleandb_commons',NULL),('CUSTOM_ERROR_PAGE','/home/asimina/.nginx_asimina/',NULL),('DYNAMIC_PAGES_COMPILER_DIRECTORY','/home/asimina/pjt/asimina_engines/pages/compiler/','used by dynamic pages download function'),('EXPORT_LIMIT','50',NULL),('EXTERNAL_LINK','/asimina_pages/',NULL),('GESTION_URL','/asimina_catalog/admin/gotopages.jsp',NULL),('HTTP_CONNECTION_TIMEOUT','10000','used to URL connection to connect to external APIs'),('IMPORT_SEMAPHORE','D010',NULL),('MAX_FILE_UPLOAD_SIZE','2097152','size in bytes, must be numeric only'),('MAX_FILE_UPLOAD_SIZE_OTHER','26214400','size in bytes, must be numeric only, used for [other] file type '),('MAX_FILE_UPLOAD_SIZE_VIDEO','52428800','size in bytes, must be numeric only, used for [video] file type '),('MENU_IMAGES_FOLDER','/home/asimina/tomcat/webapps/asimina_pages/menu_resources/uploads/',NULL),('MENU_IMAGES_PATH','/menu_resources/uploads/',NULL),('PAGES_PUBLISH_FOLDER','pages/',NULL),('PAGES_SAVE_FOLDER','admin/pages/',NULL),('PARTOO_SEMAPHORE','D011',NULL),('PORTAL_DB','cleandb_portal',NULL),('PROD_EXTERNAL_LINK','/asimina_pages/',NULL),('SEMAPHORE','D004',NULL),('SEND_REDIRECT_LINK','/asimina_pages/sites/',NULL),('THEMES_FOLDER','themes/',NULL),('UPLOADS_FOLDER','uploads/',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `files`
--

DROP TABLE IF EXISTS `files`;
/*!50001 DROP VIEW IF EXISTS `files`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `files` (
  `id` tinyint NOT NULL,
  `file_name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `label` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `file_size` tinyint NOT NULL,
  `images_generated` tinyint NOT NULL,
  `theme_id` tinyint NOT NULL,
  `theme_version` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `times_used` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `alt_name` tinyint NOT NULL,
  `removal_date` tinyint NOT NULL,
  `thumbnail` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `files_tbl`
--

DROP TABLE IF EXISTS `files_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned DEFAULT 0,
  `label` varchar(300) NOT NULL DEFAULT '',
  `type` enum('img','css','js','fonts','other','video') NOT NULL,
  `file_size` decimal(20,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'file size in kB (kilo bytes)',
  `images_generated` tinyint(1) DEFAULT 0 COMMENT 'i.e. thumbnail, 4x3, og ',
  `theme_id` int(11) unsigned NOT NULL DEFAULT 0,
  `theme_version` varchar(10) NOT NULL DEFAULT '0',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `times_used` int(11) NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  `alt_name` varchar(300) DEFAULT NULL,
  `removal_date` date DEFAULT NULL,
  `thumbnail` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_files_name_type` (`is_deleted`,`site_id`,`file_name`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files_tbl`
--

LOCK TABLES `files_tbl` WRITE;
/*!40000 ALTER TABLE `files_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `files_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!50001 DROP VIEW IF EXISTS `folders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `folders` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `parent_folder_id` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `dl_page_type` tinyint NOT NULL,
  `dl_sub_level_1` tinyint NOT NULL,
  `dl_sub_level_2` tinyint NOT NULL,
  `folder_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `folders_details`
--

DROP TABLE IF EXISTS `folders_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders_details` (
  `folder_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `path_prefix` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`folder_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders_details`
--

LOCK TABLES `folders_details` WRITE;
/*!40000 ALTER TABLE `folders_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `folders_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folders_tbl`
--

DROP TABLE IF EXISTS `folders_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `parent_folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `folder_level` enum('1','2','3','4') NOT NULL DEFAULT '1',
  `type` enum('pages','contents','stores') NOT NULL DEFAULT 'pages',
  `created_ts` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_ts` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) NOT NULL DEFAULT 0,
  `dl_page_type` varchar(200) NOT NULL DEFAULT '',
  `dl_sub_level_1` varchar(200) NOT NULL DEFAULT '',
  `dl_sub_level_2` varchar(200) NOT NULL DEFAULT '',
  `folder_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_folders` (`is_deleted`,`site_id`,`type`,`parent_folder_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders_tbl`
--

LOCK TABLES `folders_tbl` WRITE;
/*!40000 ALTER TABLE `folders_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `folders_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `freemarker_pages`
--

DROP TABLE IF EXISTS `freemarker_pages`;
/*!50001 DROP VIEW IF EXISTS `freemarker_pages`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `freemarker_pages` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `published_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `published_by` tinyint NOT NULL,
  `to_generate` tinyint NOT NULL,
  `to_generate_by` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `to_publish_by` tinyint NOT NULL,
  `to_publish_ts` tinyint NOT NULL,
  `to_unpublish` tinyint NOT NULL,
  `to_unpublish_by` tinyint NOT NULL,
  `to_unpublish_ts` tinyint NOT NULL,
  `publish_status` tinyint NOT NULL,
  `publish_log` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `upd_on_by_webmaster` tinyint NOT NULL,
  `crt_by_webmaster` tinyint NOT NULL,
  `upd_by_webmaster` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `freemarker_pages_tbl`
--

DROP TABLE IF EXISTS `freemarker_pages_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `freemarker_pages_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
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
  `publish_log` mediumtext NOT NULL DEFAULT '',
  `deleted_by` int(11) NOT NULL DEFAULT 0,
  `upd_on_by_webmaster` datetime DEFAULT NULL,
  `crt_by_webmaster` varchar(500) DEFAULT NULL,
  `upd_by_webmaster` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_freemarker_name` (`is_deleted`,`site_id`,`folder_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freemarker_pages_tbl`
--

LOCK TABLES `freemarker_pages_tbl` WRITE;
/*!40000 ALTER TABLE `freemarker_pages_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `freemarker_pages_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ignore_xss_fields`
--

DROP TABLE IF EXISTS `ignore_xss_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ignore_xss_fields` (
  `url` varchar(200) NOT NULL,
  `field` varchar(100) NOT NULL,
  PRIMARY KEY (`url`,`field`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ignore_xss_fields`
--

LOCK TABLES `ignore_xss_fields` WRITE;
/*!40000 ALTER TABLE `ignore_xss_fields` DISABLE KEYS */;
INSERT INTO `ignore_xss_fields` VALUES ('blocsAjax.jsp','detailsJson'),('blocsAjax.jsp','template_data'),('blocTemplatesAjax.jsp','css_code'),('blocTemplatesAjax.jsp','data'),('blocTemplatesAjax.jsp','jsonld_code'),('blocTemplatesAjax.jsp','js_code'),('blocTemplatesAjax.jsp','template_code'),('importAjax.jsp','itemsJson'),('pagesAjax.jsp','layoutData'),('pageTemplatesAjax.jsp','data'),('structuredContentsAjax.jsp','contentDetailData_1'),('structuredContentsAjax.jsp','contentDetailData_2'),('structuredContentsAjax.jsp','contentDetailData_3'),('structuredContentsAjax.jsp','contentDetailData_4'),('structuredContentsAjax.jsp','contentDetailData_5');
/*!40000 ALTER TABLE `ignore_xss_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `file_name` varchar(300) NOT NULL,
  `label` varchar(100) NOT NULL,
  `file_size` decimal(20,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'file size in kB (kilo bytes)',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  PRIMARY KEY (`file_name`),
  KEY `idx_image_label` (`label`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
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
-- Temporary table structure for view `libraries`
--

DROP TABLE IF EXISTS `libraries`;
/*!50001 DROP VIEW IF EXISTS `libraries`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `libraries` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `theme_id` tinyint NOT NULL,
  `theme_version` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `libraries_files`
--

DROP TABLE IF EXISTS `libraries_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libraries_files` (
  `library_id` int(11) unsigned NOT NULL,
  `file_id` int(11) unsigned NOT NULL,
  `page_position` enum('body','head') NOT NULL DEFAULT 'body',
  `sort_order` int(3) unsigned NOT NULL DEFAULT 0,
  `lang_id` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`library_id`,`file_id`,`lang_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries_files`
--

LOCK TABLES `libraries_files` WRITE;
/*!40000 ALTER TABLE `libraries_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `libraries_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libraries_tbl`
--

DROP TABLE IF EXISTS `libraries_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libraries_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `theme_id` int(11) unsigned NOT NULL DEFAULT 0,
  `theme_version` varchar(10) NOT NULL DEFAULT '0',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_library_name` (`is_deleted`,`site_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries_tbl`
--

LOCK TABLES `libraries_tbl` WRITE;
/*!40000 ALTER TABLE `libraries_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `libraries_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locked_items`
--

DROP TABLE IF EXISTS `locked_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locked_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `item_type` varchar(100) NOT NULL,
  `site_id` int(11) NOT NULL,
  `is_locked` tinyint(1) DEFAULT 0,
  `locked_by` int(11) DEFAULT 0,
  `created_ts` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_ts` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_locked` (`item_id`,`site_id`,`item_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locked_items`
--

LOCK TABLES `locked_items` WRITE;
/*!40000 ALTER TABLE `locked_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `locked_items` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `media_records`
--

DROP TABLE IF EXISTS `media_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `used_at` varchar(255) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_file_id` (`file_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_records`
--

LOCK TABLES `media_records` WRITE;
/*!40000 ALTER TABLE `media_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `media_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_tags`
--

DROP TABLE IF EXISTS `media_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) NOT NULL,
  `tag` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_tags`
--

LOCK TABLES `media_tags` WRITE;
/*!40000 ALTER TABLE `media_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `media_tags` ENABLE KEYS */;
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
-- Table structure for table `menu_js`
--

DROP TABLE IF EXISTS `menu_js`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_js` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `description` varchar(1000) NOT NULL DEFAULT '',
  `created_ts` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_ts` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `publish_status` enum('unpublished','published','error') NOT NULL DEFAULT 'unpublished',
  `published_by` int(11) NOT NULL,
  `published_ts` datetime NOT NULL DEFAULT current_timestamp(),
  `publish_log` mediumtext NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_js`
--

LOCK TABLES `menu_js` WRITE;
/*!40000 ALTER TABLE `menu_js` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_js` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_js_details`
--

DROP TABLE IF EXISTS `menu_js_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_js_details` (
  `menu_js_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `header_bloc_id` int(11) unsigned NOT NULL DEFAULT 0,
  `header_bloc_type` enum('bloc','menu') NOT NULL DEFAULT 'bloc',
  `footer_bloc_id` int(11) unsigned NOT NULL DEFAULT 0,
  `footer_bloc_type` enum('bloc','menu') NOT NULL DEFAULT 'bloc',
  `published_json` mediumtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`menu_js_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_js_details`
--

LOCK TABLES `menu_js_details` WRITE;
/*!40000 ALTER TABLE `menu_js_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu_js_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!50001 DROP VIEW IF EXISTS `menus`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `menus` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `template_id` tinyint NOT NULL,
  `langue_id` tinyint NOT NULL,
  `variant` tinyint NOT NULL,
  `template_data` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `published_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `published_by` tinyint NOT NULL,
  `to_generate` tinyint NOT NULL,
  `to_generate_by` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `to_publish_by` tinyint NOT NULL,
  `to_publish_ts` tinyint NOT NULL,
  `to_unpublish` tinyint NOT NULL,
  `to_unpublish_by` tinyint NOT NULL,
  `to_unpublish_ts` tinyint NOT NULL,
  `publish_status` tinyint NOT NULL,
  `publish_log` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

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
-- Table structure for table `page_component_urls`
--

DROP TABLE IF EXISTS `page_component_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_component_urls` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('component','item') NOT NULL,
  `component_id` int(11) unsigned NOT NULL,
  `page_item_id` int(11) unsigned NOT NULL,
  `url` varchar(2000) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_component_urls`
--

LOCK TABLES `page_component_urls` WRITE;
/*!40000 ALTER TABLE `page_component_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_component_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_item_property_values`
--

DROP TABLE IF EXISTS `page_item_property_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_item_property_values` (
  `page_item_id` int(11) unsigned NOT NULL,
  `property_id` int(11) unsigned NOT NULL,
  `value` varchar(4000) NOT NULL,
  PRIMARY KEY (`page_item_id`,`property_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_item_property_values`
--

LOCK TABLES `page_item_property_values` WRITE;
/*!40000 ALTER TABLE `page_item_property_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_item_property_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_items`
--

DROP TABLE IF EXISTS `page_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` int(11) unsigned NOT NULL,
  `index_key` smallint(5) unsigned NOT NULL,
  `component_id` int(11) unsigned NOT NULL,
  `x_cord` smallint(5) unsigned NOT NULL,
  `y_cord` smallint(5) unsigned NOT NULL,
  `width` smallint(5) unsigned NOT NULL,
  `height` smallint(5) unsigned NOT NULL,
  `css_classes` varchar(1000) NOT NULL DEFAULT '' COMMENT 'space seperated classes, for class attribute',
  `css_style` varchar(4000) NOT NULL DEFAULT '' COMMENT 'json object for style attribute',
  PRIMARY KEY (`id`),
  UNIQUE KEY `page_id` (`page_id`,`index_key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_items`
--

LOCK TABLES `page_items` WRITE;
/*!40000 ALTER TABLE `page_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_items` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Temporary table structure for view `page_templates`
--

DROP TABLE IF EXISTS `page_templates`;
/*!50001 DROP VIEW IF EXISTS `page_templates`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `page_templates` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `custom_id` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `template_code` tinyint NOT NULL,
  `is_system` tinyint NOT NULL,
  `theme_id` tinyint NOT NULL,
  `theme_version` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `page_templates_items`
--

DROP TABLE IF EXISTS `page_templates_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_templates_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `page_template_id` int(11) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `custom_id` varchar(100) NOT NULL,
  `sort_order` int(2) unsigned NOT NULL DEFAULT 0,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pti` (`page_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_templates_items`
--

LOCK TABLES `page_templates_items` WRITE;
/*!40000 ALTER TABLE `page_templates_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_templates_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_templates_items_blocs`
--

DROP TABLE IF EXISTS `page_templates_items_blocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_templates_items_blocs` (
  `item_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `bloc_id` int(11) unsigned NOT NULL,
  `type` enum('bloc','menu') NOT NULL DEFAULT 'bloc',
  `sort_order` int(2) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`item_id`,`langue_id`,`bloc_id`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_templates_items_blocs`
--

LOCK TABLES `page_templates_items_blocs` WRITE;
/*!40000 ALTER TABLE `page_templates_items_blocs` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_templates_items_blocs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_templates_items_details`
--

DROP TABLE IF EXISTS `page_templates_items_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_templates_items_details` (
  `item_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `css_classes` varchar(500) NOT NULL DEFAULT '',
  `css_style` varchar(1000) NOT NULL DEFAULT '',
  PRIMARY KEY (`item_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_templates_items_details`
--

LOCK TABLES `page_templates_items_details` WRITE;
/*!40000 ALTER TABLE `page_templates_items_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_templates_items_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_templates_tbl`
--

DROP TABLE IF EXISTS `page_templates_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_templates_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `custom_id` varchar(100) NOT NULL,
  `description` varchar(500) NOT NULL DEFAULT '',
  `template_code` mediumtext NOT NULL,
  `is_system` tinyint(1) DEFAULT 0 COMMENT '1 = system entity not to delete , selective edit',
  `theme_id` int(11) unsigned NOT NULL DEFAULT 0,
  `theme_version` varchar(10) NOT NULL DEFAULT '0',
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_page_template_uuid` (`uuid`),
  UNIQUE KEY `uk_page_template_custom_id` (`is_deleted`,`site_id`,`custom_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_templates_tbl`
--

LOCK TABLES `page_templates_tbl` WRITE;
/*!40000 ALTER TABLE `page_templates_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_templates_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!50001 DROP VIEW IF EXISTS `pages`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pages` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `path` tinyint NOT NULL,
  `langue_code` tinyint NOT NULL,
  `variant` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `html_file_path` tinyint NOT NULL,
  `published_html_file_path` tinyint NOT NULL,
  `canonical_url` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `meta_keywords` tinyint NOT NULL,
  `meta_description` tinyint NOT NULL,
  `template_id` tinyint NOT NULL,
  `dl_page_type` tinyint NOT NULL,
  `dl_sub_level_1` tinyint NOT NULL,
  `dl_sub_level_2` tinyint NOT NULL,
  `package_name` tinyint NOT NULL,
  `class_name` tinyint NOT NULL,
  `layout` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `published_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `published_by` tinyint NOT NULL,
  `social_title` tinyint NOT NULL,
  `social_type` tinyint NOT NULL,
  `social_description` tinyint NOT NULL,
  `social_image` tinyint NOT NULL,
  `social_twitter_message` tinyint NOT NULL,
  `social_twitter_hashtags` tinyint NOT NULL,
  `social_email_subject` tinyint NOT NULL,
  `social_email_popin_title` tinyint NOT NULL,
  `social_email_message` tinyint NOT NULL,
  `social_sms_text` tinyint NOT NULL,
  `to_generate` tinyint NOT NULL,
  `to_generate_by` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `to_publish_by` tinyint NOT NULL,
  `to_publish_ts` tinyint NOT NULL,
  `to_unpublish` tinyint NOT NULL,
  `to_unpublish_by` tinyint NOT NULL,
  `to_unpublish_ts` tinyint NOT NULL,
  `publish_status` tinyint NOT NULL,
  `publish_log` tinyint NOT NULL,
  `row_height` tinyint NOT NULL,
  `item_margin_x` tinyint NOT NULL,
  `item_margin_y` tinyint NOT NULL,
  `container_padding_x` tinyint NOT NULL,
  `container_padding_y` tinyint NOT NULL,
  `get_html_status` tinyint NOT NULL,
  `get_html_log` tinyint NOT NULL,
  `dynamic_html` tinyint NOT NULL,
  `layout_data` tinyint NOT NULL,
  `parent_page_id` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `attempt` tinyint NOT NULL,
  `page_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `pages_blocs`
--

DROP TABLE IF EXISTS `pages_blocs`;
/*!50001 DROP VIEW IF EXISTS `pages_blocs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pages_blocs` (
  `page_id` tinyint NOT NULL,
  `bloc_id` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `type` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `pages_folders`
--

DROP TABLE IF EXISTS `pages_folders`;
/*!50001 DROP VIEW IF EXISTS `pages_folders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pages_folders` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `parent_folder_id` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `dl_page_type` tinyint NOT NULL,
  `dl_sub_level_1` tinyint NOT NULL,
  `dl_sub_level_2` tinyint NOT NULL,
  `folder_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `pages_folders_lang_path`
--

DROP TABLE IF EXISTS `pages_folders_lang_path`;
/*!50001 DROP VIEW IF EXISTS `pages_folders_lang_path`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pages_folders_lang_path` (
  `site_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `langue_id` tinyint NOT NULL,
  `concat_path` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `path1` tinyint NOT NULL,
  `path2` tinyint NOT NULL,
  `path3` tinyint NOT NULL,
  `path4` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `pages_forms`
--

DROP TABLE IF EXISTS `pages_forms`;
/*!50001 DROP VIEW IF EXISTS `pages_forms`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `pages_forms` (
  `page_id` tinyint NOT NULL,
  `form_id` tinyint NOT NULL,
  `sort_order` tinyint NOT NULL,
  `type` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `pages_meta_tags`
--

DROP TABLE IF EXISTS `pages_meta_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages_meta_tags` (
  `page_id` int(11) unsigned NOT NULL,
  `meta_name` varchar(200) NOT NULL,
  `meta_content` mediumtext NOT NULL,
  PRIMARY KEY (`page_id`,`meta_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages_meta_tags`
--

LOCK TABLES `pages_meta_tags` WRITE;
/*!40000 ALTER TABLE `pages_meta_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `pages_meta_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages_tags`
--

DROP TABLE IF EXISTS `pages_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages_tags` (
  `page_id` int(11) unsigned NOT NULL COMMENT 'for freemarker and structured page this is parent page id whereas for react its id from table pages',
  `page_type` enum('freemarker','react','structured') NOT NULL DEFAULT 'freemarker',
  `tag_id` varchar(100) NOT NULL,
  PRIMARY KEY (`page_id`,`page_type`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages_tags`
--

LOCK TABLES `pages_tags` WRITE;
/*!40000 ALTER TABLE `pages_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `pages_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages_tbl`
--

DROP TABLE IF EXISTS `pages_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `type` enum('freemarker','react','structured') NOT NULL DEFAULT 'freemarker',
  `path` varchar(300) NOT NULL,
  `langue_code` varchar(2) NOT NULL DEFAULT 'en',
  `variant` enum('all','logged','anonymous') NOT NULL,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `html_file_path` varchar(1000) NOT NULL DEFAULT '' COMMENT 'relative path of the page html file ',
  `published_html_file_path` varchar(1000) NOT NULL DEFAULT '',
  `canonical_url` varchar(500) NOT NULL,
  `title` varchar(500) NOT NULL,
  `meta_keywords` varchar(500) NOT NULL DEFAULT '',
  `meta_description` varchar(500) NOT NULL DEFAULT '',
  `template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `dl_page_type` varchar(200) NOT NULL DEFAULT '',
  `dl_sub_level_1` varchar(200) NOT NULL DEFAULT '',
  `dl_sub_level_2` varchar(200) NOT NULL DEFAULT '',
  `package_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'for react pages',
  `class_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'for react pages',
  `layout` enum('react-grid-layout','css-grid') NOT NULL DEFAULT 'react-grid-layout',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `published_ts` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `published_by` int(11) DEFAULT NULL,
  `social_title` varchar(500) NOT NULL,
  `social_type` varchar(100) NOT NULL DEFAULT 'website',
  `social_description` varchar(500) NOT NULL DEFAULT '',
  `social_image` varchar(500) NOT NULL DEFAULT '',
  `social_twitter_message` varchar(500) NOT NULL DEFAULT '',
  `social_twitter_hashtags` varchar(500) NOT NULL DEFAULT '',
  `social_email_subject` varchar(100) NOT NULL DEFAULT '',
  `social_email_popin_title` varchar(100) NOT NULL DEFAULT '',
  `social_email_message` varchar(1000) NOT NULL DEFAULT '',
  `social_sms_text` varchar(500) NOT NULL DEFAULT '',
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
  `row_height` int(11) DEFAULT 100 COMMENT 'in px',
  `item_margin_x` int(11) DEFAULT 10 COMMENT 'x margin between items in px',
  `item_margin_y` int(11) DEFAULT 10 COMMENT 'y margin between items in px',
  `container_padding_x` int(11) DEFAULT 10 COMMENT 'x padding inside the item container in px',
  `container_padding_y` int(11) DEFAULT 10 COMMENT 'y padding inside the item container in px',
  `get_html_status` enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
  `get_html_log` mediumtext NOT NULL DEFAULT '',
  `dynamic_html` mediumtext NOT NULL,
  `layout_data` mediumtext NOT NULL,
  `parent_page_id` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) NOT NULL DEFAULT 0,
  `attempt` int(11) DEFAULT 0,
  `page_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pages_path_variant_lang_folder` (`is_deleted`,`site_id`,`path`,`variant`,`langue_code`,`folder_id`),
  KEY `idxPpId` (`parent_page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages_tbl`
--

LOCK TABLES `pages_tbl` WRITE;
/*!40000 ALTER TABLE `pages_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `pages_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages_urls`
--

DROP TABLE IF EXISTS `pages_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages_urls` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `page_id` int(11) unsigned NOT NULL,
  `type` enum('init') DEFAULT NULL,
  `js_key` varchar(100) NOT NULL,
  `url` varchar(2500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages_urls`
--

LOCK TABLES `pages_urls` WRITE;
/*!40000 ALTER TABLE `pages_urls` DISABLE KEYS */;
/*!40000 ALTER TABLE `pages_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parent_pages_blocs`
--

DROP TABLE IF EXISTS `parent_pages_blocs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parent_pages_blocs` (
  `page_id` int(11) unsigned NOT NULL,
  `bloc_id` int(11) unsigned NOT NULL,
  `type` enum('freemarker','structured') NOT NULL DEFAULT 'freemarker',
  `sort_order` int(2) unsigned NOT NULL,
  PRIMARY KEY (`page_id`,`bloc_id`,`sort_order`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parent_pages_blocs`
--

LOCK TABLES `parent_pages_blocs` WRITE;
/*!40000 ALTER TABLE `parent_pages_blocs` DISABLE KEYS */;
/*!40000 ALTER TABLE `parent_pages_blocs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parent_pages_forms`
--

DROP TABLE IF EXISTS `parent_pages_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parent_pages_forms` (
  `page_id` int(11) unsigned NOT NULL,
  `type` enum('freemarker','structured') NOT NULL DEFAULT 'freemarker',
  `form_id` varchar(36) NOT NULL,
  `sort_order` int(2) unsigned NOT NULL,
  PRIMARY KEY (`page_id`,`form_id`,`sort_order`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parent_pages_forms`
--

LOCK TABLES `parent_pages_forms` WRITE;
/*!40000 ALTER TABLE `parent_pages_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `parent_pages_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_contents`
--

DROP TABLE IF EXISTS `partoo_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_contents` (
  `cid` int(11) unsigned NOT NULL,
  `ctype` enum('store','folder','section') NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  `partoo_id` varchar(255) DEFAULT NULL,
  `partoo_error` mediumtext DEFAULT NULL,
  `rjson` mediumtext DEFAULT NULL,
  `partoo_json` mediumtext DEFAULT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`cid`,`ctype`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_contents`
--

LOCK TABLES `partoo_contents` WRITE;
/*!40000 ALTER TABLE `partoo_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_publish`
--

DROP TABLE IF EXISTS `partoo_publish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_publish` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cid` int(11) unsigned NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  `ctype` enum('store','folder') NOT NULL DEFAULT 'store',
  `status` int(1) NOT NULL DEFAULT 0,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `attempt` int(5) NOT NULL DEFAULT 0,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_publish`
--

LOCK TABLES `partoo_publish` WRITE;
/*!40000 ALTER TABLE `partoo_publish` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_publish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_services`
--

DROP TABLE IF EXISTS `partoo_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(100) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `price` double DEFAULT NULL,
  `description` varchar(320) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `to_delete` tinyint(1) DEFAULT 0,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_idx` (`category`,`service_name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_services`
--

LOCK TABLES `partoo_services` WRITE;
/*!40000 ALTER TABLE `partoo_services` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_services_deleted`
--

DROP TABLE IF EXISTS `partoo_services_deleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_services_deleted` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(100) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `price` double DEFAULT NULL,
  `description` varchar(320) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_services_deleted`
--

LOCK TABLES `partoo_services_deleted` WRITE;
/*!40000 ALTER TABLE `partoo_services_deleted` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_services_deleted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_services_details`
--

DROP TABLE IF EXISTS `partoo_services_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_services_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `partoo_work_id` int(11) DEFAULT NULL,
  `partoo_id` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `service_name` varchar(100) DEFAULT NULL,
  `service_id` int(11) NOT NULL,
  `service` text DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_idx` (`partoo_id`,`service_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_services_details`
--

LOCK TABLES `partoo_services_details` WRITE;
/*!40000 ALTER TABLE `partoo_services_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_services_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_services_details_deleted`
--

DROP TABLE IF EXISTS `partoo_services_details_deleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_services_details_deleted` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `partoo_work_id` int(11) DEFAULT NULL,
  `partoo_id` varchar(50) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `service_name` varchar(100) DEFAULT NULL,
  `service_id` int(11) NOT NULL,
  `service` text DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_services_details_deleted`
--

LOCK TABLES `partoo_services_details_deleted` WRITE;
/*!40000 ALTER TABLE `partoo_services_details_deleted` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_services_details_deleted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partoo_services_work`
--

DROP TABLE IF EXISTS `partoo_services_work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partoo_services_work` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `services_id` int(11) DEFAULT NULL,
  `partoo_id` varchar(50) DEFAULT NULL,
  `method` enum('post','delete') DEFAULT NULL,
  `request_json` text DEFAULT NULL,
  `status` enum('pending','error','success') DEFAULT 'pending',
  `error_msg` text DEFAULT NULL,
  `attempt` int(11) DEFAULT 0,
  `site_id` int(11) NOT NULL,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx1` (`services_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partoo_services_work`
--

LOCK TABLES `partoo_services_work` WRITE;
/*!40000 ALTER TABLE `partoo_services_work` DISABLE KEYS */;
/*!40000 ALTER TABLE `partoo_services_work` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `products_map_pages`
--

DROP TABLE IF EXISTS `products_map_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_map_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` varchar(100) DEFAULT NULL,
  `page_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ref_product_page` (`product_id`,`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_map_pages`
--

LOCK TABLES `products_map_pages` WRITE;
/*!40000 ALTER TABLE `products_map_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_map_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_view_bloc_criteria`
--

DROP TABLE IF EXISTS `products_view_bloc_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_view_bloc_criteria` (
  `data_id` int(11) NOT NULL,
  `cid` varchar(50) NOT NULL,
  PRIMARY KEY (`data_id`,`cid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_view_bloc_criteria`
--

LOCK TABLES `products_view_bloc_criteria` WRITE;
/*!40000 ALTER TABLE `products_view_bloc_criteria` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_view_bloc_criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_view_bloc_data`
--

DROP TABLE IF EXISTS `products_view_bloc_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_view_bloc_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `page_id` int(11) NOT NULL,
  `bloc_id` int(11) NOT NULL,
  `langue_code` varchar(5) NOT NULL,
  `for_prod_site` tinyint(1) NOT NULL DEFAULT 0,
  `view_query` mediumtext NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_ts` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`,`page_id`,`bloc_id`,`langue_code`,`for_prod_site`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_view_bloc_data`
--

LOCK TABLES `products_view_bloc_data` WRITE;
/*!40000 ALTER TABLE `products_view_bloc_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_view_bloc_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_view_bloc_results`
--

DROP TABLE IF EXISTS `products_view_bloc_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_view_bloc_results` (
  `data_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  PRIMARY KEY (`data_id`,`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_view_bloc_results`
--

LOCK TABLES `products_view_bloc_results` WRITE;
/*!40000 ALTER TABLE `products_view_bloc_results` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_view_bloc_results` ENABLE KEYS */;
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
-- Table structure for table `published_pages_applied_files`
--

DROP TABLE IF EXISTS `published_pages_applied_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `published_pages_applied_files` (
  `page_id` int(11) NOT NULL,
  `bloc_template_id` int(11) DEFAULT NULL,
  `bloc_templates_lib_id` int(11) DEFAULT NULL,
  `library_id` int(11) DEFAULT NULL,
  `file_id` int(11) NOT NULL,
  `file_name` varchar(500) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_update_ts` varchar(75) DEFAULT NULL,
  `library_name` varchar(500) DEFAULT NULL,
  `page_position` varchar(25) DEFAULT NULL,
  `sort_order` int(10) DEFAULT NULL,
  `applicable_sort_order` int(10) DEFAULT NULL,
  KEY `idx1` (`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `published_pages_applied_files`
--

LOCK TABLES `published_pages_applied_files` WRITE;
/*!40000 ALTER TABLE `published_pages_applied_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `published_pages_applied_files` ENABLE KEYS */;
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
-- Table structure for table `rss_feeds`
--

DROP TABLE IF EXISTS `rss_feeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feeds` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `url` varchar(1500) NOT NULL,
  `max_items` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '0 = All',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `activation_type` enum('auto','update','never') NOT NULL DEFAULT 'auto',
  `sync_frequency` int(10) unsigned NOT NULL DEFAULT 1,
  `sync_frequency_unit` enum('minute','hour','day') NOT NULL DEFAULT 'minute',
  `sync_type` enum('delete','update','duplicate') NOT NULL DEFAULT 'delete',
  `last_sync_ts` datetime NOT NULL,
  `ch_title` varchar(1000) NOT NULL DEFAULT '',
  `ch_link` varchar(1500) NOT NULL DEFAULT '',
  `ch_description` varchar(1000) NOT NULL DEFAULT '',
  `ch_language` varchar(100) NOT NULL DEFAULT '',
  `ch_copyright` varchar(1000) NOT NULL DEFAULT '',
  `ch_category` varchar(100) NOT NULL DEFAULT '',
  `ch_ttl` varchar(100) NOT NULL DEFAULT '',
  `ch_pubDate` varchar(100) NOT NULL DEFAULT '',
  `ch_image_url` varchar(2000) NOT NULL DEFAULT '',
  `ch_image_title` varchar(100) NOT NULL DEFAULT '',
  `ch_extra_params` mediumtext NOT NULL COMMENT 'extra param-values stored as JSON',
  `is_error` tinyint(1) NOT NULL DEFAULT 0,
  `error_text` mediumtext NOT NULL,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rss_feeds`
--

LOCK TABLES `rss_feeds` WRITE;
/*!40000 ALTER TABLE `rss_feeds` DISABLE KEYS */;
/*!40000 ALTER TABLE `rss_feeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rss_feeds_items`
--

DROP TABLE IF EXISTS `rss_feeds_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feeds_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rss_feed_id` int(11) unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `title` varchar(2000) NOT NULL DEFAULT '',
  `link` varchar(2000) NOT NULL DEFAULT '',
  `description` mediumtext NOT NULL,
  `guid` varchar(2000) NOT NULL DEFAULT '',
  `enclosure_url` varchar(2000) NOT NULL DEFAULT '',
  `enclosure_type` varchar(100) NOT NULL DEFAULT '',
  `enclosure_length` varchar(100) NOT NULL DEFAULT '',
  `pubDate` varchar(100) NOT NULL DEFAULT '',
  `pubDate_std` datetime NOT NULL DEFAULT '2000-01-01 00:00:00',
  `category` varchar(100) NOT NULL DEFAULT '',
  `author` varchar(100) NOT NULL DEFAULT '',
  `comments` varchar(100) NOT NULL DEFAULT '',
  `source` varchar(100) NOT NULL DEFAULT '',
  `source_url` varchar(2000) NOT NULL DEFAULT '',
  `extra_params` mediumtext DEFAULT NULL COMMENT 'extra param-values stored as JSON',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_rss_feed_id` (`rss_feed_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rss_feeds_items`
--

LOCK TABLES `rss_feeds_items` WRITE;
/*!40000 ALTER TABLE `rss_feeds_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `rss_feeds_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `section_field_advance`
--

DROP TABLE IF EXISTS `section_field_advance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `section_field_advance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `entity_type` enum('section','field') NOT NULL,
  `display` tinyint(1) NOT NULL DEFAULT 1,
  `unique_type` enum('none','custom','auto') NOT NULL DEFAULT 'none',
  `modifiable` enum('always','create','never') NOT NULL DEFAULT 'always',
  `reg_exp` varchar(100) DEFAULT NULL,
  `css_code` text DEFAULT NULL,
  `js_code` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `entity_id` (`entity_id`,`entity_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `section_field_advance`
--

LOCK TABLES `section_field_advance` WRITE;
/*!40000 ALTER TABLE `section_field_advance` DISABLE KEYS */;
/*!40000 ALTER TABLE `section_field_advance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections_fields`
--

DROP TABLE IF EXISTS `sections_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sections_fields` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `section_id` int(11) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `custom_id` varchar(100) NOT NULL,
  `sort_order` int(11) unsigned NOT NULL DEFAULT 0,
  `nb_items` int(11) unsigned NOT NULL DEFAULT 1 COMMENT '0 = unlimited',
  `type` varchar(50) NOT NULL,
  `value` mediumtext NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT 0,
  `is_system` tinyint(1) DEFAULT 0,
  `is_indexed` tinyint(1) NOT NULL DEFAULT 0,
  `is_meta_variable` tinyint(1) NOT NULL DEFAULT 0,
  `is_bulk_modify` tinyint(1) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  `select_type` enum('select','search') NOT NULL DEFAULT 'select',
  `is_query` tinyint(1) DEFAULT 0,
  `query_type` enum('free','catalog','content','page','data','blocs') DEFAULT NULL,
  `is_new_product_item` tinyint(1) DEFAULT 0,
  `field_specific_data` text NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`),
  KEY `idx1` (`section_id`,`custom_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections_fields`
--

LOCK TABLES `sections_fields` WRITE;
/*!40000 ALTER TABLE `sections_fields` DISABLE KEYS */;
/*!40000 ALTER TABLE `sections_fields` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections_fields_details`
--

DROP TABLE IF EXISTS `sections_fields_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sections_fields_details` (
  `field_id` int(11) unsigned NOT NULL,
  `langue_id` int(2) unsigned NOT NULL,
  `default_value` mediumtext NOT NULL,
  `placeholder` varchar(500) NOT NULL DEFAULT '',
  PRIMARY KEY (`field_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections_fields_details`
--

LOCK TABLES `sections_fields_details` WRITE;
/*!40000 ALTER TABLE `sections_fields_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `sections_fields_details` ENABLE KEYS */;
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
-- Temporary table structure for view `stores_folders`
--

DROP TABLE IF EXISTS `stores_folders`;
/*!50001 DROP VIEW IF EXISTS `stores_folders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stores_folders` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `parent_folder_id` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `dl_page_type` tinyint NOT NULL,
  `dl_sub_level_1` tinyint NOT NULL,
  `dl_sub_level_2` tinyint NOT NULL,
  `folder_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `structure_mappings`
--

DROP TABLE IF EXISTS `structure_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structure_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lang_page_id` int(11) NOT NULL,
  `bloc_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structure_mappings`
--

LOCK TABLES `structure_mappings` WRITE;
/*!40000 ALTER TABLE `structure_mappings` DISABLE KEYS */;
/*!40000 ALTER TABLE `structure_mappings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structured_catalogs`
--

DROP TABLE IF EXISTS `structured_catalogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_catalogs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `type` enum('content','page') NOT NULL DEFAULT 'content',
  `template_id` int(11) unsigned NOT NULL COMMENT 'catalog type',
  `publish_status` enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `published_ts` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `published_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_catalogs`
--

LOCK TABLES `structured_catalogs` WRITE;
/*!40000 ALTER TABLE `structured_catalogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_catalogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structured_catalogs_details`
--

DROP TABLE IF EXISTS `structured_catalogs_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_catalogs_details` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `path_prefix` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `catalog_lang` (`catalog_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_catalogs_details`
--

LOCK TABLES `structured_catalogs_details` WRITE;
/*!40000 ALTER TABLE `structured_catalogs_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_catalogs_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structured_catalogs_published`
--

DROP TABLE IF EXISTS `structured_catalogs_published`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_catalogs_published` (
  `id` int(11) unsigned NOT NULL,
  `uuid` varchar(36) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `type` enum('content','page') NOT NULL DEFAULT 'content',
  `template_id` int(11) unsigned NOT NULL COMMENT 'catalog type',
  `publish_status` enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `published_ts` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `published_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_catalogs_published`
--

LOCK TABLES `structured_catalogs_published` WRITE;
/*!40000 ALTER TABLE `structured_catalogs_published` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_catalogs_published` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `structured_contents`
--

DROP TABLE IF EXISTS `structured_contents`;
/*!50001 DROP VIEW IF EXISTS `structured_contents`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `structured_contents` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `catalog_id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `template_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `publish_status` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `published_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `published_by` tinyint NOT NULL,
  `to_generate` tinyint NOT NULL,
  `to_generate_by` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `to_publish_by` tinyint NOT NULL,
  `to_publish_ts` tinyint NOT NULL,
  `to_unpublish` tinyint NOT NULL,
  `to_unpublish_by` tinyint NOT NULL,
  `to_unpublish_ts` tinyint NOT NULL,
  `publish_log` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `unique_id` tinyint NOT NULL,
  `upd_on_by_webmaster` tinyint NOT NULL,
  `crt_by_webmaster` tinyint NOT NULL,
  `upd_by_webmaster` tinyint NOT NULL,
  `structured_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `structured_contents_details`
--

DROP TABLE IF EXISTS `structured_contents_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_contents_details` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `content_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `content_data` mediumtext NOT NULL,
  `page_id` int(11) unsigned NOT NULL DEFAULT 0,
  `fd_content_data` mediumtext GENERATED ALWAYS AS (replace(replace(replace(`content_data`,'#slash#/','/'),'#slash#"','"'),'#slash#','\\')) STORED,
  `fd_content_data_2` mediumtext GENERATED ALWAYS AS (replace(replace(replace(`content_data`,'#slash#/','/'),'#slash#"','"'),'#slash#','\\')) STORED,
  `fd_content_data_3` mediumtext GENERATED ALWAYS AS (replace(replace(replace(replace(replace(`content_data`,'#slash#/','/'),'#slash#n',''),'#slash#"','\''),'#slash#t',''),'#slash#','\\')) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_lang` (`content_id`,`langue_id`),
  KEY `idx2` (`page_id`),
  FULLTEXT KEY `struct_content_data_full_text` (`content_data`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_contents_details`
--

LOCK TABLES `structured_contents_details` WRITE;
/*!40000 ALTER TABLE `structured_contents_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_contents_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structured_contents_details_published`
--

DROP TABLE IF EXISTS `structured_contents_details_published`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_contents_details_published` (
  `id` int(11) unsigned NOT NULL,
  `content_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `content_data` mediumtext NOT NULL,
  `page_id` int(11) unsigned NOT NULL DEFAULT 0,
  `fd_content_data` mediumtext DEFAULT NULL,
  `fd_content_data_2` mediumtext DEFAULT NULL,
  `fd_content_data_3` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_lang` (`content_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_contents_details_published`
--

LOCK TABLES `structured_contents_details_published` WRITE;
/*!40000 ALTER TABLE `structured_contents_details_published` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_contents_details_published` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `structured_contents_folders`
--

DROP TABLE IF EXISTS `structured_contents_folders`;
/*!50001 DROP VIEW IF EXISTS `structured_contents_folders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `structured_contents_folders` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `parent_folder_id` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `deleted_by` tinyint NOT NULL,
  `dl_page_type` tinyint NOT NULL,
  `dl_sub_level_1` tinyint NOT NULL,
  `dl_sub_level_2` tinyint NOT NULL,
  `folder_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `structured_contents_published`
--

DROP TABLE IF EXISTS `structured_contents_published`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_contents_published` (
  `id` int(11) unsigned NOT NULL,
  `uuid` varchar(36) NOT NULL DEFAULT '',
  `catalog_id` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `type` enum('content','page') NOT NULL DEFAULT 'content',
  `template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `publish_status` enum('unpublished','queued','published','error') NOT NULL DEFAULT 'unpublished',
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
  `publish_log` mediumtext NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) NOT NULL DEFAULT 0,
  `unique_id` varchar(250) DEFAULT NULL,
  `upd_on_by_webmaster` datetime DEFAULT NULL,
  `crt_by_webmaster` varchar(500) DEFAULT NULL,
  `upd_by_webmaster` varchar(500) DEFAULT NULL,
  `structured_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  KEY `idx1` (`site_id`,`uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_contents_published`
--

LOCK TABLES `structured_contents_published` WRITE;
/*!40000 ALTER TABLE `structured_contents_published` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_contents_published` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structured_contents_tbl`
--

DROP TABLE IF EXISTS `structured_contents_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structured_contents_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `type` enum('content','page') NOT NULL DEFAULT 'content',
  `template_id` int(11) unsigned NOT NULL DEFAULT 0,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `publish_status` enum('unpublished','queued','published','error') NOT NULL DEFAULT 'unpublished',
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
  `publish_log` mediumtext NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) NOT NULL DEFAULT 0,
  `unique_id` varchar(250) DEFAULT NULL,
  `upd_on_by_webmaster` datetime DEFAULT NULL,
  `crt_by_webmaster` varchar(500) DEFAULT NULL,
  `upd_by_webmaster` varchar(500) DEFAULT NULL,
  `structured_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  KEY `idx_site_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structured_contents_tbl`
--

LOCK TABLES `structured_contents_tbl` WRITE;
/*!40000 ALTER TABLE `structured_contents_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `structured_contents_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_history`
--

DROP TABLE IF EXISTS `tags_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lang_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `item_type` varchar(50) NOT NULL,
  `old_data` mediumtext NOT NULL,
  `new_data` mediumtext NOT NULL,
  `updated_by` int(11) NOT NULL,
  `created_ts` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_history`
--

LOCK TABLES `tags_history` WRITE;
/*!40000 ALTER TABLE `tags_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template_reserved_ids`
--

DROP TABLE IF EXISTS `template_reserved_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_reserved_ids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `template_type` enum('configurable_product','simple_product') NOT NULL,
  `item_type` varchar(50) NOT NULL,
  `item_id` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=117 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `template_reserved_ids`
--

LOCK TABLES `template_reserved_ids` WRITE;
/*!40000 ALTER TABLE `template_reserved_ids` DISABLE KEYS */;
INSERT INTO `template_reserved_ids` VALUES (1,'98cc0065-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','main_information'),(2,'98cc01cc-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','product_general_informations'),(3,'98cc01fd-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','product_main_informations'),(4,'98cc020e-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants'),(5,'98cc021b-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants_variant_x'),(6,'98cc0229-45ad-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants_variant_x_specifications'),(7,'98cc0235-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','system_product_name'),(8,'98cc0241-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_id'),(9,'98cc024e-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_product_id'),(10,'98cc025b-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_manufacturer'),(11,'98cc0268-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_short_description'),(12,'98cc0274-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_long_description'),(13,'98cc0280-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_image'),(14,'98cc028e-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_tags'),(15,'98cc0299-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_id'),(16,'98cc02a5-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_name'),(17,'98cc02b1-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_ean'),(18,'98cc02bc-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_sku'),(19,'98cc02c8-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_price'),(20,'98cc02d4-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_frequency'),(21,'98cc02df-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_display'),(22,'98cc02eb-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_short_description'),(23,'98cc02fa-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_long_description'),(24,'98cc0306-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_attributes'),(25,'98cc0312-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_image'),(26,'98cc031e-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_tags'),(27,'98cc032a-45ad-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_specifications_x_spec'),(28,'98cc0336-45ad-11ef-b78d-fa163ed11cf5','simple_product','section','product_main_informations'),(29,'98cc0342-45ad-11ef-b78d-fa163ed11cf5','simple_product','section','product_general_informations'),(30,'98cc034d-45ad-11ef-b78d-fa163ed11cf5','simple_product','section','product_specifications'),(31,'98cc0359-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','system_product_name'),(32,'98cc0364-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_id'),(33,'98cc0371-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_product_id'),(34,'98cc037c-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_variant_id'),(35,'98cc0387-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_ean'),(36,'98cc0392-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_sku'),(37,'98cc039d-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_manufacturer'),(38,'98cc03a9-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_price'),(39,'98cc03b4-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_frequency'),(40,'98cc03c0-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_display'),(41,'98cc03cb-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_short_description'),(42,'98cc03d7-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_long_description'),(43,'98cc03e3-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_image'),(44,'98cc03ee-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_tags'),(45,'98cc03f9-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_attributes'),(46,'98cc0405-45ad-11ef-b78d-fa163ed11cf5','simple_product','field','product_specifications_x_spec'),(47,'3124ff5f-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','main_information'),(48,'3124ffd9-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','product_general_informations'),(49,'3124fff1-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','product_main_informations'),(50,'31250000-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants'),(51,'3125000e-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants_variant_x'),(52,'3125001d-5593-11ef-b78d-fa163ed11cf5','configurable_product','section','product_variants_variant_x_specifications'),(53,'3125002b-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','system_product_name'),(54,'31250037-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_id'),(55,'31250046-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_product_id'),(56,'31250055-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_manufacturer'),(57,'31250064-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_short_description'),(58,'31250073-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_long_description'),(59,'31250081-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_image'),(60,'3125008f-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_tags'),(61,'3125009d-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_id'),(62,'312500ab-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_name'),(63,'312500b8-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_ean'),(64,'312500c6-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_sku'),(65,'312500d3-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_price'),(66,'312500e2-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_frequency'),(67,'312500f0-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_price_display'),(68,'312500ff-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_short_description'),(69,'3125010d-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_long_description'),(70,'3125011b-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_attributes'),(71,'31250129-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_image'),(72,'31250136-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_tags'),(73,'31250144-5593-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_specifications_x_spec'),(74,'31250153-5593-11ef-b78d-fa163ed11cf5','simple_product','section','product_main_informations'),(75,'31250161-5593-11ef-b78d-fa163ed11cf5','simple_product','section','product_general_informations'),(76,'3125016e-5593-11ef-b78d-fa163ed11cf5','simple_product','section','product_specifications'),(77,'3125017b-5593-11ef-b78d-fa163ed11cf5','simple_product','field','system_product_name'),(78,'31250188-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_id'),(79,'31250196-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_product_id'),(80,'312501a4-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_variant_id'),(81,'312501b1-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_ean'),(82,'312501bf-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_sku'),(83,'312501cd-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_manufacturer'),(84,'312501da-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_price'),(85,'312501e8-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_frequency'),(86,'312501f6-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_price_display'),(87,'31250204-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_short_description'),(88,'31250212-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_long_description'),(89,'31250220-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_image'),(90,'3125022d-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_tags'),(91,'3125023a-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_attributes'),(92,'31250247-5593-11ef-b78d-fa163ed11cf5','simple_product','field','product_specifications_x_spec'),(96,'3668cd75-92c4-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_tags_id'),(101,'3668cdbe-92c4-11ef-b78d-fa163ed11cf5','simple_product','field','product_general_informations_image_alt'),(107,'36690416-92c4-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_tags_id'),(108,'36690427-92c4-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_image_alt'),(109,'3669043b-92c4-11ef-b78d-fa163ed11cf5','configurable_product','field','product_variants_variant_x_tags_id'),(114,'36690494-92c4-11ef-b78d-fa163ed11cf5','configurable_product','field','product_general_informations_image_alt');
/*!40000 ALTER TABLE `template_reserved_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(100) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `version` varchar(10) NOT NULL,
  `asimina_version` varchar(10) NOT NULL DEFAULT '1.0.0',
  `description` varchar(1000) NOT NULL DEFAULT '',
  `status` enum('opened','locked') NOT NULL DEFAULT 'opened',
  `type` enum('local','remote') NOT NULL DEFAULT 'local',
  `is_active` tinyint(1) DEFAULT 0,
  `created_ts` datetime NOT NULL,
  `updated_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `published_by` int(11) DEFAULT NULL,
  `published_ts` datetime DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` int(11) DEFAULT NULL,
  `to_unpublish_by` int(11) DEFAULT NULL,
  `to_publish_ts` datetime DEFAULT NULL,
  `to_unpublish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','queued','processing','published','error') NOT NULL DEFAULT 'unpublished',
  `publish_log` mediumtext NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_theme` (`id`,`site_id`,`name`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
/*!40000 ALTER TABLE `themes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unpublished_pages_applied_files`
--

DROP TABLE IF EXISTS `unpublished_pages_applied_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unpublished_pages_applied_files` (
  `page_id` int(11) NOT NULL,
  `bloc_template_id` int(11) DEFAULT NULL,
  `bloc_templates_lib_id` int(11) DEFAULT NULL,
  `library_id` int(11) DEFAULT NULL,
  `file_id` int(11) NOT NULL,
  `file_name` varchar(500) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_update_ts` varchar(75) DEFAULT NULL,
  `library_name` varchar(500) DEFAULT NULL,
  `page_position` varchar(25) DEFAULT NULL,
  `sort_order` int(10) DEFAULT NULL,
  `applicable_sort_order` int(10) DEFAULT NULL,
  KEY `idx1` (`page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unpublished_pages_applied_files`
--

LOCK TABLES `unpublished_pages_applied_files` WRITE;
/*!40000 ALTER TABLE `unpublished_pages_applied_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `unpublished_pages_applied_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variables`
--

DROP TABLE IF EXISTS `variables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `variables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(500) NOT NULL,
  `value` varchar(500) NOT NULL,
  `site_id` int(11) NOT NULL,
  `created_ts` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `is_editable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variables`
--

LOCK TABLES `variables` WRITE;
/*!40000 ALTER TABLE `variables` DISABLE KEYS */;
/*!40000 ALTER TABLE `variables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `bloc_templates`
--

/*!50001 DROP TABLE IF EXISTS `bloc_templates`*/;
/*!50001 DROP VIEW IF EXISTS `bloc_templates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `bloc_templates` AS select `bloc_templates_tbl`.`id` AS `id`,`bloc_templates_tbl`.`name` AS `name`,`bloc_templates_tbl`.`site_id` AS `site_id`,`bloc_templates_tbl`.`custom_id` AS `custom_id`,`bloc_templates_tbl`.`type` AS `type`,`bloc_templates_tbl`.`description` AS `description`,`bloc_templates_tbl`.`template_code` AS `template_code`,`bloc_templates_tbl`.`css_code` AS `css_code`,`bloc_templates_tbl`.`js_code` AS `js_code`,`bloc_templates_tbl`.`jsonld_code` AS `jsonld_code`,`bloc_templates_tbl`.`theme_id` AS `theme_id`,`bloc_templates_tbl`.`theme_version` AS `theme_version`,`bloc_templates_tbl`.`is_system` AS `is_system`,`bloc_templates_tbl`.`created_ts` AS `created_ts`,`bloc_templates_tbl`.`updated_ts` AS `updated_ts`,`bloc_templates_tbl`.`created_by` AS `created_by`,`bloc_templates_tbl`.`updated_by` AS `updated_by`,`bloc_templates_tbl`.`is_deleted` AS `is_deleted` from `bloc_templates_tbl` where `bloc_templates_tbl`.`is_deleted` = 0 */;
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
-- Final view structure for view `files`
--

/*!50001 DROP TABLE IF EXISTS `files`*/;
/*!50001 DROP VIEW IF EXISTS `files`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `files` AS select `files_tbl`.`id` AS `id`,`files_tbl`.`file_name` AS `file_name`,`files_tbl`.`site_id` AS `site_id`,`files_tbl`.`label` AS `label`,`files_tbl`.`type` AS `type`,`files_tbl`.`file_size` AS `file_size`,`files_tbl`.`images_generated` AS `images_generated`,`files_tbl`.`theme_id` AS `theme_id`,`files_tbl`.`theme_version` AS `theme_version`,`files_tbl`.`created_ts` AS `created_ts`,`files_tbl`.`updated_ts` AS `updated_ts`,`files_tbl`.`created_by` AS `created_by`,`files_tbl`.`updated_by` AS `updated_by`,`files_tbl`.`times_used` AS `times_used`,`files_tbl`.`is_deleted` AS `is_deleted`,`files_tbl`.`description` AS `description`,`files_tbl`.`alt_name` AS `alt_name`,`files_tbl`.`removal_date` AS `removal_date`,`files_tbl`.`thumbnail` AS `thumbnail` from `files_tbl` where `files_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `folders`
--

/*!50001 DROP TABLE IF EXISTS `folders`*/;
/*!50001 DROP VIEW IF EXISTS `folders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `folders` AS select `folders_tbl`.`id` AS `id`,`folders_tbl`.`uuid` AS `uuid`,`folders_tbl`.`name` AS `name`,`folders_tbl`.`site_id` AS `site_id`,`folders_tbl`.`parent_folder_id` AS `parent_folder_id`,`folders_tbl`.`folder_level` AS `folder_level`,`folders_tbl`.`type` AS `type`,`folders_tbl`.`created_ts` AS `created_ts`,`folders_tbl`.`updated_ts` AS `updated_ts`,`folders_tbl`.`created_by` AS `created_by`,`folders_tbl`.`updated_by` AS `updated_by`,`folders_tbl`.`is_deleted` AS `is_deleted`,`folders_tbl`.`deleted_by` AS `deleted_by`,`folders_tbl`.`dl_page_type` AS `dl_page_type`,`folders_tbl`.`dl_sub_level_1` AS `dl_sub_level_1`,`folders_tbl`.`dl_sub_level_2` AS `dl_sub_level_2`,`folders_tbl`.`folder_version` AS `folder_version` from `folders_tbl` where `folders_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `freemarker_pages`
--

/*!50001 DROP TABLE IF EXISTS `freemarker_pages`*/;
/*!50001 DROP VIEW IF EXISTS `freemarker_pages`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `freemarker_pages` AS select `freemarker_pages_tbl`.`id` AS `id`,`freemarker_pages_tbl`.`uuid` AS `uuid`,`freemarker_pages_tbl`.`name` AS `name`,`freemarker_pages_tbl`.`site_id` AS `site_id`,`freemarker_pages_tbl`.`folder_id` AS `folder_id`,`freemarker_pages_tbl`.`is_deleted` AS `is_deleted`,`freemarker_pages_tbl`.`created_ts` AS `created_ts`,`freemarker_pages_tbl`.`updated_ts` AS `updated_ts`,`freemarker_pages_tbl`.`published_ts` AS `published_ts`,`freemarker_pages_tbl`.`created_by` AS `created_by`,`freemarker_pages_tbl`.`updated_by` AS `updated_by`,`freemarker_pages_tbl`.`published_by` AS `published_by`,`freemarker_pages_tbl`.`to_generate` AS `to_generate`,`freemarker_pages_tbl`.`to_generate_by` AS `to_generate_by`,`freemarker_pages_tbl`.`to_publish` AS `to_publish`,`freemarker_pages_tbl`.`to_publish_by` AS `to_publish_by`,`freemarker_pages_tbl`.`to_publish_ts` AS `to_publish_ts`,`freemarker_pages_tbl`.`to_unpublish` AS `to_unpublish`,`freemarker_pages_tbl`.`to_unpublish_by` AS `to_unpublish_by`,`freemarker_pages_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,`freemarker_pages_tbl`.`publish_status` AS `publish_status`,`freemarker_pages_tbl`.`publish_log` AS `publish_log`,`freemarker_pages_tbl`.`deleted_by` AS `deleted_by`,`freemarker_pages_tbl`.`upd_on_by_webmaster` AS `upd_on_by_webmaster`,`freemarker_pages_tbl`.`crt_by_webmaster` AS `crt_by_webmaster`,`freemarker_pages_tbl`.`upd_by_webmaster` AS `upd_by_webmaster` from `freemarker_pages_tbl` where `freemarker_pages_tbl`.`is_deleted` = 0 */;
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
-- Final view structure for view `libraries`
--

/*!50001 DROP TABLE IF EXISTS `libraries`*/;
/*!50001 DROP VIEW IF EXISTS `libraries`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `libraries` AS select `libraries_tbl`.`id` AS `id`,`libraries_tbl`.`name` AS `name`,`libraries_tbl`.`site_id` AS `site_id`,`libraries_tbl`.`theme_id` AS `theme_id`,`libraries_tbl`.`theme_version` AS `theme_version`,`libraries_tbl`.`created_ts` AS `created_ts`,`libraries_tbl`.`updated_ts` AS `updated_ts`,`libraries_tbl`.`created_by` AS `created_by`,`libraries_tbl`.`updated_by` AS `updated_by`,`libraries_tbl`.`is_deleted` AS `is_deleted` from `libraries_tbl` where `libraries_tbl`.`is_deleted` = 0 */;
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
-- Final view structure for view `menus`
--

/*!50001 DROP TABLE IF EXISTS `menus`*/;
/*!50001 DROP VIEW IF EXISTS `menus`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `menus` AS select `cleandb_portal`.`menus`.`id` AS `id`,`cleandb_portal`.`menus`.`uuid` AS `uuid`,`cleandb_portal`.`menus`.`name` AS `name`,`cleandb_portal`.`menus`.`site_id` AS `site_id`,`cleandb_portal`.`menus`.`template_id` AS `template_id`,`cleandb_portal`.`menus`.`langue_id` AS `langue_id`,`cleandb_portal`.`menus`.`variant` AS `variant`,`cleandb_portal`.`menus`.`template_data` AS `template_data`,`cleandb_portal`.`menus`.`created_ts` AS `created_ts`,`cleandb_portal`.`menus`.`updated_ts` AS `updated_ts`,`cleandb_portal`.`menus`.`published_ts` AS `published_ts`,`cleandb_portal`.`menus`.`created_by` AS `created_by`,`cleandb_portal`.`menus`.`updated_by` AS `updated_by`,`cleandb_portal`.`menus`.`published_by` AS `published_by`,`cleandb_portal`.`menus`.`to_generate` AS `to_generate`,`cleandb_portal`.`menus`.`to_generate_by` AS `to_generate_by`,`cleandb_portal`.`menus`.`to_publish` AS `to_publish`,`cleandb_portal`.`menus`.`to_publish_by` AS `to_publish_by`,`cleandb_portal`.`menus`.`to_publish_ts` AS `to_publish_ts`,`cleandb_portal`.`menus`.`to_unpublish` AS `to_unpublish`,`cleandb_portal`.`menus`.`to_unpublish_by` AS `to_unpublish_by`,`cleandb_portal`.`menus`.`to_unpublish_ts` AS `to_unpublish_ts`,`cleandb_portal`.`menus`.`publish_status` AS `publish_status`,`cleandb_portal`.`menus`.`publish_log` AS `publish_log` from `cleandb_portal`.`menus` */;
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
-- Final view structure for view `page_templates`
--

/*!50001 DROP TABLE IF EXISTS `page_templates`*/;
/*!50001 DROP VIEW IF EXISTS `page_templates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `page_templates` AS select `page_templates_tbl`.`id` AS `id`,`page_templates_tbl`.`name` AS `name`,`page_templates_tbl`.`site_id` AS `site_id`,`page_templates_tbl`.`custom_id` AS `custom_id`,`page_templates_tbl`.`description` AS `description`,`page_templates_tbl`.`template_code` AS `template_code`,`page_templates_tbl`.`is_system` AS `is_system`,`page_templates_tbl`.`theme_id` AS `theme_id`,`page_templates_tbl`.`theme_version` AS `theme_version`,`page_templates_tbl`.`uuid` AS `uuid`,`page_templates_tbl`.`created_ts` AS `created_ts`,`page_templates_tbl`.`updated_ts` AS `updated_ts`,`page_templates_tbl`.`created_by` AS `created_by`,`page_templates_tbl`.`updated_by` AS `updated_by`,`page_templates_tbl`.`is_deleted` AS `is_deleted` from `page_templates_tbl` where `page_templates_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pages`
--

/*!50001 DROP TABLE IF EXISTS `pages`*/;
/*!50001 DROP VIEW IF EXISTS `pages`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pages` AS select `pages_tbl`.`id` AS `id`,`pages_tbl`.`uuid` AS `uuid`,`pages_tbl`.`name` AS `name`,`pages_tbl`.`site_id` AS `site_id`,`pages_tbl`.`type` AS `type`,`pages_tbl`.`path` AS `path`,`pages_tbl`.`langue_code` AS `langue_code`,`pages_tbl`.`variant` AS `variant`,`pages_tbl`.`folder_id` AS `folder_id`,`pages_tbl`.`html_file_path` AS `html_file_path`,`pages_tbl`.`published_html_file_path` AS `published_html_file_path`,`pages_tbl`.`canonical_url` AS `canonical_url`,`pages_tbl`.`title` AS `title`,`pages_tbl`.`meta_keywords` AS `meta_keywords`,`pages_tbl`.`meta_description` AS `meta_description`,`pages_tbl`.`template_id` AS `template_id`,`pages_tbl`.`dl_page_type` AS `dl_page_type`,`pages_tbl`.`dl_sub_level_1` AS `dl_sub_level_1`,`pages_tbl`.`dl_sub_level_2` AS `dl_sub_level_2`,`pages_tbl`.`package_name` AS `package_name`,`pages_tbl`.`class_name` AS `class_name`,`pages_tbl`.`layout` AS `layout`,`pages_tbl`.`created_ts` AS `created_ts`,`pages_tbl`.`updated_ts` AS `updated_ts`,`pages_tbl`.`published_ts` AS `published_ts`,`pages_tbl`.`created_by` AS `created_by`,`pages_tbl`.`updated_by` AS `updated_by`,`pages_tbl`.`published_by` AS `published_by`,`pages_tbl`.`social_title` AS `social_title`,`pages_tbl`.`social_type` AS `social_type`,`pages_tbl`.`social_description` AS `social_description`,`pages_tbl`.`social_image` AS `social_image`,`pages_tbl`.`social_twitter_message` AS `social_twitter_message`,`pages_tbl`.`social_twitter_hashtags` AS `social_twitter_hashtags`,`pages_tbl`.`social_email_subject` AS `social_email_subject`,`pages_tbl`.`social_email_popin_title` AS `social_email_popin_title`,`pages_tbl`.`social_email_message` AS `social_email_message`,`pages_tbl`.`social_sms_text` AS `social_sms_text`,`pages_tbl`.`to_generate` AS `to_generate`,`pages_tbl`.`to_generate_by` AS `to_generate_by`,`pages_tbl`.`to_publish` AS `to_publish`,`pages_tbl`.`to_publish_by` AS `to_publish_by`,`pages_tbl`.`to_publish_ts` AS `to_publish_ts`,`pages_tbl`.`to_unpublish` AS `to_unpublish`,`pages_tbl`.`to_unpublish_by` AS `to_unpublish_by`,`pages_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,`pages_tbl`.`publish_status` AS `publish_status`,`pages_tbl`.`publish_log` AS `publish_log`,`pages_tbl`.`row_height` AS `row_height`,`pages_tbl`.`item_margin_x` AS `item_margin_x`,`pages_tbl`.`item_margin_y` AS `item_margin_y`,`pages_tbl`.`container_padding_x` AS `container_padding_x`,`pages_tbl`.`container_padding_y` AS `container_padding_y`,`pages_tbl`.`get_html_status` AS `get_html_status`,`pages_tbl`.`get_html_log` AS `get_html_log`,`pages_tbl`.`dynamic_html` AS `dynamic_html`,`pages_tbl`.`layout_data` AS `layout_data`,`pages_tbl`.`parent_page_id` AS `parent_page_id`,`pages_tbl`.`is_deleted` AS `is_deleted`,`pages_tbl`.`deleted_by` AS `deleted_by`,`pages_tbl`.`attempt` AS `attempt`,`pages_tbl`.`page_version` AS `page_version` from `pages_tbl` where `pages_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pages_blocs`
--

/*!50001 DROP TABLE IF EXISTS `pages_blocs`*/;
/*!50001 DROP VIEW IF EXISTS `pages_blocs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pages_blocs` AS select `p`.`id` AS `page_id`,`ppb`.`bloc_id` AS `bloc_id`,`ppb`.`sort_order` AS `sort_order`,`ppb`.`type` AS `type` from ((`freemarker_pages` `bp` left join `pages` `p` on(`p`.`parent_page_id` = `bp`.`id` and `p`.`type` = 'freemarker')) join `parent_pages_blocs` `ppb` on(`ppb`.`type` = 'freemarker' and `ppb`.`page_id` = `bp`.`id`)) union select `scd`.`page_id` AS `page_id`,`ppb`.`bloc_id` AS `bloc_id`,`ppb`.`sort_order` AS `sort_order`,`ppb`.`type` AS `type` from ((`structured_contents` `sc` join `structured_contents_details` `scd` on(`scd`.`content_id` = `sc`.`id`)) join `parent_pages_blocs` `ppb` on(`ppb`.`type` = 'structured' and `ppb`.`page_id` = `sc`.`id`)) where `sc`.`type` = 'page' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pages_folders`
--

/*!50001 DROP TABLE IF EXISTS `pages_folders`*/;
/*!50001 DROP VIEW IF EXISTS `pages_folders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pages_folders` AS select `folders`.`id` AS `id`,`folders`.`uuid` AS `uuid`,`folders`.`name` AS `name`,`folders`.`site_id` AS `site_id`,`folders`.`parent_folder_id` AS `parent_folder_id`,`folders`.`folder_level` AS `folder_level`,`folders`.`type` AS `type`,`folders`.`created_ts` AS `created_ts`,`folders`.`updated_ts` AS `updated_ts`,`folders`.`created_by` AS `created_by`,`folders`.`updated_by` AS `updated_by`,`folders`.`is_deleted` AS `is_deleted`,`folders`.`deleted_by` AS `deleted_by`,`folders`.`dl_page_type` AS `dl_page_type`,`folders`.`dl_sub_level_1` AS `dl_sub_level_1`,`folders`.`dl_sub_level_2` AS `dl_sub_level_2`,`folders`.`folder_version` AS `folder_version` from `folders` where `folders`.`type` = 'pages' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pages_folders_lang_path`
--

/*!50001 DROP TABLE IF EXISTS `pages_folders_lang_path`*/;
/*!50001 DROP VIEW IF EXISTS `pages_folders_lang_path`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pages_folders_lang_path` AS select `f`.`site_id` AS `site_id`,`f`.`id` AS `folder_id`,`fd`.`langue_id` AS `langue_id`,concat_ws('/',nullif(`fd4`.`path_prefix`,''),nullif(`fd3`.`path_prefix`,''),nullif(`fd2`.`path_prefix`,''),nullif(`fd`.`path_prefix`,'')) AS `concat_path`,`f`.`folder_level` AS `folder_level`,`fd`.`path_prefix` AS `path1`,`fd2`.`path_prefix` AS `path2`,`fd3`.`path_prefix` AS `path3`,`fd4`.`path_prefix` AS `path4` from (((((((`folders` `f` join `folders_details` `fd` on(`fd`.`folder_id` = `f`.`id`)) left join `folders` `f2` on(`f`.`parent_folder_id` = `f2`.`id`)) left join `folders_details` `fd2` on(`fd2`.`folder_id` = `f2`.`id` and `fd`.`langue_id` = `fd2`.`langue_id`)) left join `folders` `f3` on(`f2`.`parent_folder_id` = `f3`.`id`)) left join `folders_details` `fd3` on(`fd3`.`folder_id` = `f3`.`id` and `fd`.`langue_id` = `fd3`.`langue_id`)) left join `folders` `f4` on(`f3`.`parent_folder_id` = `f4`.`id`)) left join `folders_details` `fd4` on(`fd4`.`folder_id` = `f4`.`id` and `fd`.`langue_id` = `fd4`.`langue_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pages_forms`
--

/*!50001 DROP TABLE IF EXISTS `pages_forms`*/;
/*!50001 DROP VIEW IF EXISTS `pages_forms`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pages_forms` AS select `p`.`id` AS `page_id`,`ppf`.`form_id` AS `form_id`,`ppf`.`sort_order` AS `sort_order`,`ppf`.`type` AS `type` from ((`freemarker_pages` `bp` join `pages` `p` on(`p`.`parent_page_id` = `bp`.`id` and `p`.`type` = 'freemarker')) join `parent_pages_forms` `ppf` on(`ppf`.`type` = 'freemarker' and `ppf`.`page_id` = `bp`.`id`)) union select `scd`.`page_id` AS `page_id`,`ppf`.`form_id` AS `form_id`,`ppf`.`sort_order` AS `sort_order`,`ppf`.`type` AS `type` from ((`structured_contents` `sc` join `structured_contents_details` `scd` on(`scd`.`content_id` = `sc`.`id`)) join `parent_pages_forms` `ppf` on(`ppf`.`type` = 'structured' and `ppf`.`page_id` = `sc`.`id`)) where `sc`.`type` = 'page' */;
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

--
-- Final view structure for view `stores_folders`
--

/*!50001 DROP TABLE IF EXISTS `stores_folders`*/;
/*!50001 DROP VIEW IF EXISTS `stores_folders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `stores_folders` AS select `folders`.`id` AS `id`,`folders`.`uuid` AS `uuid`,`folders`.`name` AS `name`,`folders`.`site_id` AS `site_id`,`folders`.`parent_folder_id` AS `parent_folder_id`,`folders`.`folder_level` AS `folder_level`,`folders`.`type` AS `type`,`folders`.`created_ts` AS `created_ts`,`folders`.`updated_ts` AS `updated_ts`,`folders`.`created_by` AS `created_by`,`folders`.`updated_by` AS `updated_by`,`folders`.`is_deleted` AS `is_deleted`,`folders`.`deleted_by` AS `deleted_by`,`folders`.`dl_page_type` AS `dl_page_type`,`folders`.`dl_sub_level_1` AS `dl_sub_level_1`,`folders`.`dl_sub_level_2` AS `dl_sub_level_2`,`folders`.`folder_version` AS `folder_version` from `folders` where `folders`.`type` = 'stores' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `structured_contents`
--

/*!50001 DROP TABLE IF EXISTS `structured_contents`*/;
/*!50001 DROP VIEW IF EXISTS `structured_contents`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `structured_contents` AS select `structured_contents_tbl`.`id` AS `id`,`structured_contents_tbl`.`uuid` AS `uuid`,`structured_contents_tbl`.`catalog_id` AS `catalog_id`,`structured_contents_tbl`.`name` AS `name`,`structured_contents_tbl`.`site_id` AS `site_id`,`structured_contents_tbl`.`type` AS `type`,`structured_contents_tbl`.`template_id` AS `template_id`,`structured_contents_tbl`.`folder_id` AS `folder_id`,`structured_contents_tbl`.`publish_status` AS `publish_status`,`structured_contents_tbl`.`created_ts` AS `created_ts`,`structured_contents_tbl`.`updated_ts` AS `updated_ts`,`structured_contents_tbl`.`published_ts` AS `published_ts`,`structured_contents_tbl`.`created_by` AS `created_by`,`structured_contents_tbl`.`updated_by` AS `updated_by`,`structured_contents_tbl`.`published_by` AS `published_by`,`structured_contents_tbl`.`to_generate` AS `to_generate`,`structured_contents_tbl`.`to_generate_by` AS `to_generate_by`,`structured_contents_tbl`.`to_publish` AS `to_publish`,`structured_contents_tbl`.`to_publish_by` AS `to_publish_by`,`structured_contents_tbl`.`to_publish_ts` AS `to_publish_ts`,`structured_contents_tbl`.`to_unpublish` AS `to_unpublish`,`structured_contents_tbl`.`to_unpublish_by` AS `to_unpublish_by`,`structured_contents_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,`structured_contents_tbl`.`publish_log` AS `publish_log`,`structured_contents_tbl`.`is_deleted` AS `is_deleted`,`structured_contents_tbl`.`deleted_by` AS `deleted_by`,`structured_contents_tbl`.`unique_id` AS `unique_id`,`structured_contents_tbl`.`upd_on_by_webmaster` AS `upd_on_by_webmaster`,`structured_contents_tbl`.`crt_by_webmaster` AS `crt_by_webmaster`,`structured_contents_tbl`.`upd_by_webmaster` AS `upd_by_webmaster`,`structured_contents_tbl`.`structured_version` AS `structured_version` from `structured_contents_tbl` where `structured_contents_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `structured_contents_folders`
--

/*!50001 DROP TABLE IF EXISTS `structured_contents_folders`*/;
/*!50001 DROP VIEW IF EXISTS `structured_contents_folders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `structured_contents_folders` AS select `folders`.`id` AS `id`,`folders`.`uuid` AS `uuid`,`folders`.`name` AS `name`,`folders`.`site_id` AS `site_id`,`folders`.`parent_folder_id` AS `parent_folder_id`,`folders`.`folder_level` AS `folder_level`,`folders`.`type` AS `type`,`folders`.`created_ts` AS `created_ts`,`folders`.`updated_ts` AS `updated_ts`,`folders`.`created_by` AS `created_by`,`folders`.`updated_by` AS `updated_by`,`folders`.`is_deleted` AS `is_deleted`,`folders`.`deleted_by` AS `deleted_by`,`folders`.`dl_page_type` AS `dl_page_type`,`folders`.`dl_sub_level_1` AS `dl_sub_level_1`,`folders`.`dl_sub_level_2` AS `dl_sub_level_2`,`folders`.`folder_version` AS `folder_version` from `folders` where `folders`.`type` = 'contents' */;
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

-- Dump completed on 2024-12-05 20:21:49
