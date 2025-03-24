-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_expert_system
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
-- Table structure for table `check_rights`
--

DROP TABLE IF EXISTS `check_rights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `check_rights` (
  `url` varchar(150) NOT NULL,
  PRIMARY KEY (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `check_rights`
--

LOCK TABLES `check_rights` WRITE;
/*!40000 ALTER TABLE `check_rights` DISABLE KEYS */;
/*!40000 ALTER TABLE `check_rights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `code` varchar(100) NOT NULL,
  `val` varchar(255) DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 `ENCRYPTED`=Yes;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('CATALOG_DB','cleandb_catalog',NULL),('CATALOG_URL','/asimina_catalog/',NULL),('CKEDITOR_DB_NAME','cleandb_ckeditor',NULL),('CKEDITOR_DOWNLOAD_PAGES_FOLDER','/asimina_ckeditor/sites/',NULL),('CKEDITOR_WEB_APP','/asimina_ckeditor/',NULL),('CKEDITOR_WEB_URL','/home/asimina/tomcat/webapps/asimina_ckeditor/pages/',NULL),('COMMONS_DB','cleandb_commons',NULL),('DOWNLOAD_PAGES_FOLDER','/home/asimina/tomcat/webapps/asimina_ckeditor/sites/',NULL),('EXPERT_SYSTEM_D3_TEMPLATES_PATH','/home/asimina/tomcat/webapps/asimina_expert_system/pages/d3templates/',NULL),('EXPERT_SYSTEM_FETCH_JSP_TEMPLATE','/home/asimina/tomcat/webapps/asimina_expert_system/pages/fetchdatajsptemplate',NULL),('EXPERT_SYSTEM_GENERATED_HTML_RELATIVE_PATH','generatedHtmls/',NULL),('EXPERT_SYSTEM_GENERATED_JSP_RELATIVE_PATH','generatedJsps/',NULL),('EXPERT_SYSTEM_GENERATED_JS_URL','/generatedJs/',NULL),('EXPERT_SYSTEM_GENERATE_HTML_FOLDER','/home/asimina/tomcat/webapps/asimina_expert_system/generatedHtmls/',NULL),('EXPERT_SYSTEM_GENERATE_JSP_FOLDER','/home/asimina/tomcat/webapps/asimina_expert_system/generatedJsps/',NULL),('EXPERT_SYSTEM_GENERATE_JSP_URL','/asimina_expert_system/generatedJsps/',NULL),('EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER','/home/asimina/tomcat/webapps/asimina_expert_system/generatedJs/',NULL),('EXPERT_SYSTEM_HELPER_JS_CSS_URL','/pages/',NULL),('EXPERT_SYSTEM_JQUERY_URL','/asimina_expert_system/js/jquery.min.js',NULL),('EXPERT_SYSTEM_RELATIVE_PATH_TO_GENERATE_JSP','../pages/',NULL),('EXPERT_SYSTEM_WEB_APP','/asimina_expert_system/',NULL),('GOTO_EXPSYS_APP_URL','/asimina_catalog/admin/gotoexpertsystem.jsp',NULL),('PORTAL_DB','cleandb_portal',NULL),('REQUETE_WEB_APP','',NULL),('ROOT_WEB','asimina_expert_system',NULL),('WEBAPP_FOLDER','/home/asimina/tomcat/webapps/asimina_expert_system/',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dest_page_filters`
--

DROP TABLE IF EXISTS `dest_page_filters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dest_page_filters` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dest_page_id` int(10) DEFAULT NULL,
  `display_name` varchar(50) DEFAULT NULL,
  `user_filter_type` varchar(10) DEFAULT NULL,
  `used_as_parameter` char(1) DEFAULT NULL,
  `option_query` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dest_page_filters`
--

LOCK TABLES `dest_page_filters` WRITE;
/*!40000 ALTER TABLE `dest_page_filters` DISABLE KEYS */;
/*!40000 ALTER TABLE `dest_page_filters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dest_page_setting`
--

DROP TABLE IF EXISTS `dest_page_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dest_page_setting` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `destination_page` varchar(250) DEFAULT NULL,
  `maunal_screen` char(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dest_page_setting`
--

LOCK TABLES `dest_page_setting` WRITE;
/*!40000 ALTER TABLE `dest_page_setting` DISABLE KEYS */;
/*!40000 ALTER TABLE `dest_page_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dest_page_settings`
--

DROP TABLE IF EXISTS `dest_page_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dest_page_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `destination_page` varchar(250) DEFAULT NULL,
  `auto_screen` char(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dest_page_settings`
--

LOCK TABLES `dest_page_settings` WRITE;
/*!40000 ALTER TABLE `dest_page_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `dest_page_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `es_queries`
--

DROP TABLE IF EXISTS `es_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `es_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `pagination_col` varchar(255) DEFAULT NULL,
  `ignore_selectable_col` varchar(255) DEFAULT NULL,
  `query` text DEFAULT NULL,
  `distinct_keys_query` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `es_queries`
--

LOCK TABLES `es_queries` WRITE;
/*!40000 ALTER TABLE `es_queries` DISABLE KEYS */;
/*!40000 ALTER TABLE `es_queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `es_query_col_mapping`
--

DROP TABLE IF EXISTS `es_query_col_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `es_query_col_mapping` (
  `query_name` varchar(50) NOT NULL,
  `col` varchar(255) NOT NULL,
  `mapped_cols` varchar(500) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `es_query_col_mapping`
--

LOCK TABLES `es_query_col_mapping` WRITE;
/*!40000 ALTER TABLE `es_query_col_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `es_query_col_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `es_query_levels`
--

DROP TABLE IF EXISTS `es_query_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `es_query_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_name` varchar(25) DEFAULT NULL,
  `parent_level_id` int(11) DEFAULT NULL,
  `j_object` varchar(25) DEFAULT NULL,
  `j_object_key` varchar(25) DEFAULT NULL,
  `j_object_columns` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `es_query_levels`
--

LOCK TABLES `es_query_levels` WRITE;
/*!40000 ALTER TABLE `es_query_levels` DISABLE KEYS */;
/*!40000 ALTER TABLE `es_query_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_conditions`
--

DROP TABLE IF EXISTS `expert_system_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_conditions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_id` int(10) unsigned NOT NULL,
  `json_tag` varchar(250) NOT NULL,
  `operator` varchar(35) NOT NULL,
  `value` varchar(250) NOT NULL,
  `intra_condition_operator` enum('AND','OR') DEFAULT NULL,
  `value_type` enum('V','T') NOT NULL DEFAULT 'V',
  `target_func` varchar(20) DEFAULT NULL,
  `source_func` varchar(20) DEFAULT NULL,
  `source_params` varchar(100) DEFAULT NULL,
  `target_params` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_conditions`
--

LOCK TABLES `expert_system_conditions` WRITE;
/*!40000 ALTER TABLE `expert_system_conditions` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_conditions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_html`
--

DROP TABLE IF EXISTS `expert_system_html`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_html` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) unsigned NOT NULL,
  `tag_type` varchar(15) NOT NULL,
  `tag_id` varchar(75) NOT NULL,
  `tag_name` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_html`
--

LOCK TABLES `expert_system_html` WRITE;
/*!40000 ALTER TABLE `expert_system_html` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_html` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_json`
--

DROP TABLE IF EXISTS `expert_system_json`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_json` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `screen_name` varchar(30) DEFAULT NULL,
  `json` longtext NOT NULL,
  `url` varchar(250) DEFAULT NULL,
  `destination_page` varchar(75) DEFAULT NULL,
  `status` int(1) DEFAULT 0,
  `last_backup` varchar(50) DEFAULT NULL,
  `script_file` varchar(30) DEFAULT NULL,
  `rules_script_file` varchar(30) DEFAULT NULL,
  `any_manual_changes` tinyint(4) NOT NULL DEFAULT 0,
  `ckeditor_page_id` varchar(10) DEFAULT NULL,
  `json_uuid` varchar(50) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_json`
--

LOCK TABLES `expert_system_json` WRITE;
/*!40000 ALTER TABLE `expert_system_json` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_json` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_queries`
--

DROP TABLE IF EXISTS `expert_system_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_queries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) NOT NULL,
  `query` mediumtext NOT NULL,
  `created_by` varchar(30) DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `query_type` enum('d3','c3','array','d3map','d3mapchl','array-with-labels') DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `is_requete_query` char(1) DEFAULT '0',
  `requete_query_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_queries`
--

LOCK TABLES `expert_system_queries` WRITE;
/*!40000 ALTER TABLE `expert_system_queries` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_query_params`
--

DROP TABLE IF EXISTS `expert_system_query_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_query_params` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) NOT NULL,
  `param` varchar(255) DEFAULT NULL,
  `default_value` varchar(75) DEFAULT NULL,
  `query_id` int(10) NOT NULL,
  `requete_column_value` varchar(100) DEFAULT NULL,
  `requete_column_operator` varchar(5) DEFAULT NULL,
  `requete_column_param` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_query_params`
--

LOCK TABLES `expert_system_query_params` WRITE;
/*!40000 ALTER TABLE `expert_system_query_params` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_query_params` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_reuse_json`
--

DROP TABLE IF EXISTS `expert_system_reuse_json`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_reuse_json` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) unsigned NOT NULL,
  `json_tag` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_reuse_json`
--

LOCK TABLES `expert_system_reuse_json` WRITE;
/*!40000 ALTER TABLE `expert_system_reuse_json` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_reuse_json` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_rules`
--

DROP TABLE IF EXISTS `expert_system_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_rules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) unsigned NOT NULL,
  `output_type` char(1) NOT NULL,
  `output_tag` varchar(100) NOT NULL,
  `output_val` longtext NOT NULL,
  `created_by` int(10) unsigned DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `html_tag_id` varchar(75) DEFAULT NULL,
  `exec_order` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_rules`
--

LOCK TABLES `expert_system_rules` WRITE;
/*!40000 ALTER TABLE `expert_system_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_system_script`
--

DROP TABLE IF EXISTS `expert_system_script`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expert_system_script` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `json_id` int(10) unsigned NOT NULL,
  `json_tag` varchar(75) NOT NULL,
  `parent_json_tag` varchar(75) DEFAULT NULL,
  `html_tag` varchar(75) DEFAULT NULL,
  `max_rows` int(10) DEFAULT NULL,
  `show_col` tinyint(1) DEFAULT 1,
  `col_header` varchar(100) DEFAULT NULL,
  `col_seq_num` int(10) DEFAULT NULL,
  `created_by` int(10) unsigned NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `script_file` varchar(30) DEFAULT NULL,
  `functions` varchar(250) DEFAULT NULL,
  `field_type` varchar(10) DEFAULT NULL,
  `field_name` varchar(50) DEFAULT NULL,
  `fill_from` varchar(50) DEFAULT NULL,
  `add_pagination` tinyint(1) DEFAULT 0,
  `col_header_css` varchar(75) DEFAULT NULL,
  `col_value_css` varchar(75) DEFAULT NULL,
  `d3chart` varchar(20) DEFAULT NULL,
  `c3chart` varchar(20) DEFAULT NULL,
  `xaxis` varchar(25) DEFAULT NULL,
  `xcols` varchar(50) DEFAULT NULL,
  `ycols` varchar(50) DEFAULT NULL,
  `c3col_graph_type` varchar(255) DEFAULT NULL,
  `c3_col_groups` varchar(255) DEFAULT NULL,
  `extra_fields` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_system_script`
--

LOCK TABLES `expert_system_script` WRITE;
/*!40000 ALTER TABLE `expert_system_script` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_system_script` ENABLE KEYS */;
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
-- Table structure for table `page_profil`
--

DROP TABLE IF EXISTS `page_profil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_profil` (
  `url` varchar(150) NOT NULL DEFAULT '',
  `profil_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`url`,`profil_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_profil`
--

LOCK TABLES `page_profil` WRITE;
/*!40000 ALTER TABLE `page_profil` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_profil` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `query_formats`
--

DROP TABLE IF EXISTS `query_formats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query_formats` (
  `id` int(11) NOT NULL,
  `type` varchar(32) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query_formats`
--

LOCK TABLES `query_formats` WRITE;
/*!40000 ALTER TABLE `query_formats` DISABLE KEYS */;
INSERT INTO `query_formats` VALUES (1,'JSON structure'),(2,'JSON array'),(3,'JSON array with labels'),(4,'C3'),(5,'D3'),(6,'D3Map'),(7,'D3MapChl');
/*!40000 ALTER TABLE `query_formats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `query_settings`
--

DROP TABLE IF EXISTS `query_settings`;
/*!50001 DROP VIEW IF EXISTS `query_settings`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `query_settings` (
  `qs_uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `query_id` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `access` tinyint NOT NULL,
  `query_key` tinyint NOT NULL,
  `query_format` tinyint NOT NULL,
  `paginate` tinyint NOT NULL,
  `items_per_page` tinyint NOT NULL,
  `query_type_id` tinyint NOT NULL,
  `query_sub_type_id` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `selected_columns` tinyint NOT NULL,
  `filter_settings` tinyint NOT NULL,
  `sorting_settings` tinyint NOT NULL,
  `column_settings` tinyint NOT NULL,
  `publish_ts` tinyint NOT NULL,
  `publish_status` tinyint NOT NULL,
  `published_by` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `query_settings_published`
--

DROP TABLE IF EXISTS `query_settings_published`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query_settings_published` (
  `qs_uuid` varchar(100) NOT NULL,
  `name` varchar(75) DEFAULT NULL,
  `query_id` varchar(75) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `access` enum('private','public') NOT NULL DEFAULT 'public',
  `query_key` varchar(32) DEFAULT NULL,
  `query_format` int(11) DEFAULT NULL,
  `paginate` tinyint(4) DEFAULT NULL,
  `items_per_page` int(11) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `query_sub_type_id` varchar(50) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `selected_columns` text DEFAULT NULL,
  `filter_settings` text DEFAULT NULL,
  `sorting_settings` text DEFAULT NULL,
  `column_settings` text DEFAULT NULL,
  `publish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  `published_by` int(11) DEFAULT NULL,
  `version` int(10) DEFAULT 1,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query_settings_published`
--

LOCK TABLES `query_settings_published` WRITE;
/*!40000 ALTER TABLE `query_settings_published` DISABLE KEYS */;
/*!40000 ALTER TABLE `query_settings_published` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `query_settings_tbl`
--

DROP TABLE IF EXISTS `query_settings_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query_settings_tbl` (
  `qs_uuid` varchar(100) NOT NULL,
  `name` varchar(75) DEFAULT NULL,
  `query_id` varchar(75) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `access` enum('private','public') NOT NULL DEFAULT 'public',
  `query_key` varchar(32) DEFAULT NULL,
  `query_format` int(11) DEFAULT NULL,
  `paginate` tinyint(4) DEFAULT NULL,
  `items_per_page` int(11) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `query_sub_type_id` varchar(50) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `selected_columns` text DEFAULT NULL,
  `filter_settings` text DEFAULT NULL,
  `sorting_settings` text DEFAULT NULL,
  `column_settings` text DEFAULT NULL,
  `publish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  `published_by` int(11) DEFAULT NULL,
  `version` int(10) DEFAULT 1,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`qs_uuid`),
  UNIQUE KEY `uidx1` (`site_id`,`query_id`,`is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query_settings_tbl`
--

LOCK TABLES `query_settings_tbl` WRITE;
/*!40000 ALTER TABLE `query_settings_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `query_settings_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `query_types`
--

DROP TABLE IF EXISTS `query_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_name` varchar(50) DEFAULT NULL,
  `query_type` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query_types`
--

LOCK TABLES `query_types` WRITE;
/*!40000 ALTER TABLE `query_types` DISABLE KEYS */;
INSERT INTO `query_types` VALUES (1,'products','Commercial catalog'),(2,'structured_page','Structured page'),(3,'structured_content','Structured Content'),(4,'pages','Pages'),(5,'blocs','Blocs'),(8,'stores','Stores'),(7,'forms','Forms'),(9,'subsidies','Subsidies'),(10,'deliveryfees','Delivery Fee');
/*!40000 ALTER TABLE `query_types` ENABLE KEYS */;
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
  `siren` varchar(50) DEFAULT NULL,
  `imei` varchar(100) DEFAULT NULL,
  `activity_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `user_agent` text DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `siren_type` char(1) DEFAULT NULL,
  `marche` varchar(255) DEFAULT NULL
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
-- Final view structure for view `query_settings`
--

/*!50001 DROP TABLE IF EXISTS `query_settings`*/;
/*!50001 DROP VIEW IF EXISTS `query_settings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `query_settings` AS select `query_settings_tbl`.`qs_uuid` AS `qs_uuid`,`query_settings_tbl`.`name` AS `name`,`query_settings_tbl`.`query_id` AS `query_id`,`query_settings_tbl`.`site_id` AS `site_id`,`query_settings_tbl`.`access` AS `access`,`query_settings_tbl`.`query_key` AS `query_key`,`query_settings_tbl`.`query_format` AS `query_format`,`query_settings_tbl`.`paginate` AS `paginate`,`query_settings_tbl`.`items_per_page` AS `items_per_page`,`query_settings_tbl`.`query_type_id` AS `query_type_id`,`query_settings_tbl`.`query_sub_type_id` AS `query_sub_type_id`,`query_settings_tbl`.`created_by` AS `created_by`,`query_settings_tbl`.`created_on` AS `created_on`,`query_settings_tbl`.`updated_by` AS `updated_by`,`query_settings_tbl`.`updated_on` AS `updated_on`,`query_settings_tbl`.`selected_columns` AS `selected_columns`,`query_settings_tbl`.`filter_settings` AS `filter_settings`,`query_settings_tbl`.`sorting_settings` AS `sorting_settings`,`query_settings_tbl`.`column_settings` AS `column_settings`,`query_settings_tbl`.`publish_ts` AS `publish_ts`,`query_settings_tbl`.`publish_status` AS `publish_status`,`query_settings_tbl`.`published_by` AS `published_by`,`query_settings_tbl`.`version` AS `version`,`query_settings_tbl`.`is_deleted` AS `is_deleted` from `query_settings_tbl` where `query_settings_tbl`.`is_deleted` = 0 */;
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

-- Dump completed on 2024-12-05 20:21:38
