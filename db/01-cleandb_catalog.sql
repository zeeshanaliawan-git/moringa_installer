-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_catalog
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
INSERT INTO `actions` VALUES ('shell',NULL,NULL,'Shell'),('sql',NULL,NULL,'Sql'),('publish',NULL,NULL,'Publish'),('remove',NULL,NULL,'Remove'),('publishorder',NULL,NULL,'PublishOrdering');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `additionalfee_rules`
--

DROP TABLE IF EXISTS `additionalfee_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additionalfee_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `add_fee_id` int(11) NOT NULL,
  `rule_apply` varchar(50) DEFAULT NULL,
  `rule_apply_value` varchar(50) DEFAULT NULL,
  `element_type` varchar(50) DEFAULT NULL,
  `element_type_value` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `additionalfee_rules`
--

LOCK TABLES `additionalfee_rules` WRITE;
/*!40000 ALTER TABLE `additionalfee_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `additionalfee_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `additionalfees`
--

DROP TABLE IF EXISTS `additionalfees`;
/*!50001 DROP VIEW IF EXISTS `additionalfees`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `additionalfees` (
  `id` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `additional_fee` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `additionalfees_tbl`
--

DROP TABLE IF EXISTS `additionalfees_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additionalfees_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `additional_fee` varchar(255) DEFAULT NULL,
  `lang_1_description` text DEFAULT NULL,
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `additionalfees_tbl`
--

LOCK TABLES `additionalfees_tbl` WRITE;
/*!40000 ALTER TABLE `additionalfees_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `additionalfees_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `algolia_default_index`
--

DROP TABLE IF EXISTS `algolia_default_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `algolia_default_index` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `index_name` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `algolia_default_index`
--

LOCK TABLES `algolia_default_index` WRITE;
/*!40000 ALTER TABLE `algolia_default_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `algolia_default_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `algolia_indexes`
--

DROP TABLE IF EXISTS `algolia_indexes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `algolia_indexes` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `index_type` varchar(75) NOT NULL,
  `index_name` varchar(255) NOT NULL,
  `algolia_index` varchar(255) NOT NULL,
  `test_algolia_index` varchar(255) NOT NULL,
  `order_seq` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`,`langue_id`,`index_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `algolia_indexes`
--

LOCK TABLES `algolia_indexes` WRITE;
/*!40000 ALTER TABLE `algolia_indexes` DISABLE KEYS */;
/*!40000 ALTER TABLE `algolia_indexes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `algolia_rules`
--

DROP TABLE IF EXISTS `algolia_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `algolia_rules` (
  `site_id` int(11) NOT NULL,
  `langue_id` int(1) NOT NULL,
  `rule_type` varchar(75) NOT NULL,
  `rule_criteria` varchar(30) NOT NULL,
  `rule_value` varchar(255) NOT NULL,
  `index_name` varchar(255) NOT NULL,
  `exclude_from_default` tinyint(1) NOT NULL DEFAULT 0,
  `order_seq` int(10) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `algolia_rules`
--

LOCK TABLES `algolia_rules` WRITE;
/*!40000 ALTER TABLE `algolia_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `algolia_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `algolia_settings`
--

DROP TABLE IF EXISTS `algolia_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `algolia_settings` (
  `site_id` int(11) NOT NULL,
  `activated` tinyint(1) NOT NULL DEFAULT 0,
  `application_id` varchar(255) DEFAULT NULL,
  `search_api_key` varchar(255) DEFAULT NULL,
  `write_api_key` varchar(255) DEFAULT NULL,
  `exclude_noindex` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `test_application_id` varchar(255) DEFAULT NULL,
  `test_search_api_key` varchar(255) DEFAULT NULL,
  `test_write_api_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `algolia_settings`
--

LOCK TABLES `algolia_settings` WRITE;
/*!40000 ALTER TABLE `algolia_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `algolia_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `all_delivery_methods`
--

DROP TABLE IF EXISTS `all_delivery_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `all_delivery_methods` (
  `method` varchar(25) NOT NULL DEFAULT '',
  `displayName` varchar(50) DEFAULT NULL,
  `helpText` text DEFAULT NULL,
  PRIMARY KEY (`method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `all_delivery_methods`
--

LOCK TABLES `all_delivery_methods` WRITE;
/*!40000 ALTER TABLE `all_delivery_methods` DISABLE KEYS */;
INSERT INTO `all_delivery_methods` VALUES ('home_delivery','Livraison ',''),('pick_up_in_store','Livraison en agence',''),('pick_up_in_package_point','Livraison point relais','');
/*!40000 ALTER TABLE `all_delivery_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `all_payment_methods`
--

DROP TABLE IF EXISTS `all_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `all_payment_methods` (
  `method` varchar(25) NOT NULL DEFAULT '',
  `displayName` varchar(50) DEFAULT NULL,
  `helpText` text DEFAULT NULL,
  `subText` text DEFAULT NULL,
  `test_redirect_url` varchar(255) DEFAULT NULL,
  `prod_redirect_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `all_payment_methods`
--

LOCK TABLES `all_payment_methods` WRITE;
/*!40000 ALTER TABLE `all_payment_methods` DISABLE KEYS */;
INSERT INTO `all_payment_methods` VALUES ('credit_card','Carte bancaire','','','/cleandb_portal/cart/paymentPageCredit.jsp','/cleandb_prodportal/cart/paymentPageCredit.jsp'),('cash_on_pickup','Paiement en agence','','','/cleandb_portal/cart/completion.jsp','/cleandb_prodportal/cart/completion.jsp'),('cash_on_delivery','Paiement au retrait','','','/cleandb_portal/cart/completion.jsp','/cleandb_prodportal/cart/completion.jsp'),('orange_money','Orange Money','','','/cleandb_portal/cart/paymentPage.jsp','/cleandb_prodportal/cart/paymentPage.jsp'),('paypal','Paypal','','','/cleandb_portal/cart/paymentPagePaypal.jsp','/cleandb_prodportal/cart/paymentPagePaypal.jsp'),('orange_money_obf','Orange Money OBF',NULL,NULL,'/cleandb_portal/cart/paymentPageOrange.jsp','/cleandb_prodportal/cart/paymentPageOrange.jsp');
/*!40000 ALTER TABLE `all_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attributes_v2`
--

DROP TABLE IF EXISTS `attributes_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attributes_v2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(150) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'text',
  `site_id` int(11) NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `unit` varchar(255) DEFAULT '',
  `icon` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_site` (`name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attributes_v2`
--

LOCK TABLES `attributes_v2` WRITE;
/*!40000 ALTER TABLE `attributes_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `attributes_v2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attributes_values_v2`
--

DROP TABLE IF EXISTS `attributes_values_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attributes_values_v2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(100) NOT NULL,
  `value` varchar(100) NOT NULL,
  `attr_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attributes_values_v2`
--

LOCK TABLES `attributes_values_v2` WRITE;
/*!40000 ALTER TABLE `attributes_values_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `attributes_values_v2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backups`
--

DROP TABLE IF EXISTS `backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backups` (
  `file_prefix` varchar(20) NOT NULL,
  `started_on` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups`
--

LOCK TABLES `backups` WRITE;
/*!40000 ALTER TABLE `backups` DISABLE KEYS */;
/*!40000 ALTER TABLE `backups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `cart_promotion`
--

DROP TABLE IF EXISTS `cart_promotion`;
/*!50001 DROP VIEW IF EXISTS `cart_promotion`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `cart_promotion` (
  `id` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `auto_generate_cc` tinyint NOT NULL,
  `uses_per_coupon` tinyint NOT NULL,
  `uses_per_customer` tinyint NOT NULL,
  `coupon_quantity` tinyint NOT NULL,
  `cc_length` tinyint NOT NULL,
  `cc_prefix` tinyint NOT NULL,
  `rule_field` tinyint NOT NULL,
  `rule_type` tinyint NOT NULL,
  `verify_condition` tinyint NOT NULL,
  `rule_condition` tinyint NOT NULL,
  `rule_condition_value` tinyint NOT NULL,
  `discount_type` tinyint NOT NULL,
  `discount_value` tinyint NOT NULL,
  `element_on` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cart_promotion_coupon`
--

DROP TABLE IF EXISTS `cart_promotion_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_promotion_coupon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cp_id` int(11) NOT NULL,
  `coupon_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_promotion_coupon`
--

LOCK TABLES `cart_promotion_coupon` WRITE;
/*!40000 ALTER TABLE `cart_promotion_coupon` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_promotion_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_promotion_on_elements`
--

DROP TABLE IF EXISTS `cart_promotion_on_elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_promotion_on_elements` (
  `cart_promo_id` int(11) NOT NULL,
  `element_on` varchar(20) NOT NULL,
  `element_on_value` varchar(255) NOT NULL,
  PRIMARY KEY (`cart_promo_id`,`element_on`,`element_on_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_promotion_on_elements`
--

LOCK TABLES `cart_promotion_on_elements` WRITE;
/*!40000 ALTER TABLE `cart_promotion_on_elements` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_promotion_on_elements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_promotion_tbl`
--

DROP TABLE IF EXISTS `cart_promotion_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_promotion_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `auto_generate_cc` tinyint(1) NOT NULL DEFAULT 0,
  `uses_per_coupon` int(10) DEFAULT NULL,
  `uses_per_customer` int(10) DEFAULT NULL,
  `coupon_quantity` int(10) DEFAULT NULL,
  `cc_length` int(10) DEFAULT NULL,
  `cc_prefix` varchar(50) DEFAULT NULL,
  `rule_field` tinyint(1) NOT NULL DEFAULT 0,
  `rule_type` varchar(25) DEFAULT NULL,
  `verify_condition` varchar(25) DEFAULT NULL,
  `rule_condition` varchar(12) DEFAULT NULL,
  `rule_condition_value` varchar(255) DEFAULT NULL,
  `discount_type` varchar(10) NOT NULL,
  `discount_value` varchar(10) NOT NULL,
  `element_on` varchar(20) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_promotion_tbl`
--

LOCK TABLES `cart_promotion_tbl` WRITE;
/*!40000 ALTER TABLE `cart_promotion_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_promotion_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_attribute_values`
--

DROP TABLE IF EXISTS `catalog_attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_attribute_values` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cat_attrib_id` int(11) NOT NULL,
  `attribute_value` varchar(255) NOT NULL,
  `small_text` varchar(100) NOT NULL DEFAULT '',
  `color` varchar(50) NOT NULL DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cat_attribute_value` (`cat_attrib_id`,`attribute_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_attribute_values`
--

LOCK TABLES `catalog_attribute_values` WRITE;
/*!40000 ALTER TABLE `catalog_attribute_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalog_attribute_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_attributes`
--

DROP TABLE IF EXISTS `catalog_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_attributes` (
  `cat_attrib_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `visible_to` enum('all','logged_customer','backoffice') NOT NULL DEFAULT 'all',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `type` enum('selection','specs') NOT NULL DEFAULT 'selection',
  `detail_only` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1= show on detail page only',
  `migration_name` varchar(500) NOT NULL DEFAULT '' COMMENT 'used by device data migration',
  `is_searchable` tinyint(1) NOT NULL DEFAULT 0,
  `value_type` enum('text','color','select') NOT NULL DEFAULT 'text',
  `is_fixed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'cannot update or delete this attribute',
  PRIMARY KEY (`cat_attrib_id`),
  UNIQUE KEY `uk_catalog_attrib_name_type` (`catalog_id`,`name`,`type`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_attributes`
--

LOCK TABLES `catalog_attributes` WRITE;
/*!40000 ALTER TABLE `catalog_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalog_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_descriptions`
--

DROP TABLE IF EXISTS `catalog_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_descriptions` (
  `catalog_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `canonical_url` varchar(1000) NOT NULL DEFAULT '',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  `folder_name` varchar(255) DEFAULT NULL COMMENT 'This name will be used for default path for products in a catalog',
  `top_banner_path_opentype` varchar(30) DEFAULT 'same_window',
  `bottom_banner_path_opentype` varchar(30) DEFAULT 'same_window',
  `page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`catalog_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_descriptions`
--

LOCK TABLES `catalog_descriptions` WRITE;
/*!40000 ALTER TABLE `catalog_descriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalog_descriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_essential_blocks`
--

DROP TABLE IF EXISTS `catalog_essential_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_essential_blocks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `block_text` varchar(4000) NOT NULL,
  `file_name` varchar(500) DEFAULT NULL,
  `actual_file_name` varchar(500) CHARACTER SET latin1 DEFAULT NULL,
  `image_label` varchar(100) DEFAULT NULL,
  `order_seq` int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_essential_blocks`
--

LOCK TABLES `catalog_essential_blocks` WRITE;
/*!40000 ALTER TABLE `catalog_essential_blocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalog_essential_blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_tags`
--

DROP TABLE IF EXISTS `catalog_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_tags` (
  `catalog_id` int(11) NOT NULL,
  `tag_id` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`catalog_id`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_tags`
--

LOCK TABLES `catalog_tags` WRITE;
/*!40000 ALTER TABLE `catalog_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalog_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_types`
--

DROP TABLE IF EXISTS `catalog_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_types` (
  `name` varchar(50) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `product_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_types`
--

LOCK TABLES `catalog_types` WRITE;
/*!40000 ALTER TABLE `catalog_types` DISABLE KEYS */;
INSERT INTO `catalog_types` VALUES ('Accessories','accessory','product'),('Devices','device','product'),('Offers','offer','offer_prepaid,offer_postpaid'),('Products','product','product');
/*!40000 ALTER TABLE `catalog_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `catalog_types_all`
--

DROP TABLE IF EXISTS `catalog_types_all`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalog_types_all` (
  `name` varchar(50) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  `product_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalog_types_all`
--

LOCK TABLES `catalog_types_all` WRITE;
/*!40000 ALTER TABLE `catalog_types_all` DISABLE KEYS */;
INSERT INTO `catalog_types_all` VALUES ('Accessories','accessory','product'),('Devices','device','product'),('Offers','offer','offer_prepaid,offer_postpaid'),('Products','product','product');
/*!40000 ALTER TABLE `catalog_types_all` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `catalogs`
--

DROP TABLE IF EXISTS `catalogs`;
/*!50001 DROP VIEW IF EXISTS `catalogs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `catalogs` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `catalog_uuid` tinyint NOT NULL,
  `lang_1_heading` tinyint NOT NULL,
  `lang_2_heading` tinyint NOT NULL,
  `lang_3_heading` tinyint NOT NULL,
  `lang_4_heading` tinyint NOT NULL,
  `lang_5_heading` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `lang_1_details_heading` tinyint NOT NULL,
  `lang_2_details_heading` tinyint NOT NULL,
  `lang_3_details_heading` tinyint NOT NULL,
  `lang_4_details_heading` tinyint NOT NULL,
  `lang_5_details_heading` tinyint NOT NULL,
  `product_types_custom` tinyint NOT NULL,
  `is_special` tinyint NOT NULL,
  `lang_1_price_formatter` tinyint NOT NULL,
  `lang_2_price_formatter` tinyint NOT NULL,
  `lang_3_price_formatter` tinyint NOT NULL,
  `lang_4_price_formatter` tinyint NOT NULL,
  `lang_5_price_formatter` tinyint NOT NULL,
  `lang_1_currency` tinyint NOT NULL,
  `lang_2_currency` tinyint NOT NULL,
  `lang_3_currency` tinyint NOT NULL,
  `lang_4_currency` tinyint NOT NULL,
  `lang_5_currency` tinyint NOT NULL,
  `lang_1_round_to_decimals` tinyint NOT NULL,
  `lang_2_round_to_decimals` tinyint NOT NULL,
  `lang_3_round_to_decimals` tinyint NOT NULL,
  `lang_4_round_to_decimals` tinyint NOT NULL,
  `lang_5_round_to_decimals` tinyint NOT NULL,
  `lang_1_show_decimals` tinyint NOT NULL,
  `lang_2_show_decimals` tinyint NOT NULL,
  `lang_3_show_decimals` tinyint NOT NULL,
  `lang_4_show_decimals` tinyint NOT NULL,
  `lang_5_show_decimals` tinyint NOT NULL,
  `cart_url` tinyint NOT NULL,
  `cart_prod_url` tinyint NOT NULL,
  `cart_url_params` tinyint NOT NULL,
  `store_locator_url` tinyint NOT NULL,
  `store_locator_prod_url` tinyint NOT NULL,
  `store_locator_url_params` tinyint NOT NULL,
  `lang_1_hub_page_heading` tinyint NOT NULL,
  `lang_2_hub_page_heading` tinyint NOT NULL,
  `lang_3_hub_page_heading` tinyint NOT NULL,
  `lang_4_hub_page_heading` tinyint NOT NULL,
  `lang_5_hub_page_heading` tinyint NOT NULL,
  `lang_1_top_banner_path` tinyint NOT NULL,
  `topban_product_list` tinyint NOT NULL,
  `topban_product_detail` tinyint NOT NULL,
  `topban_hub` tinyint NOT NULL,
  `lang_2_top_banner_path` tinyint NOT NULL,
  `lang_3_top_banner_path` tinyint NOT NULL,
  `lang_4_top_banner_path` tinyint NOT NULL,
  `lang_5_top_banner_path` tinyint NOT NULL,
  `lang_1_bottom_banner_path` tinyint NOT NULL,
  `bottomban_product_list` tinyint NOT NULL,
  `bottomban_product_detail` tinyint NOT NULL,
  `bottomban_hub` tinyint NOT NULL,
  `lang_2_bottom_banner_path` tinyint NOT NULL,
  `lang_3_bottom_banner_path` tinyint NOT NULL,
  `lang_4_bottom_banner_path` tinyint NOT NULL,
  `lang_5_bottom_banner_path` tinyint NOT NULL,
  `hub_page_orientation` tinyint NOT NULL,
  `view_name` tinyint NOT NULL,
  `lang_1_meta_keywords` tinyint NOT NULL,
  `lang_2_meta_keywords` tinyint NOT NULL,
  `lang_3_meta_keywords` tinyint NOT NULL,
  `lang_4_meta_keywords` tinyint NOT NULL,
  `lang_5_meta_keywords` tinyint NOT NULL,
  `lang_1_meta_description` tinyint NOT NULL,
  `lang_2_meta_description` tinyint NOT NULL,
  `lang_3_meta_description` tinyint NOT NULL,
  `lang_4_meta_description` tinyint NOT NULL,
  `lang_5_meta_description` tinyint NOT NULL,
  `invoice_nature` tinyint NOT NULL,
  `manufacturers` tinyint NOT NULL,
  `price_tax_included` tinyint NOT NULL,
  `catalog_type` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `tax_percentage` tinyint NOT NULL,
  `show_amount_tax_included` tinyint NOT NULL,
  `essentials_alignment_lang_1` tinyint NOT NULL,
  `essentials_alignment_lang_2` tinyint NOT NULL,
  `essentials_alignment_lang_3` tinyint NOT NULL,
  `essentials_alignment_lang_4` tinyint NOT NULL,
  `essentials_alignment_lang_5` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `buy_status` tinyint NOT NULL,
  `default_sort` tinyint NOT NULL,
  `html_variant` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `catalog_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `catalogs_tbl`
--

DROP TABLE IF EXISTS `catalogs_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalogs_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `catalog_uuid` varchar(36) DEFAULT uuid(),
  `lang_1_heading` varchar(255) DEFAULT NULL,
  `lang_2_heading` varchar(255) DEFAULT NULL,
  `lang_3_heading` varchar(255) DEFAULT NULL,
  `lang_4_heading` varchar(255) DEFAULT NULL,
  `lang_5_heading` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `lang_1_details_heading` varchar(255) DEFAULT NULL,
  `lang_2_details_heading` varchar(255) DEFAULT NULL,
  `lang_3_details_heading` varchar(255) DEFAULT NULL,
  `lang_4_details_heading` varchar(255) DEFAULT NULL,
  `lang_5_details_heading` varchar(255) DEFAULT NULL,
  `product_types_custom` text DEFAULT NULL COMMENT 'comma-seperated custom product types for this catalog',
  `is_special` tinyint(1) NOT NULL DEFAULT 0,
  `lang_1_price_formatter` varchar(25) DEFAULT NULL,
  `lang_2_price_formatter` varchar(25) DEFAULT NULL,
  `lang_3_price_formatter` varchar(25) DEFAULT NULL,
  `lang_4_price_formatter` varchar(25) DEFAULT NULL,
  `lang_5_price_formatter` varchar(25) DEFAULT NULL,
  `lang_1_currency` varchar(25) DEFAULT NULL,
  `lang_2_currency` varchar(25) DEFAULT NULL,
  `lang_3_currency` varchar(25) DEFAULT NULL,
  `lang_4_currency` varchar(25) DEFAULT NULL,
  `lang_5_currency` varchar(25) DEFAULT NULL,
  `lang_1_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_2_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_3_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_4_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_5_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_1_show_decimals` varchar(1) DEFAULT NULL,
  `lang_2_show_decimals` varchar(1) DEFAULT NULL,
  `lang_3_show_decimals` varchar(1) DEFAULT NULL,
  `lang_4_show_decimals` varchar(1) DEFAULT NULL,
  `lang_5_show_decimals` varchar(1) DEFAULT NULL,
  `cart_url` text DEFAULT NULL,
  `cart_prod_url` text DEFAULT NULL,
  `cart_url_params` text DEFAULT NULL,
  `store_locator_url` text DEFAULT NULL,
  `store_locator_prod_url` text DEFAULT NULL,
  `store_locator_url_params` text DEFAULT NULL,
  `lang_1_hub_page_heading` varchar(255) DEFAULT NULL,
  `lang_2_hub_page_heading` varchar(255) DEFAULT NULL,
  `lang_3_hub_page_heading` varchar(255) DEFAULT NULL,
  `lang_4_hub_page_heading` varchar(255) DEFAULT NULL,
  `lang_5_hub_page_heading` varchar(255) DEFAULT NULL,
  `lang_1_top_banner_path` varchar(255) DEFAULT NULL,
  `topban_product_list` char(1) DEFAULT '0',
  `topban_product_detail` char(1) DEFAULT '0',
  `topban_hub` char(1) DEFAULT '0',
  `lang_2_top_banner_path` varchar(255) DEFAULT NULL,
  `lang_3_top_banner_path` varchar(255) DEFAULT NULL,
  `lang_4_top_banner_path` varchar(255) DEFAULT NULL,
  `lang_5_top_banner_path` varchar(255) DEFAULT NULL,
  `lang_1_bottom_banner_path` varchar(255) DEFAULT NULL,
  `bottomban_product_list` char(1) DEFAULT '0',
  `bottomban_product_detail` char(1) DEFAULT '0',
  `bottomban_hub` char(1) DEFAULT '0',
  `lang_2_bottom_banner_path` varchar(255) DEFAULT NULL,
  `lang_3_bottom_banner_path` varchar(255) DEFAULT NULL,
  `lang_4_bottom_banner_path` varchar(255) DEFAULT NULL,
  `lang_5_bottom_banner_path` varchar(255) DEFAULT NULL,
  `hub_page_orientation` varchar(50) DEFAULT NULL,
  `view_name` varchar(50) DEFAULT NULL,
  `lang_1_meta_keywords` text DEFAULT NULL,
  `lang_2_meta_keywords` text DEFAULT NULL,
  `lang_3_meta_keywords` text DEFAULT NULL,
  `lang_4_meta_keywords` text DEFAULT NULL,
  `lang_5_meta_keywords` text DEFAULT NULL,
  `lang_1_meta_description` text DEFAULT NULL,
  `lang_2_meta_description` text DEFAULT NULL,
  `lang_3_meta_description` text DEFAULT NULL,
  `lang_4_meta_description` text DEFAULT NULL,
  `lang_5_meta_description` text DEFAULT NULL,
  `invoice_nature` varchar(100) NOT NULL DEFAULT '',
  `manufacturers` text DEFAULT NULL,
  `price_tax_included` tinyint(1) NOT NULL DEFAULT 0,
  `catalog_type` varchar(30) NOT NULL DEFAULT 'product',
  `site_id` int(11) NOT NULL DEFAULT 0,
  `tax_percentage` varchar(10) DEFAULT NULL,
  `show_amount_tax_included` tinyint(1) NOT NULL DEFAULT 1,
  `essentials_alignment_lang_1` varchar(100) NOT NULL DEFAULT '' COMMENT 'comes from constants in cleandb_common',
  `essentials_alignment_lang_2` varchar(100) NOT NULL DEFAULT '',
  `essentials_alignment_lang_3` varchar(100) NOT NULL DEFAULT '',
  `essentials_alignment_lang_4` varchar(100) NOT NULL DEFAULT '',
  `essentials_alignment_lang_5` varchar(100) NOT NULL DEFAULT '',
  `version` int(10) NOT NULL DEFAULT 1,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT '',
  `lang_3_description` text DEFAULT '',
  `lang_4_description` text DEFAULT '',
  `lang_5_description` text DEFAULT '',
  `buy_status` enum('all','logged') DEFAULT 'all',
  `default_sort` varchar(15) DEFAULT 'promotion',
  `html_variant` enum('all','anonymous','logged') NOT NULL DEFAULT 'all',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `catalog_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id_name` (`is_deleted`,`site_id`,`name`),
  UNIQUE KEY `site_id_uuid` (`site_id`,`catalog_uuid`,`is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalogs_tbl`
--

LOCK TABLES `catalogs_tbl` WRITE;
/*!40000 ALTER TABLE `catalogs_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalogs_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories_v2`
--

DROP TABLE IF EXISTS `categories_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories_v2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(150) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 0,
  `parent_id` int(11) DEFAULT 0,
  `site_id` int(11) NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_site` (`name`,`site_id`,`parent_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories_v2`
--

LOCK TABLES `categories_v2` WRITE;
/*!40000 ALTER TABLE `categories_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories_v2` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `check_rights` VALUES ('/asimina_catalog/admin/accessories.jsp'),('/asimina_catalog/admin/libmsgs.jsp'),('/asimina_catalog/admin/listpublish.jsp'),('/asimina_catalog/admin/listtarifs.jsp'),('/asimina_catalog/admin/manageProfil.jsp'),('/asimina_catalog/admin/menus.jsp'),('/asimina_catalog/admin/mobiles.jsp'),('/asimina_catalog/admin/mobiles_order.jsp'),('/asimina_catalog/admin/preprodcache.jsp'),('/asimina_catalog/admin/preprodstats.jsp'),('/asimina_catalog/admin/prodcache.jsp'),('/asimina_catalog/admin/prodlibmsgs.jsp'),('/asimina_catalog/admin/prodlisttarifs.jsp'),('/asimina_catalog/admin/prodstats.jsp'),('/asimina_catalog/admin/prod_accessories.jsp'),('/asimina_catalog/admin/prod_mobiles.jsp'),('/asimina_catalog/admin/userManagement.jsp');
/*!40000 ALTER TABLE `check_rights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `comewiths`
--

DROP TABLE IF EXISTS `comewiths`;
/*!50001 DROP VIEW IF EXISTS `comewiths`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `comewiths` (
  `id` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `comewith` tinyint NOT NULL,
  `type` tinyint NOT NULL,
  `applied_to_type` tinyint NOT NULL,
  `applied_to_value` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `variant_type` tinyint NOT NULL,
  `frequency` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `price_difference` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `comewiths_rules`
--

DROP TABLE IF EXISTS `comewiths_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comewiths_rules` (
  `comewith_id` int(11) NOT NULL,
  `associated_to_type` varchar(50) DEFAULT NULL,
  `associated_to_value` varchar(255) DEFAULT NULL,
  UNIQUE KEY `comewith_id` (`comewith_id`,`associated_to_type`,`associated_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comewiths_rules`
--

LOCK TABLES `comewiths_rules` WRITE;
/*!40000 ALTER TABLE `comewiths_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `comewiths_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comewiths_tbl`
--

DROP TABLE IF EXISTS `comewiths_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comewiths_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lang_1_description` text DEFAULT NULL,
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `comewith` varchar(50) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `applied_to_type` varchar(50) DEFAULT NULL,
  `applied_to_value` varchar(255) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `variant_type` varchar(10) DEFAULT NULL,
  `frequency` varchar(10) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `price_difference` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comewiths_tbl`
--

LOCK TABLES `comewiths_tbl` WRITE;
/*!40000 ALTER TABLE `comewiths_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `comewiths_tbl` ENABLE KEYS */;
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
INSERT INTO `config` VALUES ('CART_COOKIE','asimina_catalogCartItems',NULL),('CART_URL','/asimina_portal/',NULL),('CATALOG_ESSENTIALS_IMG_PATH','/asimina_catalog/uploads/catalogs/essentials/',NULL),('CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/catalogs/essentials/',NULL),('CATALOG_EXTERNAL_URL','/asimina_catalog/',NULL),('CATALOG_INTERNAL_LINK','http://127.0.0.1/asimina_catalog/',NULL),('CATAPULTE_DB','cleandb_catapulte',NULL),('CKEDITOR_APP_URL','/asimina_ckeditor/',NULL),('CKEDITOR_DB','cleandb_ckeditor',NULL),('CKEDITOR_DOWNLOAD_PAGES_FOLDER','sites/',NULL),('CKEDITOR_URL','http://127.0.0.1/asimina_ckeditor/',NULL),('COMMONS_DB','cleandb_commons',NULL),('COPY_PRODUCT_COMMENTS','0','If we want comments added in test site by admins to be moved to prod at time of publish set this to 1'),('DB_NAME','cleandb_catalog',NULL),('DEBUG','Oui',''),('EXPERT_SYSTEM_APP_URL','/asimina_expert_system/',NULL),('EXTERNAL_CATALOG_LINK','/asimina_catalog/',NULL),('FAMILIE_IMAGES_PATH','/asimina_catalog/uploads/familie/',NULL),('FAMILIE_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/familie/',NULL),('INTERNAL_LINK_BLOG_ARTICLE_PAGE','http://127.0.0.1/asimina_ckeditor/blogViewer.jsp',NULL),('INTERNAL_LINK_BLOG_MAIN_PAGE','http://127.0.0.1/asimina_ckeditor/blogFrontPage.jsp',NULL),('INTERNAL_LINK_FORMS_MAIN_PAGE','http://127.0.0.1/asimina_forms/forms.jsp',NULL),('INTERNAL_LINK_HUB_PREPROD','http://127.0.0.1/asimina_catalog/hub.jsp',NULL),('INTERNAL_LINK_HUB_PROD','http://127.0.0.1/asimina_prodcatalog/hub.jsp',NULL),('INTERNAL_LINK_LANDINGPAGE_PREPROD','http://127.0.0.1/asimina_catalog/landingpage.jsp',NULL),('INTERNAL_LINK_LANDINGPAGE_PROD','http://127.0.0.1/asimina_prodcatalog/landingpage.jsp',NULL),('INTERNAL_LINK_PRODUCTS_PREPROD','http://127.0.0.1/asimina_catalog/listproducts.jsp',NULL),('INTERNAL_LINK_PRODUCTS_PROD','http://127.0.0.1/asimina_prodcatalog/listproducts.jsp',NULL),('INTERNAL_LINK_PRODUCT_ITEM_PREPROD','http://127.0.0.1/asimina_catalog/product.jsp',NULL),('INTERNAL_LINK_PRODUCT_ITEM_PROD','http://127.0.0.1/asimina_prodcatalog/product.jsp',NULL),('IS_PROD_ENVIRONMENT','0',NULL),('LANDINGPAGE_IMAGES_PATH','/asimina_catalog/uploads/landingpage/',NULL),('LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/landingpage/',NULL),('max_catalogs_folder_level','4',NULL),('max_category_level','5',NULL),('MENU_DESIGNER_URL','/asimina_menu/',NULL),('PORTAL_DB','cleandb_portal',NULL),('PORTAL_PROD_DB','cleandb_prod_portal',NULL),('PORTAL_URL','/asimina_portal/',NULL),('PRODUCTS_IMG_PATH','/asimina_catalog/uploads/products/',NULL),('PRODUCTS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/products/',NULL),('PRODUCT_ESSENTIALS_IMG_PATH','/asimina_catalog/uploads/essentials/',NULL),('PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/essentials/',NULL),('PRODUCT_SHAREBAR_IMAGES_PATH','/asimina_catalog/uploads/sharebar/products/',NULL),('PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_catalog/uploads/sharebar/products/',NULL),('PROD_CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/catalogs/essentials/',''),('PROD_DB','cleandb_prod_catalog',NULL),('PROD_FAMILIE_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/familie/',NULL),('PROD_LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/landingpage/',NULL),('PROD_PORTAL_URL','/asimina_prodportal/',NULL),('PROD_PRODUCTS_IMG_PATH','/asimina_prodcatalog/uploads/products/',NULL),('PROD_PRODUCTS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/products/',NULL),('PROD_PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/essentials/',''),('PROD_PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/sharebar/products/',NULL),('SEMAPHORE','D001',NULL),('share_bar_twitter_bitly_token','',NULL),('SHELL_DIR','/home/asimina/pjt/asimina_engines/catalog/bin',''),('SHOP_DB','cleandb_shop',NULL),('SHOP_PROD_DB','cleandb_prod_shop',NULL),('SMART_BANNER_ICON_PATH','/home/asimina/tomcat/webapps/asimina_prodportal/img/smartbanner/',NULL),('SMART_BANNER_ICON_URL','/asimina_prodportal/img/smartbanner/',NULL),('sso_app_id','',NULL),('WAIT_TIMEOUT','300','');
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
INSERT INTO `coordinates` VALUES (10,10,584,500,'tarifs','ADMIN',NULL),(32,115,120,80,'tarifs','ADMIN','publish'),(343,114,120,80,'tarifs','ADMIN','published'),(343,114,120,80,'devices','ADMIN','published'),(32,115,120,80,'devices','ADMIN','publish'),(10,10,584,500,'devices','ADMIN',NULL),(10,10,584,500,'translations','ADMIN',NULL),(32,115,120,80,'translations','ADMIN','publish'),(343,114,120,80,'translations','ADMIN','published'),(43,284,120,80,'tarifs','ADMIN','delete'),(347,283,120,80,'tarifs','ADMIN','deleted'),(180,407,120,80,'tarifs','ADMIN','cancel'),(43,284,120,80,'devices','ADMIN','delete'),(347,283,120,80,'devices','ADMIN','deleted'),(204,400,120,80,'devices','ADMIN','cancel'),(10,10,584,500,'accessories','ADMIN',NULL),(32,115,120,80,'accessories','ADMIN','publish'),(343,114,120,80,'accessories','ADMIN','published'),(43,284,120,80,'accessories','ADMIN','delete'),(347,283,120,80,'accessories','ADMIN','deleted'),(141,400,147,98,'accessories','ADMIN','cancel'),(10,10,584,500,'faqs','ADMIN',NULL),(42,179,120,80,'faqs','ADMIN','publish'),(343,114,120,80,'faqs','ADMIN','published'),(43,284,120,80,'faqs','ADMIN','delete'),(347,283,120,80,'faqs','ADMIN','deleted'),(182,405,120,80,'faqs','ADMIN','cancel'),(620,10,300,500,'tarifs','PROD_SITE_ACCESS',NULL),(10,10,584,500,'catalogs','ADMIN',NULL),(32,115,120,80,'catalogs','ADMIN','publish'),(343,114,120,80,'catalogs','ADMIN','published'),(43,284,120,80,'catalogs','ADMIN','delete'),(347,283,120,80,'catalogs','ADMIN','deleted'),(180,407,120,80,'catalogs','ADMIN','cancel'),(620,10,300,500,'catalogs','PROD_SITE_ACCESS',NULL),(10,12,584,500,'products','ADMIN',NULL),(48,197,120,80,'products','ADMIN','publish'),(343,116,120,80,'products','ADMIN','published'),(43,286,120,80,'products','ADMIN','delete'),(347,285,120,80,'products','ADMIN','deleted'),(180,409,120,80,'products','ADMIN','cancel'),(620,10,300,500,'products','PROD_SITE_ACCESS',NULL),(10,10,584,500,'shop','ADMIN',NULL),(32,115,120,80,'shop','ADMIN','publish'),(351,99,120,110,'shop','ADMIN','published'),(325,540,300,500,'shop','PROD_CACHE_MGMT',NULL),(182,405,120,80,'shop','ADMIN','cancel'),(926,29,300,500,'catalogs','PROD_CACHE_MGMT',NULL),(582,534,300,500,'accessories','PROD_CACHE_MGMT',NULL),(924,18,300,500,'products','PROD_CACHE_MGMT',NULL),(51,64,120,80,'products','ADMIN','publish_ordering'),(579,528,300,500,'faqs','PROD_CACHE_MGMT',NULL),(36,57,120,80,'faqs','ADMIN','publish_ordering'),(10,10,584,500,'families','ADMIN',NULL),(42,179,120,80,'families','ADMIN','publish'),(343,114,120,80,'families','ADMIN','published'),(43,284,120,80,'families','ADMIN','delete'),(347,283,120,80,'families','ADMIN','deleted'),(182,405,120,80,'families','ADMIN','cancel'),(579,528,300,500,'families','PROD_CACHE_MGMT',NULL),(36,58,120,80,'families','ADMIN','publish_ordering'),(10,10,584,500,'resources','ADMIN',NULL),(32,115,120,80,'resources','ADMIN','publish'),(343,114,120,80,'resources','ADMIN','published'),(46,195,120,80,'landingpages','ADMIN','publish'),(9,11,584,500,'landingpages','ADMIN',NULL),(192,288,120,80,'resources','ADMIN','cancel'),(620,10,300,500,'resources','PROD_SITE_ACCESS',NULL),(926,29,300,500,'resources','PROD_CACHE_MGMT',NULL),(342,115,120,80,'landingpages','ADMIN','published'),(42,285,120,80,'landingpages','ADMIN','delete'),(346,284,120,80,'landingpages','ADMIN','deleted'),(179,408,120,80,'landingpages','ADMIN','cancel'),(620,10,300,500,'landingpages','PROD_SITE_ACCESS',NULL),(924,18,300,500,'landingpages','PROD_CACHE_MGMT',NULL),(10,10,584,500,'promotions','ADMIN',NULL),(48,195,120,80,'promotions','ADMIN','publish'),(343,114,120,80,'promotions','ADMIN','published'),(43,284,120,80,'promotions','ADMIN','delete'),(347,283,120,80,'promotions','ADMIN','deleted'),(180,407,120,80,'promotions','ADMIN','cancel'),(620,10,300,500,'promotions','PROD_SITE_ACCESS',NULL),(924,18,300,500,'promotions','PROD_CACHE_MGMT',NULL),(50,62,120,80,'promotions','ADMIN','publish_ordering'),(10,10,584,500,'cartrules','ADMIN',NULL),(48,195,120,80,'cartrules','ADMIN','publish'),(343,114,120,80,'cartrules','ADMIN','published'),(43,284,120,80,'cartrules','ADMIN','delete'),(347,283,120,80,'cartrules','ADMIN','deleted'),(180,407,120,80,'cartrules','ADMIN','cancel'),(620,10,300,500,'cartrules','PROD_SITE_ACCESS',NULL),(924,18,300,500,'cartrules','PROD_CACHE_MGMT',NULL),(50,62,120,80,'cartrules','ADMIN','publish_ordering'),(10,10,584,500,'additionalfees','ADMIN',NULL),(48,195,120,80,'additionalfees','ADMIN','publish'),(343,114,120,80,'additionalfees','ADMIN','published'),(43,284,120,80,'additionalfees','ADMIN','delete'),(347,283,120,80,'additionalfees','ADMIN','deleted'),(180,407,120,80,'additionalfees','ADMIN','cancel'),(620,10,300,500,'additionalfees','PROD_SITE_ACCESS',NULL),(924,18,300,500,'additionalfees','PROD_CACHE_MGMT',NULL),(50,62,120,80,'additionalfees','ADMIN','publish_ordering'),(10,10,584,500,'comewiths','ADMIN',NULL),(48,195,120,80,'comewiths','ADMIN','publish'),(343,114,120,80,'comewiths','ADMIN','published'),(43,284,120,80,'comewiths','ADMIN','delete'),(347,283,120,80,'comewiths','ADMIN','deleted'),(180,407,120,80,'comewiths','ADMIN','cancel'),(620,10,300,500,'comewiths','PROD_SITE_ACCESS',NULL),(924,18,300,500,'comewiths','PROD_CACHE_MGMT',NULL),(50,62,120,80,'comewiths','ADMIN','publish_ordering'),(10,10,584,500,'subsidies','ADMIN',NULL),(48,195,120,80,'subsidies','ADMIN','publish'),(343,114,120,80,'subsidies','ADMIN','published'),(43,284,120,80,'subsidies','ADMIN','delete'),(347,283,120,80,'subsidies','ADMIN','deleted'),(180,407,120,80,'subsidies','ADMIN','cancel'),(620,10,300,500,'subsidies','PROD_SITE_ACCESS',NULL),(924,18,300,500,'subsidies','PROD_CACHE_MGMT',NULL),(50,62,120,80,'subsidies','ADMIN','publish_ordering'),(10,10,584,500,'deliveryfees','ADMIN',NULL),(48,195,120,80,'deliveryfees','ADMIN','publish'),(343,114,120,80,'deliveryfees','ADMIN','published'),(43,284,120,80,'deliveryfees','ADMIN','delete'),(347,283,120,80,'deliveryfees','ADMIN','deleted'),(180,407,120,80,'deliveryfees','ADMIN','cancel'),(620,10,300,500,'deliveryfees','PROD_SITE_ACCESS',NULL),(924,18,300,500,'deliveryfees','PROD_CACHE_MGMT',NULL),(50,62,120,80,'deliveryfees','ADMIN','publish_ordering'),(10,10,584,500,'deliverymins','ADMIN',NULL),(48,195,120,80,'deliverymins','ADMIN','publish'),(343,114,120,80,'deliverymins','ADMIN','published'),(43,284,120,80,'deliverymins','ADMIN','delete'),(347,283,120,80,'deliverymins','ADMIN','deleted'),(180,407,120,80,'deliverymins','ADMIN','cancel'),(620,10,300,500,'deliverymins','PROD_SITE_ACCESS',NULL),(924,18,300,500,'deliverymins','PROD_CACHE_MGMT',NULL),(50,62,120,80,'deliverymins','ADMIN','publish_ordering'),(10,10,584,500,'deliveryfees','ADMIN',NULL),(48,195,120,80,'deliveryfees','ADMIN','publish'),(343,114,120,80,'deliveryfees','ADMIN','published'),(43,284,120,80,'deliveryfees','ADMIN','delete'),(347,283,120,80,'deliveryfees','ADMIN','deleted'),(180,407,120,80,'deliveryfees','ADMIN','cancel'),(620,10,300,500,'deliveryfees','PROD_SITE_ACCESS',NULL),(924,18,300,500,'deliveryfees','PROD_CACHE_MGMT',NULL),(50,62,120,80,'deliveryfees','ADMIN','publish_ordering'),(10,10,584,500,'deliverymins','ADMIN',NULL),(48,195,120,80,'deliverymins','ADMIN','publish'),(343,114,120,80,'deliverymins','ADMIN','published'),(43,284,120,80,'deliverymins','ADMIN','delete'),(347,283,120,80,'deliverymins','ADMIN','deleted'),(180,407,120,80,'deliverymins','ADMIN','cancel'),(620,10,300,500,'deliverymins','PROD_SITE_ACCESS',NULL),(924,18,300,500,'deliverymins','PROD_CACHE_MGMT',NULL),(50,62,120,80,'deliverymins','ADMIN','publish_ordering'),(28,65,120,80,'moduleparams','ADMIN','publish'),(487,9,128,500,'moduleparams','PROD_CACHE_MGMT',''),(10,10,473,500,'moduleparams','ADMIN',''),(279,83,120,80,'moduleparams','ADMIN','published'),(45,282,120,80,'moduleparams','ADMIN','delete'),(250,286,120,80,'moduleparams','ADMIN','deleted'),(138,418,120,80,'moduleparams','ADMIN','cancel'),(28,65,120,80,'quantitylimits','ADMIN','publish'),(487,9,128,500,'quantitylimits','PROD_CACHE_MGMT',''),(10,10,473,500,'quantitylimits','ADMIN',''),(279,83,120,80,'quantitylimits','ADMIN','published'),(45,282,120,80,'quantitylimits','ADMIN','delete'),(250,286,120,80,'quantitylimits','ADMIN','deleted'),(138,418,120,80,'quantitylimits','ADMIN','cancel');
/*!40000 ALTER TABLE `coordinates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_methods`
--

DROP TABLE IF EXISTS `delivery_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delivery_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `helpText` text DEFAULT NULL,
  `orderSeq` int(11) DEFAULT NULL,
  `subType` varchar(50) NOT NULL DEFAULT '',
  `mapsDisplay` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`,`method`,`subType`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_methods`
--

LOCK TABLES `delivery_methods` WRITE;
/*!40000 ALTER TABLE `delivery_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `deliveryfees`
--

DROP TABLE IF EXISTS `deliveryfees`;
/*!50001 DROP VIEW IF EXISTS `deliveryfees`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `deliveryfees` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `dep_type` tinyint NOT NULL,
  `dep_value` tinyint NOT NULL,
  `fee` tinyint NOT NULL,
  `applicable_per_item` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `delivery_type` tinyint NOT NULL,
  `UUID` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deliveryfees_rules`
--

DROP TABLE IF EXISTS `deliveryfees_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveryfees_rules` (
  `deliveryfee_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL,
  PRIMARY KEY (`deliveryfee_id`,`applied_to_type`,`applied_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliveryfees_rules`
--

LOCK TABLES `deliveryfees_rules` WRITE;
/*!40000 ALTER TABLE `deliveryfees_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `deliveryfees_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deliveryfees_tbl`
--

DROP TABLE IF EXISTS `deliveryfees_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveryfees_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `dep_type` varchar(10) NOT NULL,
  `dep_value` varchar(64) NOT NULL,
  `fee` varchar(10) DEFAULT NULL,
  `applicable_per_item` tinyint(1) DEFAULT 0,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `delivery_type` varchar(75) DEFAULT NULL,
  `UUID` varchar(36) NOT NULL DEFAULT uuid(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliveryfees_tbl`
--

LOCK TABLES `deliveryfees_tbl` WRITE;
/*!40000 ALTER TABLE `deliveryfees_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `deliveryfees_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `deliverymins`
--

DROP TABLE IF EXISTS `deliverymins`;
/*!50001 DROP VIEW IF EXISTS `deliverymins`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `deliverymins` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `dep_type` tinyint NOT NULL,
  `dep_value` tinyint NOT NULL,
  `criteria_type` tinyint NOT NULL,
  `minimum_type` tinyint NOT NULL,
  `minimum_total` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `applied_to_type` tinyint NOT NULL,
  `applied_to_value` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deliverymins_tbl`
--

DROP TABLE IF EXISTS `deliverymins_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliverymins_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `dep_type` varchar(10) NOT NULL,
  `dep_value` varchar(64) NOT NULL,
  `criteria_type` varchar(10) DEFAULT NULL,
  `minimum_type` varchar(10) DEFAULT '',
  `minimum_total` varchar(10) DEFAULT NULL,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  `applied_to_type` varchar(50) DEFAULT '',
  `applied_to_value` varchar(255) DEFAULT '',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliverymins_tbl`
--

LOCK TABLES `deliverymins_tbl` WRITE;
/*!40000 ALTER TABLE `deliverymins_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `deliverymins_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eligibility_emails`
--

DROP TABLE IF EXISTS `eligibility_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eligibility_emails` (
  `email` varchar(50) NOT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eligibility_emails`
--

LOCK TABLES `eligibility_emails` WRITE;
/*!40000 ALTER TABLE `eligibility_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `eligibility_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eligibility_requests`
--

DROP TABLE IF EXISTS `eligibility_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eligibility_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(50) DEFAULT NULL,
  `tm` timestamp NULL DEFAULT current_timestamp(),
  `email_sent` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eligibility_requests`
--

LOCK TABLES `eligibility_requests` WRITE;
/*!40000 ALTER TABLE `eligibility_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `eligibility_requests` ENABLE KEYS */;
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
INSERT INTO `errcode` VALUES (0,'','success','success','#00ff1a');
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
-- Table structure for table `familie`
--

DROP TABLE IF EXISTS `familie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `familie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `catalog_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `lang_1_description` text DEFAULT NULL,
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `img_name` varchar(100) DEFAULT NULL,
  `img_alt_tag` varchar(255) DEFAULT NULL,
  `lang_1_img_alt_tag` varchar(255) DEFAULT NULL,
  `lang_2_img_alt_tag` varchar(255) DEFAULT NULL,
  `lang_3_img_alt_tag` varchar(255) DEFAULT NULL,
  `lang_4_img_alt_tag` varchar(255) DEFAULT NULL,
  `lang_5_img_alt_tag` varchar(255) DEFAULT NULL,
  `order_seq` int(10) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `lang_1_name` varchar(255) DEFAULT NULL,
  `lang_2_name` varchar(255) DEFAULT NULL,
  `lang_3_name` varchar(255) DEFAULT NULL,
  `lang_4_name` varchar(255) DEFAULT NULL,
  `lang_5_name` varchar(255) DEFAULT NULL,
  `lang_1_listing_heading` varchar(255) DEFAULT NULL,
  `lang_2_listing_heading` varchar(255) DEFAULT NULL,
  `lang_3_listing_heading` varchar(255) DEFAULT NULL,
  `lang_4_listing_heading` varchar(255) DEFAULT NULL,
  `lang_5_listing_heading` varchar(255) DEFAULT NULL,
  `lang_1_meta_keywords` text DEFAULT NULL,
  `lang_2_meta_keywords` text DEFAULT NULL,
  `lang_3_meta_keywords` text DEFAULT NULL,
  `lang_4_meta_keywords` text DEFAULT NULL,
  `lang_5_meta_keywords` text DEFAULT NULL,
  `lang_1_meta_description` text DEFAULT NULL,
  `lang_2_meta_description` text DEFAULT NULL,
  `lang_3_meta_description` text DEFAULT NULL,
  `lang_4_meta_description` text DEFAULT NULL,
  `lang_5_meta_description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `catalog_id` (`catalog_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `familie`
--

LOCK TABLES `familie` WRITE;
/*!40000 ALTER TABLE `familie` DISABLE KEYS */;
/*!40000 ALTER TABLE `familie` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fraud_rules`
--

DROP TABLE IF EXISTS `fraud_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fraud_rules` (
  `column` varchar(50) NOT NULL,
  `days` int(11) NOT NULL,
  `limit` int(11) NOT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `cart_type` enum('topup','normal','card2wallet') NOT NULL,
  PRIMARY KEY (`column`,`days`,`site_id`,`cart_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fraud_rules`
--

LOCK TABLES `fraud_rules` WRITE;
/*!40000 ALTER TABLE `fraud_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `fraud_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fraud_rules_log`
--

DROP TABLE IF EXISTS `fraud_rules_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fraud_rules_log` (
  `column` varchar(50) NOT NULL,
  `days` int(11) NOT NULL,
  `limit` int(11) NOT NULL,
  `tm` timestamp NULL DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `cart_type` enum('topup','normal') NOT NULL DEFAULT 'normal',
  `ip` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fraud_rules_log`
--

LOCK TABLES `fraud_rules_log` WRITE;
/*!40000 ALTER TABLE `fraud_rules_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `fraud_rules_log` ENABLE KEYS */;
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
INSERT INTO `has_action` VALUES ('tarifs','publish',1,'publish:tarif'),('devices','delete',5,'remove:device'),('translations','publish',3,'publish:translation'),('tarifs','delete',4,'remove:tarif'),('devices','publish',6,'publish:device'),('accessories','delete',7,'remove:accessory'),('accessories','publish',8,'publish:accessory'),('faqs','delete',9,'remove:faq'),('faqs','publish',10,'publish:faq'),('catalogs','delete',11,'remove:catalog'),('catalogs','publish',12,'publish:catalog'),('products','delete',13,'remove:product'),('products','publish',14,'publish:product'),('products','publish_ordering',17,'publishorder:product'),('shop','publish',16,'publish:shop'),('faqs','publish_ordering',18,'publishorder:faq'),('families','delete',19,'remove:familie'),('families','publish',20,'publish:familie'),('families','publish_ordering',21,'publishorder:familie'),('landingpages','delete',25,'remove:landingpage'),('resources','publish',23,'publish:resources'),('landingpages','publish',26,'publish:landingpage'),('promotions','delete',28,'remove:promotion'),('promotions','publish',29,'publish:promotion'),('promotions','publish_ordering',30,'publishorder:promotion'),('cartrules','delete',31,'remove:cartrule'),('cartrules','publish',32,'publish:cartrule'),('cartrules','publish_ordering',33,'publishorder:cartrule'),('additionalfees','delete',34,'remove:additionalfee'),('additionalfees','publish',35,'publish:additionalfee'),('additionalfees','publish_ordering',36,'publishorder:additionalfee'),('comewiths','delete',37,'remove:comewith'),('comewiths','publish',38,'publish:comewith'),('comewiths','publish_ordering',39,'publishorder:comewith'),('subsidies','delete',40,'remove:subsidy'),('subsidies','publish',41,'publish:subsidy'),('subsidies','publish_ordering',42,'publishorder:subsidy'),('deliveryfees','delete',43,'remove:deliveryfee'),('deliveryfees','publish',44,'publish:deliveryfee'),('deliveryfees','publish_ordering',45,'publishorder:deliveryfee'),('deliverymins','delete',46,'remove:deliverymin'),('deliverymins','publish',47,'publish:deliverymin'),('deliverymins','publish_ordering',48,'publishorder:deliverymin'),('moduleparams','delete',49,'remove:moduleparams'),('moduleparams','publish',50,'publish:moduleparams'),('quantitylimits','delete',51,'remove:quantitylimits'),('quantitylimits','publish',52,'publish:quantitylimits');
/*!40000 ALTER TABLE `has_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `landing_pages`
--

DROP TABLE IF EXISTS `landing_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_name` varchar(100) NOT NULL,
  `orientation` varchar(50) NOT NULL DEFAULT '',
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `site_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `landing_pages`
--

LOCK TABLES `landing_pages` WRITE;
/*!40000 ALTER TABLE `landing_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `landing_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `landing_pages_items`
--

DROP TABLE IF EXISTS `landing_pages_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_pages_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `landing_page_id` int(11) NOT NULL,
  `sort_order` int(11) NOT NULL,
  `lang_1_url` varchar(500) NOT NULL DEFAULT '',
  `lang_2_url` varchar(500) NOT NULL DEFAULT '',
  `lang_3_url` varchar(500) NOT NULL DEFAULT '',
  `lang_4_url` varchar(500) NOT NULL DEFAULT '',
  `lang_5_url` varchar(500) NOT NULL DEFAULT '',
  `lang_1_title` varchar(250) NOT NULL DEFAULT '',
  `lang_2_title` varchar(250) NOT NULL DEFAULT '',
  `lang_3_title` varchar(250) NOT NULL DEFAULT '',
  `lang_4_title` varchar(250) NOT NULL DEFAULT '',
  `lang_5_title` varchar(250) NOT NULL DEFAULT '',
  `lang_1_description` varchar(500) NOT NULL DEFAULT '',
  `lang_2_description` varchar(500) NOT NULL DEFAULT '',
  `lang_3_description` varchar(500) NOT NULL DEFAULT '',
  `lang_4_description` varchar(500) NOT NULL DEFAULT '',
  `lang_5_description` varchar(500) NOT NULL DEFAULT '',
  `lang_1_image` varchar(500) NOT NULL DEFAULT '',
  `lang_2_image` varchar(500) NOT NULL DEFAULT '',
  `lang_3_image` varchar(500) NOT NULL DEFAULT '',
  `lang_4_image` varchar(500) NOT NULL DEFAULT '',
  `lang_5_image` varchar(500) NOT NULL DEFAULT '',
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `landing_pages_items`
--

LOCK TABLES `landing_pages_items` WRITE;
/*!40000 ALTER TABLE `landing_pages_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `landing_pages_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language` (
  `langue_id` int(1) unsigned NOT NULL AUTO_INCREMENT,
  `langue` varchar(32) NOT NULL DEFAULT '',
  `langue_code` varchar(2) DEFAULT NULL,
  `og_local` varchar(10) DEFAULT NULL,
  `direction` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`langue_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language`
--

LOCK TABLES `language` WRITE;
/*!40000 ALTER TABLE `language` DISABLE KEYS */;
INSERT INTO `language` VALUES (1,'Français','fr','fr_FR',NULL),(2,'English','en','en_EN',NULL);
/*!40000 ALTER TABLE `language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `langue_msg`
--

DROP TABLE IF EXISTS `langue_msg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `langue_msg` (
  `LANGUE_REF` varchar(255) NOT NULL DEFAULT '',
  `LANGUE_1` varchar(255) DEFAULT NULL,
  `LANGUE_2` varchar(255) DEFAULT NULL,
  `LANGUE_3` varchar(255) DEFAULT NULL,
  `LANGUE_4` varchar(255) DEFAULT NULL,
  `LANGUE_5` varchar(255) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `updated_by` int(10) DEFAULT NULL,
  UNIQUE KEY `LANGUE_REF` (`LANGUE_REF`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `langue_msg`
--

LOCK TABLES `langue_msg` WRITE;
/*!40000 ALTER TABLE `langue_msg` DISABLE KEYS */;
INSERT INTO `langue_msg` VALUES ('Détails du forfait','','Tariff Details','تفاصيل التعريفة',NULL,NULL,'2022-11-04 14:51:14',104),('Appels','','Calls','',NULL,NULL,'2022-11-04 14:49:35',104),('Nationaux','','National','الوطني',NULL,NULL,'2019-10-09 20:26:38',1),('Internationaux','','International','',NULL,NULL,'2022-11-04 14:51:43',104),('Autres','','Others','الآخرين',NULL,NULL,'2022-12-01 09:21:27',74),('Bonus call','','Bonus call','',NULL,NULL,'2022-11-04 14:50:44',104),('SMS, MMS, Data','','SMS, MMS, Data','',NULL,NULL,'2019-10-09 20:26:49',1),('SMS','','SMS','',NULL,NULL,'2019-10-09 20:26:49',1),('MMS','','MMS','',NULL,NULL,'2019-10-09 20:26:36',1),('Data','','Data','البيانات',NULL,NULL,'2022-11-04 14:51:14',104),('Wi-Fi','','Wi-Fi','',NULL,NULL,'2022-11-04 14:54:21',104),('Facebook','','Facebook','',NULL,NULL,'2022-11-04 14:51:14',104),('Whatsapp','','Whatsapp','',NULL,NULL,'2022-11-04 14:54:21',104),('Viber','','Viber','',NULL,NULL,'2019-10-09 20:26:53',1),('Reseau','','Network','',NULL,NULL,'2019-10-09 20:26:46',1),('Service Clients','','Customer service','',NULL,NULL,'2019-10-09 20:26:48',1),('Avec engagement 24 mois','','Price 24 months','????? 24 ????',NULL,NULL,'2022-11-04 14:50:44',104),('Avec engagement 18 mois','','Price 18 months','????? 18 ????',NULL,NULL,'2022-11-04 14:50:44',104),('Avec engagement 12 mois','','Price 12 months','????? 12 ????',NULL,NULL,'2022-11-04 14:50:44',104),('Ajouter au panier','','Add to Basket','اضف الى السلة',NULL,NULL,'2022-11-29 09:01:45',74),('Services inclus','','Services included','',NULL,NULL,'2019-10-09 20:26:48',1),('Nous vous informons','','We inform you','نعلمكم',NULL,NULL,'2019-10-09 20:26:39',1),('Mentions légales','Avertissement','Disclaimer','تنصل',NULL,NULL,'2019-10-09 20:26:35',1),('Prix exprimés Toutes Taxes Comprises','','All Taxes Included','وشملت جميع الضرائب',NULL,NULL,'2022-11-29 09:11:02',74),('Les forfaits','','Tariffs','',NULL,NULL,'2022-11-04 14:51:43',104),('Avec engagement','','With commitment','?? ??????',NULL,NULL,'2022-11-04 14:50:44',104),('Sans engagement','','Without commitment','دون التزام',NULL,NULL,'2022-11-04 14:49:22',104),('Prépayé','','Prepaid','',NULL,NULL,'2019-10-09 20:26:44',1),('Details','Détails','Details','تفاصيل',NULL,NULL,'2022-11-04 14:51:14',104),('Retour','','Back','الى الخلف',NULL,NULL,'2019-10-09 20:26:46',1),('Article suivant','','Next item','البند التالي',NULL,NULL,'2023-09-14 06:56:16',115),('Article précédent','','Previous item','الشيء السابق',NULL,NULL,'2023-09-14 07:01:45',115),('Liste des mobiles','','List of Mobiles','',NULL,NULL,'2022-11-04 14:51:43',104),('Détails du mobile','','Mobile Details','تفاصيل الجوال',NULL,NULL,'2022-11-04 14:51:14',104),('L\'essentiel','','The essential','Essentials',NULL,NULL,'2022-11-04 14:51:43',104),('Fiche technique','','Technical Sheet','ورقة التقنية',NULL,NULL,'2022-11-04 14:51:43',104),('Plus...','','More...','More...',NULL,NULL,'2019-10-09 20:26:43',1),('Comparer','','Compare','',NULL,NULL,'2022-11-04 14:50:44',104),('Retourner','','Go Back','عد',NULL,NULL,'2019-10-09 20:26:46',1),('Voir détails','','View Details','عرض التفاصيل',NULL,NULL,'2022-11-04 14:54:21',104),('Ecran tactile','','Touch screen','',NULL,NULL,'2022-11-04 14:51:14',104),('pouces','','inches','',NULL,NULL,'2019-10-09 20:26:43',1),('Apn','','Resolution','',NULL,NULL,'2022-11-04 14:49:35',104),('megapixels','','megapixels','',NULL,NULL,'2019-10-09 20:26:35',1),('Promotion','','','ترويج',NULL,NULL,'2024-01-16 05:44:03',115),('Réseaux et connectivité','','Networks and connectivity','',NULL,NULL,'2019-10-09 20:26:46',1),('Nouveau','','New','الجديد',NULL,NULL,'2019-10-09 20:26:39',1),('Autonomie','','Autonomy','',NULL,NULL,'2023-09-14 06:46:23',115),('Accessoires','','Accessories','مستلزمات',NULL,NULL,'2022-11-04 14:49:35',104),('Capacite Memoire','','Memory capacity','',NULL,NULL,'2022-11-04 14:50:44',104),('Reseaux','','Networks','',NULL,NULL,'2019-10-09 20:26:46',1),('Longueur','','Length','',NULL,NULL,'2022-11-04 14:51:43',104),('Type De Batterie','','Battery type','',NULL,NULL,'2019-10-09 20:26:52',1),('Taille Ecran','','Screen size','',NULL,NULL,'2019-10-09 20:26:51',1),('Additional category','Catégorie additionnelle','','',NULL,NULL,'2022-11-29 09:01:45',74),('Autres caractéristiques','','Others features','',NULL,NULL,'2022-12-01 09:21:27',74),('Commandes vocales','','Voice commands','اوامر صوتية',NULL,NULL,'2023-09-14 07:01:46',115),('Technologie de l\'écran','','Screen technology','',NULL,NULL,'2019-10-09 20:26:51',1),('Appareil photo','','Photo camera','',NULL,NULL,'2022-11-04 14:49:35',104),('Nombre d\'appareils photo','','Number of cameras','',NULL,NULL,'2023-09-14 06:53:12',115),('Zoom optique','','Optical zoom','',NULL,NULL,'2022-11-04 14:54:21',104),('Audio et vidéo','','Audio and video','',NULL,NULL,'2023-09-14 07:01:45',115),('Format de la prise casque','','Headphone jack format','',NULL,NULL,'2022-11-04 14:51:43',104),('Contenu du pack','','Pack content','حزمة المحتوى',NULL,NULL,'2022-11-04 14:51:14',104),('Synthèse','','Synthesis','',NULL,NULL,'2019-10-09 20:26:50',1),('Information Supplémentaire','','Additional information','',NULL,NULL,'2022-11-29 09:01:45',74),('Découvrir','','Discover','',NULL,NULL,'2022-11-04 14:51:14',104),('Les prix sont affichés hors taxes','','Prices are displayed excluding taxes','',NULL,NULL,'2022-11-04 14:51:43',104),('En savoir plus','','Read more','قراءة المزيد',NULL,NULL,'2022-11-04 14:51:14',104),('Page non trouvée','','Page not found','الصفحة غير موجودة',NULL,NULL,'2019-10-09 20:26:42',1),('Enregistrez','','Register','سجل هنا',NULL,NULL,'2023-03-06 12:52:51',113),('Email','','','البريد الإلكتروني',NULL,NULL,'2022-11-04 14:51:14',104),('Mot de passe','','Password','كلمه السر',NULL,NULL,'2019-10-09 20:26:37',1),('Prénom','','First name','',NULL,NULL,'2023-09-14 06:46:23',115),('Surname','Nom de famille','','',NULL,NULL,'2023-09-14 06:46:23',115),('Identifiant Orange','','Orange ID','',NULL,NULL,'2022-11-04 14:51:43',104),('Enregistrer','','Save','سجل',NULL,NULL,'2023-03-06 12:52:51',113),('Afficher le mot de passe','','Show password','عرض كلمة المرور',NULL,NULL,'2023-09-14 07:01:45',115),('Masquer le mot de passe','','Hide password','إخفاء كلمة المرور',NULL,NULL,'2022-11-04 14:51:43',104),('Enregistrement réussis. Dès à présent, vous allez pouvoir vous connecter à votre compte avec votre email','','Registration successful. From now on, you will be able to login to your account with your email','',NULL,NULL,'2023-03-06 12:52:51',113),('Mon compte','','My account','حسابي',NULL,NULL,'2019-10-09 20:26:36',1),('Bonjour','','Hello','مرحبا',NULL,NULL,'2022-11-04 14:50:44',104),('Some of the required fields are missing','Certains des champs requis sont manquants','','بعض الحقول المطلوبة مفقودة',NULL,NULL,'2019-10-09 20:26:49',1),('Certains des champs requis sont manquants','','Some of required fields are missing','بعض الحقول المطلوبة مفقودة',NULL,NULL,'2023-09-14 07:01:45',115),('nom d\'utilisateur ou mot de passe invalide','','Invalid username or password','اسم المستخدم أو كلمة المرور غير صالحة',NULL,NULL,'2023-09-14 06:46:23',115),('vous devez fournir le nom d\'utilisateur / mot de passe','Veuillez fournir le nom d\'utilisateur/mot de passe','You must provide username/password','يجب عليك تقديم اسم المستخدم / كلمة المرور',NULL,NULL,'2023-09-14 06:46:23',115),('Success','Succès','','',NULL,NULL,'2019-10-09 20:26:50',1),('Achat rapide','','Buy Now','اشتري الآن',NULL,NULL,'2023-09-14 07:01:45',115),('week','Semaine','Week','',NULL,NULL,'2022-11-04 14:54:21',104),('month','mois','month','شهر',NULL,NULL,'2021-09-14 15:19:19',59),('Duration','Durée','Duration','',NULL,NULL,'2022-11-04 14:51:14',104),('gratuit','','free','حر',NULL,NULL,'2022-11-04 14:51:43',104),('à partir de','','price from','',NULL,NULL,'2022-11-04 14:54:21',104),('mois','','Month','',NULL,NULL,'2021-09-14 15:19:19',59),('illimité','','unlimited','',NULL,NULL,'2022-11-04 14:51:43',104),('One Time Payment','','','دفعة لمرة واحدة',NULL,NULL,'2019-10-09 20:26:40',1),('12 months','12 mois','12 Months','',NULL,NULL,'2022-11-04 14:49:35',104),('6 months','6 mois','6 Months','',NULL,NULL,'2022-11-04 14:49:35',104),('1 Month','1 mois','1 Month','',NULL,NULL,'2022-11-04 14:49:35',104),('Description','La description','Description','وصف',NULL,NULL,'2022-11-04 14:51:14',104),('Dollar','','','دولار',NULL,NULL,'2022-11-04 14:51:14',104),('engagment 12 mois','','12 months commitment','',NULL,NULL,'2022-11-04 14:51:14',104),('engagment 24 mois','','24 months commitment','',NULL,NULL,'2022-11-04 14:51:14',104),('Samsung','','','سامسونج',NULL,NULL,'2019-10-09 20:26:47',1),('Usage à domicile ou au bureau. Vous allez pouvoir partager votre connexion avec un\r\nnombre plus impo','','Home or office use. You will be able to share your connection with a more important number','استخدام المنزل أو المكتب. ستتمكن من مشاركة اتصالك برقم أكثر أهمية',NULL,NULL,'2023-09-14 06:53:12',115),('\"Particuliers, professionnels, voici votre nouvel assistant quotidien pour le surf, la bureautique e','','\"Personal, professional, here is your new daily assistant for surfing, office automation and','\"الشخصية ، والمهنية ، وهنا هو مساعدك اليومي الجديد لتصفح الإنترنت والتشغيل الآلي للمكاتب و',NULL,NULL,'2022-11-04 14:49:35',104),('Panier mis à jour','','Cart updated','عربة تحديثها',NULL,NULL,'2019-10-09 20:26:42',1),('Memory Capacity','Capacité mémoire','','',NULL,NULL,'2019-10-09 20:26:35',1),('Color','Couleur','Color','اللون',NULL,NULL,'2022-11-04 14:50:44',104),('Warranty','Garantie','','',NULL,NULL,'2022-11-04 14:54:21',104),('2 years','2 ans','','',NULL,NULL,'2022-11-04 14:49:35',104),('Black','Noir','','',NULL,NULL,'2022-11-04 14:50:44',104),('Noir','','Black','أسود',NULL,NULL,'2019-10-09 20:26:39',1),('1 Year','1 an','1 Year','',NULL,NULL,'2022-11-04 14:49:35',104),('Size','Taille','','',NULL,NULL,'2019-10-09 20:26:48',1),('J\'ai lu et j\'accepte les conditions générales de vente','','I read and I agree to the general selling conditions','لقد قرأت وأقبل الشروط العامة للبيع',NULL,NULL,'2022-11-04 14:51:43',104),('Passer la commande','','Order','طلب',NULL,NULL,'2023-09-14 06:43:11',115),('Revenir aux achats','','Back to Shopping','العودة إلى التسوق',NULL,NULL,'2023-09-14 07:03:48',115),('J\'accepte les','','I accept the','أقبل',NULL,NULL,'2022-11-04 14:51:43',104),('termes et conditions','Conditions générales de vente','Terms & Conditions','البنود و الظروف',NULL,NULL,'2023-09-14 06:40:36',115),('Certaines informations demandées restent à renseigner','','Some information requested remain to be filled','بعض المعلومات المطلوبة لا تزال ملؤها',NULL,NULL,'2023-09-14 07:01:45',115),('Cette adresse mail a déjà été enregistrée','','This email address has already been registered','تم تسجيل عنوان البريد الإلكتروني هذا بالفعل',NULL,NULL,'2023-09-14 06:54:50',115),('Se connecter','','Login','تسجيل الدخول',NULL,NULL,'2019-10-09 20:26:47',1),('Panier','','Cart','سلة',NULL,NULL,'2019-10-09 20:26:42',1),('Coordonnees','','Contact Information','معلومات للتواصل',NULL,NULL,'2022-11-04 14:51:14',104),('Confirmation','','','التأكيد',NULL,NULL,'2022-11-04 14:50:44',104),('Merci! Votre commande est maintenant enregistrée.','','Thank you! Your order is now registered.','شكرا لك! طلبك مسجل الآن.',NULL,NULL,'2023-09-14 06:43:11',115),('Un mail incluant les informations de cette page et une facture au format .pdf vous a été envoyé à l\'adresse','','An email including the information on this page and an invoice in .pdf format has been sent to the addressg','تم إرسال بريد إلكتروني يتضمن المعلومات الواردة في هذه الصفحة وفاتورة بتنسيق .pdf إلى العنوان',NULL,NULL,'2023-09-14 07:00:19',115),('Votre commande','','Your order','طلبك',NULL,NULL,'2023-09-14 06:43:11',115),('Référence commande','','Order reference','مرجع الطلب',NULL,NULL,'2023-09-14 06:43:11',115),('Heure','','Time','',NULL,NULL,'2022-11-04 14:51:43',104),('Suivre la commande','','Order Status','حالة الطلب',NULL,NULL,'2023-09-14 06:56:16',115),('Total Hors Taxes','','Total without taxes','مجموع الضرائب',NULL,NULL,'2019-10-09 20:26:52',1),('A payer chaque mois','','To pay every month','',NULL,NULL,'2022-11-04 14:49:35',104),('(2) TVA 20% sur les services','','(2) VAT 20% on services','(2) ضريبة القيمة المضافة 20 ٪ على الخدمات',NULL,NULL,'2022-11-04 14:49:35',104),('Euro/mois','','Euro/Month','',NULL,NULL,'2022-11-04 14:51:14',104),('Facturation','','Billing','الفواتير',NULL,NULL,'2022-11-04 14:51:43',104),('Téléphone','','Telephone','',NULL,NULL,'2019-10-09 20:26:52',1),('Livraison','','Delivery','تسليم',NULL,NULL,'2022-11-04 14:51:43',104),('A bientôt,','','Thanks for Shopping - Please come again.','شكرا للتسوق - يرجى العودة مرة أخرى.',NULL,NULL,'2022-11-04 14:49:35',104),('Le Service Client','','Client service','',NULL,NULL,'2022-11-04 14:51:43',104),('Vous','','You','',NULL,NULL,'2022-11-04 14:54:21',104),('Civilité','','Civility','كياسة',NULL,NULL,'2022-11-04 14:50:44',104),('Nom de famille','','Last Name','الكنية',NULL,NULL,'2023-09-14 06:46:23',115),('Nationalité','','Nationality','الوطني',NULL,NULL,'2019-10-09 20:26:38',1),('Type de pièce d\'identité','','Identity type','',NULL,NULL,'2023-09-14 06:47:17',115),('Passeport','','Passport','جواز سفر',NULL,NULL,'2019-10-09 20:26:42',1),('Carte résident','','Resident Card','',NULL,NULL,'2023-09-14 07:01:45',115),('N° de carte d\'identité/Passeport','','ID card number / Passport','رقم بطاقة الهوية / جواز السفر',NULL,NULL,'2023-09-14 06:53:12',115),('Pour vous contacter','','Contact','',NULL,NULL,'2019-10-09 20:26:43',1),('E-mail','','','البريد الإلكتروني',NULL,NULL,'2022-11-04 14:51:14',104),('Confirmez votre e-mail','','Confirm Email','تأكيد عنوان البريد الإلكتروني',NULL,NULL,'2022-11-04 14:51:14',104),('Votre adresse de facturation','','Billing Address','عنوان وصول الفواتير',NULL,NULL,'2023-09-14 07:00:19',115),('Adresse','','Address','',NULL,NULL,'2023-09-14 06:54:50',115),('Complément d\'adresse (facultatif)','','Additional address (optional)','عنوان إضافي (اختياري)',NULL,NULL,'2023-09-14 06:55:05',115),('Ville','','City','',NULL,NULL,'2019-10-09 20:26:53',1),('Soumettre','','Submit','خضع',NULL,NULL,'2019-10-09 20:26:49',1),('Username','Utilisateur','','',NULL,NULL,'2019-10-09 20:26:53',1),('Forgot Password?','Mot de passe oublié?','','هل نسيت كلمة المرور؟',NULL,NULL,'2022-11-04 14:51:43',104),('Login','S\'identifier','','تسجيل الدخول',NULL,NULL,'2022-11-04 14:51:43',104),('Not a member? Register here!','Pas un membre? Inscrivez-vous ici!','','ليس عضوا؟ سجل هنا!',NULL,NULL,'2019-10-09 20:26:39',1),('Nos boutiques','Nos boutiques','Our Shops','محلاتنا',NULL,NULL,'2019-10-09 20:26:39',1),('Results','Résultats','Results','',NULL,NULL,'2019-10-14 14:03:49',1),('Keyword not Found(s).','Mot-clé introuvable (s).','','',NULL,NULL,'2022-11-04 14:51:43',104),('Not enough stock, please reduce the quantity','Pas assez de stock, veuillez réduire la quantité','','ليس ما يكفي من الأسهم ، يرجى تقليل الكمية',NULL,NULL,'2023-09-14 07:02:46',115),('Meilleur réseau','','Best network','أفضل شبكة',NULL,NULL,'2019-10-09 20:26:35',1),('Weight','Poids','','',NULL,NULL,'2022-11-04 14:54:21',104),('Le produit a bien été ajouté au panier','','The product has been successfully added to cart','',NULL,NULL,'2022-11-29 09:01:45',74),('Poursuivre les achats','','Continue Shopping','مواصلة التسوق',NULL,NULL,'2023-09-14 06:56:16',115),('Finaliser mes achats','Passer à la caisse','Proceed to Checkout','باشرالخروج من الفندق',NULL,NULL,'2022-11-04 14:51:43',104),('Supprimer','','Remove from Cart','أزل من السلة',NULL,NULL,'2019-10-09 20:26:50',1),('Votre panier est tristement vide. Nous espérons que nos offres sauront vous satisfaire.','','Your basket is sadly empty. We hope that our offers will satisfy you.','سلتك فارغة',NULL,NULL,'2023-09-14 07:11:46',115),('You must accept the terms and conditions!','','','يجب عليك قبول الشروط والأحكام!',NULL,NULL,'2022-11-04 14:54:21',104),('Adresse e-mail invalide','','Email address is not valid','عنوان البريد الإلكتروني غير صالح',NULL,NULL,'2023-09-14 07:01:45',115),('Le champ ne peut contenir que des nombres','','Enter numbers only','',NULL,NULL,'2023-09-14 06:53:12',115),('Token incompatibilité','','Token incompatible','رمز غير متوافق',NULL,NULL,'2019-10-09 20:26:52',1),('Fermer','','Close','أغلق',NULL,NULL,'2022-11-04 14:51:43',104),('Mon Profil','','My profile','ملفي الشخصي',NULL,NULL,'2019-10-09 20:26:36',1),('Some error occurred while processing search','','','حدث خطأ ما أثناء معالجة البحث',NULL,NULL,'2019-10-09 20:26:49',1),('Some error occurred while processing cart','','','حدث خطأ ما أثناء معالجة العربة',NULL,NULL,'2019-10-09 20:26:49',1),('Operating Hours','Heures de fonctionnement','','ساعات العمل',NULL,NULL,'2019-10-09 20:26:40',1),('adresse mail non valide','','invalid email address','',NULL,NULL,'2023-09-14 07:01:45',115),('numéro de téléphone non valide','','Invalid phone number','رقم هاتف غير صحيح',NULL,NULL,'2023-09-14 06:53:12',115),('Formulaire de demande de partenariat SVA','','SVA Partnership Application Form','استمارة طلب شراكة SVA',NULL,NULL,'2022-11-04 14:51:43',104),('Nom & prénom du représentant','','Name and first name of the representative','الاسم والاسم الأول للممثل',NULL,NULL,'2023-09-14 06:46:23',115),('Devenir partenaire','','To become partner','',NULL,NULL,'2022-11-04 14:51:14',104),('Voix','','Voice','',NULL,NULL,'2022-11-04 14:54:21',104),('Fichier de présentation du service','','Service presentation file','ملف عرض الخدمة',NULL,NULL,'2022-11-04 14:51:43',104),('Envoyer','','Send','إرسال',NULL,NULL,'2022-11-04 14:51:14',104),('num�ro de t�l�phone non valide','','Invalid Mobile number','رقم هاتف غير صحيح',NULL,NULL,'2023-09-14 06:53:12',115),('Nom & pr�nom du repr�sentant','','Name and first name of the representative','الاسم والاسم الأول للممثل',NULL,NULL,'2023-09-14 06:46:23',115),('Soumettez nous votre demande en remplissant le formulaire ci-dessous et nos �quipes vous contacterons dans les plus brefs d�lais.','Soumettez nous votre demande en remplissant le formulaire ci-dessous et nos équipes vous contacterons dans les plus brefs délais.','Submit your request by filling out the form below and our teams will contact you as soon as possible.','أرسل طلبك من خلال ملء النموذج أدناه وسوف تقوم فرقنا بالاتصال بك في أقرب وقت ممكن.',NULL,NULL,'2019-10-09 20:26:49',1),('Soumettez nous votre demande en remplissant le formulaire ci-dessous et nos équipes vous contacterons dans les plus brefs délais.','','Submit your request by filling out the form below and our teams will contact you as soon as possible.','أرسل طلبك من خلال ملء النموذج أدناه وسوف تقوم فرقنا بالاتصال بك في أقرب وقت ممكن.',NULL,NULL,'2019-10-09 20:26:49',1),('Télécharger','','Download','',NULL,NULL,'2022-11-02 14:06:44',104),('Your session is expired. Please login again','Votre session a expirée, veuillez vous reconnecter','','انتهت جلستك. الرجاد الدخول على الحساب من جديد',NULL,NULL,'2022-11-04 14:54:21',104),('Mon Orders','','My orders','طلبي',NULL,NULL,'2022-11-29 09:11:31',74),('Téléphone seul','','Device only','',NULL,NULL,'2019-10-09 20:26:52',1),('Some error occurred while processing request','','','حدث خطأ ما أثناء معالجة الطلب',NULL,NULL,'2019-10-09 20:26:49',1),('Close','Fermer','','أغلق',NULL,NULL,'2022-11-04 14:50:44',104),('Unavailable','Indisponible','','',NULL,NULL,'2022-11-02 14:40:36',104),('Your Bookings','Vos réservations','','حجوزاتك',NULL,NULL,'2022-11-04 14:54:21',104),('Comments','','Comments','تعليقات',NULL,NULL,'2023-09-14 06:46:08',115),('Save Comments','Sauvegarder commentaires','','',NULL,NULL,'2023-09-14 06:46:08',115),('Un mail incluant les informations de cette page et une facture vous a été envoyé à l\'adresse','','An email including the information on this page and an invoice has been sent to you','تم إرسال بريد إلكتروني يتضمن المعلومات الواردة في هذه الصفحة وفاتورة بتنسيق .pdf إلى العنوان',NULL,NULL,'2023-09-14 07:00:19',115),('Total Price','Total de la commande','','السعر الكلي',NULL,NULL,'2023-09-14 06:43:11',115),('Votre panier est tristement vide.','','Your basket is empty','سلتك فارغة',NULL,NULL,'2023-09-14 07:11:46',115),('à partir','','from','',NULL,NULL,'2022-11-04 14:54:21',104),('3 Months','3 mois','3 Months','',NULL,NULL,'2022-11-04 14:49:35',104),('Status','Statut','','',NULL,NULL,'2019-10-09 20:26:50',1),('Open','ouvrir','','افتح',NULL,NULL,'2019-10-09 20:26:40',1),('correspondant à la sélection','','corresponding to the selection','المقابلة للاختيار',NULL,NULL,'2022-11-04 14:51:14',104),('Prix Toutes Taxes Comprises','','All Taxes Included','وشملت جميع الضرائب',NULL,NULL,'2022-11-29 09:11:02',74),('day','jour','Day','يوم',NULL,NULL,'2022-11-04 14:51:14',104),('You are not authorized to view this page!!!','Vous n\'êtes pas autorisé à accéder à cette page','','',NULL,NULL,'2022-11-04 14:54:21',104),('Submit Complaint','Soumettre une demande','','',NULL,NULL,'2019-10-09 20:26:50',1),('Confirmez','','Confirmation','التأكيد',NULL,NULL,'2022-11-04 14:51:14',104),('votre','','yours','',NULL,NULL,'2022-11-04 14:54:21',104),('Vérifiez votre panier','','Your Cart Information','تحقق من سلة التسوق الخاصة بك',NULL,NULL,'2022-11-04 14:54:21',104),('J\'ai lu et j\'accepte les','','I have read and I accept','لقد قرأت وأوافق',NULL,NULL,'2022-11-04 14:51:43',104),('Filter Product By','Filtrer le produit par','','تصفية المنتج من قبل',NULL,NULL,'2022-11-04 14:51:43',104),('Récapitulatif','Récapitulatif','Summary','ملخص',NULL,NULL,'2022-10-28 07:04:39',74),('USD','FCFA','FCFA','FCFA',NULL,NULL,'2019-10-09 20:26:53',1),('test','testFR','testEN','',NULL,NULL,'2019-10-09 20:26:51',1),('Back to catalog','Revenir au catalogue','','',NULL,NULL,'2023-09-14 07:03:48',115),('Submit Answer','Soumettre la réponse','','',NULL,NULL,'2019-10-09 20:26:50',1),('Forfait','','Package','',NULL,NULL,'2022-11-04 14:51:43',104),('Question regarding product','Question regarding produit2','','',NULL,NULL,'2019-10-09 20:26:44',1),('A user asked a question regarding a product you recently purchased:','Un client a posé une question sur un produit que vous avez récemment acheter','','',NULL,NULL,'2023-09-14 06:46:08',115),('Regards,','Cordialement','','',NULL,NULL,'2019-10-09 20:26:46',1),('Choisissez votre méthode de paiement','','Choose your payment method','اختر طريقة الدفع الخاصة بك',NULL,NULL,'2023-09-14 07:01:46',115),('Finaliser','','Confirm','وضع اللمسات الأخيرة',NULL,NULL,'2022-11-04 14:51:43',104),('End Date must be equal to or greater than Start Date','','','يجب أن يكون تاريخ الانتهاء مساويًا لـ أو أكبر من تاريخ البدء',NULL,NULL,'2022-11-04 14:51:14',104),('Choisissez votre <br />méthode de paiement','','Choose your payment method','اختر طريقة الدفع الخاصة بك',NULL,NULL,'2023-09-14 07:01:46',115),('Yearly','Annuel','','',NULL,NULL,'2023-03-06 12:52:30',113),('Starting from','À partir de','Starting from','',NULL,NULL,'2022-11-02 15:17:34',104),('Back','Retour','','الى الخلف',NULL,NULL,'2022-11-04 14:50:44',104),('PKR','PKR','PKR','PKR',NULL,NULL,'2019-10-09 20:26:43',1),('adresse mail invalide fournie','L\'adresse e-mail fournie n\'est pas valide','The email address you provided is not valid','',NULL,NULL,'2023-09-14 07:01:45',115),('Choisissez un mode de livraison','','Choose a delivery mode','اختر وضع التسليم',NULL,NULL,'2023-09-14 07:04:44',115),('Étape précédente','','Previous step','الخطوة السابقة',NULL,NULL,'2022-11-04 14:54:21',104),('Étape suivante','','Next step','الخطوة السابقة',NULL,NULL,'2023-09-14 06:56:16',115),('Choisissez un mode de <br />livraison','','Choose a delivery mode','اختر وضع التسليم',NULL,NULL,'2023-09-14 07:04:44',115),('Filter par','Filtrer par','Filter by','تصفية حسب',NULL,NULL,'2022-11-04 14:51:43',104),('Total de la commande','','Total order','النظام الكلي',NULL,NULL,'2023-09-14 06:43:11',115),('Commande/demande annulée','','Order/request canceled','الطلب / الطلب ملغى',NULL,NULL,'2023-09-14 07:01:46',115),('sous 2 - 5 jours ouvres chez vous','','within 2-5 business days at home','في غضون 2-5 أيام عمل في المنزل',NULL,NULL,'2019-10-09 20:26:49',1),('Vous serez recontacter par un conseiller client pour définir l\'agence de livraison','','You will be contacted by a customer advisor to explain the delivery process','سيتم الاتصال بك من قبل مستشار العملاء لشرح عملية التسليم',NULL,NULL,'2022-11-04 14:54:21',104),('$','','PKR','',NULL,NULL,'2022-11-04 14:49:35',104),('Contact number','Contact No','','',NULL,NULL,'2023-09-14 06:53:12',115),('Modifier','','Modify','',NULL,NULL,'2019-10-09 20:26:36',1),('Réinitialiser','','Reset','إعادة تعيين',NULL,NULL,'2019-10-09 20:26:46',1),('Appliquer','','Apply','',NULL,NULL,'2022-11-04 14:49:35',104),('disponible','','Available','متاح',NULL,NULL,'2022-11-04 14:51:14',104),('Avis client','','Customer reviews','مراجعات العملاء',NULL,NULL,'2022-11-04 14:50:44',104),('Merci de remplir ce champ','','Please fill in this field','شكرا لك ملء هذا المجال',NULL,NULL,'2019-10-09 20:26:35',1),('Bientôt disponible','','Coming soon','متاح قريبا',NULL,NULL,'2022-11-04 14:50:44',104),('Vous serez recontacté par un conseiller client pour définir l\'agence de livraison','','You will be contacted by a customer advisor to explain the delivery process','سيتم الاتصال بك من قبل مستشار العملاء لشرح عملية التسليم',NULL,NULL,'2022-11-04 14:54:21',104),('Recurring Price','Prix récurrent','','',NULL,NULL,'2019-10-14 13:46:41',1),('entrer le numéro seulement','','enter number only','أدخل الرقم فقط',NULL,NULL,'2023-09-14 06:53:12',115),('Entrez une adresse email valide','','Enter a valid email address','أدخل عنوان بريد إلكتروني صالح',NULL,NULL,'2023-09-14 07:10:38',115),('Merci dentrer un numéro de téléphone valide','','Please enter a valid phone number','يرجى إدخال رقم هاتف صالح',NULL,NULL,'2023-09-14 06:53:12',115),('Merci d\'entrer un numéro de téléphone valide','','Please enter a valid phone number','يرجى إدخال رقم هاتف صالح',NULL,NULL,'2023-09-14 06:53:12',115),('Merci d entrer une adresse email valide','','Please enter a valid email address','يرجى إدخال عنوان بريد إلكتروني صالح',NULL,NULL,'2023-09-14 07:00:19',115),('Merci d entrer un numéro de téléphone valide','','Please enter a valid phone number','يرجى إدخال رقم هاتف صالح',NULL,NULL,'2023-09-14 06:53:12',115),('Merci de renseigner le meme email.','','Please fill in the same email.','يرجى ملء نفس البريد الإلكتروني.',NULL,NULL,'2020-05-19 07:25:55',56),('sous 2 - 5 jours ouvrÃ©s chez vous','','within 2-5 business days at home','في غضون 2-5 أيام عمل في المنزل',NULL,NULL,'2019-10-09 20:26:49',1),('Vous serez recontactÃ© par un conseiller client pour dÃ©finir l\'agence de livraison','','You will be contacted by a customer advisor to explain the delivery process','سيتم الاتصال بك من قبل مستشار العملاء لشرح عملية التسليم',NULL,NULL,'2022-11-04 14:54:21',104),('Livraison Ã  domicile','','Home delivery','توصيل للمنازل',NULL,NULL,'2022-11-04 14:51:43',104),('Voir la carte','','See the map','',NULL,NULL,'2023-09-14 06:48:49',115),('Trouver Une agence','','Find a store','',NULL,NULL,'2019-10-09 20:26:52',1),('Rechercher','','Search','بحث',NULL,NULL,'2019-10-09 20:26:45',1),('Veuillez sélectionner une méthode de paiement','','Please choose a payment method','',NULL,NULL,'2019-10-11 15:57:09',1),('disponibles','','Available','متاح',NULL,NULL,'2022-11-04 14:51:14',104),('Livraison à domicile','','Home delivery','توصيل للمنازل',NULL,NULL,'2022-11-04 14:51:43',104),('Votre recherche n\'affiche aucun résultat','','Your search does not show any results','بحثك لا يعرض أي نتائج',NULL,NULL,'2022-11-04 14:54:21',104),('Votre panier comprend','','Items in the basket','تشمل سلة الخاص بك',NULL,NULL,'2022-11-04 14:54:21',104),('Plus de boutiques','','More shops','مزيد من المتاجر',NULL,NULL,'2019-10-09 20:26:43',1),('Un mail incluant les informations de cette page et une confirmation de commande au format.pdf vous ont été envoyés à l\'adresse','','An email including the information on this page and an order confirmation in .pdf format have been sent to you at','تم إرسال بريد إلكتروني يتضمن المعلومات الواردة في هذه الصفحة وتأكيد الطلب بتنسيق pdf',NULL,NULL,'2023-09-14 07:00:19',115),('XAF','FCFA','FCAF','','','','2022-11-04 14:54:21',104),('sous 2-5 jours ouvrés chez vous','','within 2-5 business days at home','في غضون 2-5 أيام عمل في المنزل',NULL,NULL,'2019-10-09 20:26:49',1),('Vous serez livré chez vous','','You order will be delivered to your home','سيتم تسليمك إلى منزلك',NULL,NULL,'2022-11-29 09:11:31',74),('Frais lié au paiement : gratuit','','Payment Fee: Free','دفع الرسوم: مجانا',NULL,NULL,'2022-11-04 14:51:43',104),('puis','','then','ثم',NULL,NULL,'2019-10-09 20:26:44',1),('Continuez vos achats','','Continue Shopping','مواصلة التسوق',NULL,NULL,'2023-09-14 06:38:06',115),('Voir votre panier','','View your cart','عرض عربة التسوق',NULL,NULL,'2023-09-14 06:38:51',115),('TVA incluse','TVA incluse','VTA included','',NULL,NULL,'2022-10-28 09:38:22',74),('Suivi de commande','','Order Status','حالة الطلب',NULL,NULL,'2023-09-14 06:56:16',115),('sous 2-5 jours ouvrés chez vous\r\nsous 2-5 jours ouvrés chez vous\r\nsous 2-5 jours ouvrés chez vous\r\nsous 2-5 jours ouvrés chez vous','','within 2-5 business days at home','في غضون 2-5 أيام عمل في المنزل',NULL,NULL,'2019-10-09 20:26:49',1),('Vérifiez les informations.','','Check the information before confirming','تحقق من المعلومات قبل التأكيد',NULL,NULL,'2022-11-04 14:54:21',104),('Choisissez votre mode de paiement puis vérifiez les informations de votre commande avant de la valider.','','Choose your method of payment then check the information of your order before validating it.','اختر طريقة الدفع الخاصة بك ثم تحقق من معلومات طلبك قبل التحقق من صحته.',NULL,NULL,'2023-09-14 07:04:44',115),('Engagement','','Commitment','',NULL,NULL,'2022-11-04 14:51:14',104),('pendant','','for','',NULL,NULL,'2019-10-09 20:26:42',1),('a été ajouté au panier','','has been added to the cart','تمت إضافته إلى السلة',NULL,NULL,'2023-09-14 07:01:45',115),('Off Peak Hours (10am - 12pm)','Heures creuses (de 10h à 12h)','Off Peak Hours (10am - 12pm)','',NULL,NULL,'2019-10-09 20:26:40',1),('Off Peak Hours (2pm - 4pm)','Heures creuses (de 14h à 16h)','Off Peak Hours (2pm - 4pm)','',NULL,NULL,'2019-10-09 20:26:40',1),('One Month','Un mois','One Month','',NULL,NULL,'2021-09-14 15:19:19',59),('Availability','Disponibilité','Availability','توفر',NULL,NULL,'2022-11-04 14:49:35',104),('Program Duration','Durée du programme','Program Duration','',NULL,NULL,'2023-09-14 06:46:08',115),('Numéro de votre commande','','Your order number','رقم طلبك',NULL,NULL,'2023-09-14 06:53:12',115),('Votre adresse email','','Your email address','بريدك الالكتروني',NULL,NULL,'2023-09-14 06:54:50',115),('Submit','Soumettre','','',NULL,NULL,'2019-10-09 20:26:50',1),('Retour à la boutique','','Return to the shop','العودة إلى المحل',NULL,NULL,'2019-10-09 20:26:46',1),('Voir le statut','','See the order status','انظر الحالة',NULL,NULL,'2022-11-29 09:11:31',74),('Désolé, cette commande n\'existe pas','','Sorry, this command does not exist','عذرا ، هذا الأمر غير موجود',NULL,NULL,'2023-09-14 06:43:11',115),('blue','Bleu','Blue','','l4','l5','2022-11-04 14:50:44',104),('Couleur','','Color','',NULL,NULL,'2022-11-04 14:51:14',104),('Rouge','','Red','',NULL,NULL,'2019-10-09 20:26:46',1),('Stockage','','Storage','',NULL,NULL,'2023-09-14 06:36:28',115),('Apple','','','أبل',NULL,NULL,'2022-11-04 14:49:35',104),('Votre adresse e-mail','','Your email address','بريدك الالكتروني',NULL,NULL,'2023-09-14 06:54:50',115),('Merci d\'entrer une adresse e-mail valide','','Please enter a valid email address','يرجى إدخال عنوان بريد إلكتروني صالح',NULL,NULL,'2023-09-14 07:00:19',115),('Best Price','Meilleur prix','','',NULL,NULL,'2022-11-04 14:50:44',104),('Registered Customer','Client enregistré','','',NULL,NULL,'2023-03-06 12:52:51',113),('Retour à l’accueil','','Back to Home','عودة إلى الإستقبال',NULL,NULL,'2019-10-09 20:26:46',1),('Numéro de téléphone mobile','','Phone number','رقم الهاتف المحمول',NULL,NULL,'2023-09-14 06:53:12',115),('A Payer','','To pay','',NULL,NULL,'2022-11-04 14:49:35',104),('Désolé, aucune correspondance trouvée.','','Sorry, no match found.','عذرا ، لم يتم العثور على تطابق.',NULL,NULL,'2022-11-04 14:51:14',104),('Bleu','','Blue','',NULL,NULL,'2022-11-04 14:50:44',104),('Numéro de la commande','','Order number','رقم الطلب',NULL,NULL,'2023-09-14 06:53:12',115),('Merci dentrer une adresse e-mail valide','','Please enter a valid e-mail address','يرجى إدخال عنوان بريد إلكتروني صالح',NULL,NULL,'2023-09-14 07:00:19',115),('Storage','Stockage','','',NULL,NULL,'2023-09-14 06:36:28',115),('back to top','Haut','Back to top','',NULL,NULL,'2022-11-04 14:50:44',104),('Retour en haut','','Top','',NULL,NULL,'2019-10-09 20:26:46',1),('Abonnement un mois','','One month subscription','',NULL,NULL,'2022-11-04 14:49:35',104),('(TVA incluse)','','(VTA included)','',NULL,NULL,'2023-09-14 07:01:45',115),('Exclusive Price','Prix exclusif','','سعر حصري',NULL,NULL,'2022-11-04 14:51:14',104),('d\'engagement','','commitment','التزام',NULL,NULL,'2022-11-04 14:51:14',104),('Avance à payer','','Advance to Pay','مقدما للدفع',NULL,NULL,'2022-11-04 14:49:35',104),('soit','','is','',NULL,NULL,'2019-10-09 20:26:49',1),('something','quelque chose','','',NULL,NULL,'2019-10-09 20:26:49',1),('Starting price','Prix à partir de','','',NULL,NULL,'2022-11-02 15:17:34',104),('Avance','','Advance','',NULL,NULL,'2022-11-04 14:49:35',104),('Souscrire','','Suscribe','',NULL,NULL,'2019-10-09 20:26:49',1),('Ce produit a déjà été ajouté au panier','','This product has already been added to cart','تمت إضافة هذا المنتج بالفعل إلى سلة التسوق',NULL,NULL,'2023-09-14 07:01:45',115),('Vérifiez les informations avant de valider','','Check the information before confirming','تحقق من المعلومات قبل التأكيد',NULL,NULL,'2023-09-14 06:45:09',115),('Votre commande n’a pas abouti car vous avez atteint le nombre maximal d’opération autorisées.','','Your order was unsuccessful because you have reached the maximum number of transactions allowed.','',NULL,NULL,'2023-09-14 06:53:12',115),('Voir Conditions','Voir les conditions','See conditions','',NULL,NULL,'2019-10-09 20:26:54',1),('Retour à la payment','','Back to the payment','العودة إلى الدفع',NULL,NULL,'2019-10-09 20:26:46',1),('Aller au paiement','','Go to payment page','',NULL,NULL,'2022-11-04 14:49:35',104),('Confirm Booking','','','تأكيد الحجز',NULL,NULL,'2022-11-04 14:50:44',104),('From','De','From','من عند',NULL,NULL,'2022-11-04 14:51:43',104),('Out of Stock','Momentanément indisponible','','إنتهى من المخزن',NULL,NULL,'2023-09-14 06:36:28',115),('Stock Update','Mis à jour stock','','',NULL,NULL,'2023-09-14 06:36:28',115),('Temporairement indisponible','','Temporarily unavailable','غير متاح مؤقتا',NULL,NULL,'2022-11-02 14:40:36',104),('Product indisponible','','Product unavailable','',NULL,NULL,'2022-11-02 14:40:36',104),('M\'alerter par mail','','Notify me by email','يخطر لي عن طريق البريد الإلكتروني',NULL,NULL,'2022-11-04 14:51:43',104),('Confirmer','','Confirmation','التأكيد',NULL,NULL,'2022-11-04 14:50:44',104),('Recevez une alerte par email dès que ce produit est à nouveau disponible','','Receive an alert by email as soon as this product is available again','تلقي تنبيه عبر البريد الإلكتروني بمجرد توفر هذا المنتج مرة أخرى',NULL,NULL,'2022-11-02 14:40:36',104),('Votre adresse email ne sera pas utilisée à d\'autres fins.','','Your email address will not be used for any other purpose.','لن يتم استخدام عنوان بريدك الإلكتروني لأي غرض آخر.',NULL,NULL,'2023-09-14 06:54:50',115),('Produit indisponible','','Product unavailable','المنتج غير متوفر',NULL,NULL,'2022-11-02 14:40:36',104),('Capacity','Capacité','','',NULL,NULL,'2022-11-04 14:50:44',104),('Champange Gold','','Champange Gold','الشمبانيا الذهب',NULL,NULL,'2022-11-04 14:50:44',104),('Vous ï¿½tes sur le point de quitter votre commande.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('subfield',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('field',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('subtype',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('type',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Start KYC',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('KYC',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Large',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('1 months commitment',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Some of required fields are missing',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Avatar',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Contact No',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Label 2','','Label','',NULL,NULL,'2022-11-04 14:51:43',104),('Total Amount','Prix total','','',NULL,NULL,'2022-11-29 09:01:11',74),('Title','Titre','','',NULL,NULL,'2019-10-09 20:26:52',1),('today','aujourd\'hui','','',NULL,NULL,'2019-10-09 20:26:52',1),('Thank you','Merci','','',NULL,NULL,'2019-10-09 20:26:51',1),('Home Delivery',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('select','choisissez','','',NULL,NULL,'2019-10-14 13:50:40',1),('---select---','--Sélectionnez--','','',NULL,NULL,'2022-11-04 14:49:35',104),('Select an option','Choisissez une option','','',NULL,NULL,'2019-10-14 13:50:40',1),('Required','Requis','','',NULL,NULL,'2019-10-09 20:26:46',1),('Réalité virtuelle','','Virtual reality','',NULL,NULL,'2019-10-09 20:26:46',1),('16 Inch',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Méthode de paiement',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Date et heure de la commande','','','',NULL,NULL,'2023-09-14 06:43:11',115),('Adresse de livraison','','Delivery address','',NULL,NULL,'2023-09-14 07:01:45',115),('Méthode de livraison',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Informations annexes',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Masquer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Afficher le détail des étapes précédentes','','Show details of previous steps','',NULL,NULL,'2023-09-14 07:01:45',115),('Historique du statut',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Référence',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Rechercher un point relais',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Livraison à domicle',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Livraison point relais',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Livraison en agence',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('16\'',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Yellow',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Purple',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Pine Green',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('2K2',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Manufacture Year',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('XL',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Local',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('32GB',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Auto',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Taxe de','','Total taxes','',NULL,NULL,'2019-10-09 20:26:51',1),('Transmission',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Imported',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('RÃ©initialiser','Réinitialisé','Reset','',NULL,NULL,'2019-10-09 20:26:46',1),('225',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Assembly',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('150',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('60',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Les prix sont affichÃ©s hors taxes','','Prices are displayed excluding taxes','',NULL,NULL,'2022-11-04 14:51:43',104),('Frost Blue',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Metal Bronze',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Phantom Black',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('64GB',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Silver',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('L',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Incgo',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Formula 1',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('MG Motors',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('اللون','Colour','Colour','',NULL,NULL,'2022-11-04 14:54:21',104),('Remax',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vivo',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('retry my luck',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('One Plus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('game over',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('try my luck',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('spin the wheel',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('I participate',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('the field is invalid',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('firstname',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Weekly','Hebdomadaire','','',NULL,NULL,'2022-11-04 14:54:21',104),('the field is required',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('lastname',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Best offer','Meilleur offre','','',NULL,NULL,'2022-11-04 14:50:44',104),('Search Results',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('see test',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('par',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('à',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('le',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('voir toutes les dépêches',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('imprimer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('lecture',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('lire plus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('discover',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('upstream speed',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('mbps',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Customer Name','','Customer Name','',NULL,NULL,'2022-11-04 14:51:14',104),('downstream speed',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('text messages',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('call time',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('months then',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('validity',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('mb',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Thank You for Shopping with Us!','Merci d\'avoir acheter avec nous','','',NULL,NULL,'2019-10-09 20:26:51',1),('','FCFA','FCFA','FCFA',NULL,NULL,NULL,NULL),('Saved','Sauvegardé','','',NULL,NULL,'2023-09-14 06:44:36',115),('in stock','','','',NULL,NULL,'2023-09-14 06:36:28',115),('Offre Suivante','','','',NULL,NULL,'2023-09-14 06:56:16',115),('Offre précédente',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('with commitment',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('forfaits',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mobile only',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('With offer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Purchase type',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('FCFAx',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('EUR','Eur','',NULL,NULL,NULL,NULL,NULL),('see all',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('ancien mot de passe','','','',NULL,NULL,'2023-09-14 07:01:45',115),('Login token expired. Refresh the page and try again',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Name',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Miss',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mr',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mrs',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Civility',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Enregistrement',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Above link will expire in 3 hours',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Kindly click the following link in order to reset your password',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Brown',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Username and password you entered does not match any account',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('** Please bring your ID to pick up your order.','','','',NULL,NULL,'2023-09-14 07:01:45',115),('* Delivery date will be confirmed by e-mail','','','',NULL,NULL,'2023-09-14 07:01:45',115),('shipping type',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('billing address',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('delivery address',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('transaction reference',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('payement method',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('date and hour of the order',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('reset filters',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('view all',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('i want it',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('remember me',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('forgot your password',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange mobile number or email address','','','',NULL,NULL,'2023-09-14 06:53:12',115),('your credentials are incorrect',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('indicate the line number or the email address designating the Orange account you wish to use','','','',NULL,NULL,'2023-09-14 06:53:12',115),('or',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('identify yourself',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('create your account',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('first visit ?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('already customer ?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('confort +',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('comment','','','',NULL,NULL,'2023-09-14 06:46:08',115),('you did not find results according to your search? Let us know so we can improve the search functionality.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('assistance',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('servicess',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Removable','Supprimable','','',NULL,NULL,'2019-10-09 20:26:46',1),('reset filter',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('recommended','','','',NULL,NULL,'2023-09-14 06:46:08',115),('top mobile',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('no results found',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('add mobile',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('displayed',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('products',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('see less',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('ratings',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('remove filters',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('price without permanence',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Wireless charging','Chargement sans fil','','',NULL,NULL,'2022-11-04 14:54:21',104),('limited quantity',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('black friday',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sign_up_site_3',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('To contact us','Pour nous contacter','','',NULL,NULL,'2019-10-09 20:26:52',1),('Billind address','Adresse de facturation','','',NULL,NULL,'2023-09-14 07:01:45',115),('Above link will expire in 24 hours',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Kindly click the following link in order to verify your account',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Dear',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Account verification',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Account info updated',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Password updated successfully',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le mot de passe doit contenir au moins un caractère et un chiffre',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Réinitialiser le mot de passe',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le mot de passe doit contenir au moins 8 caractères',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Invalid token provided',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Token is already expired. Enter your username to get a verification email again',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Forgot Password','Mot de passe oublié','','',NULL,NULL,'2022-11-04 14:51:43',104),('An email is sent with the instructions','Un email contenant les instructions vous a été envoyé','An email containing the instructions has been send','',NULL,NULL,'2022-11-04 14:49:35',104),('refill',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('top trends',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('orange number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('amount',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('recharger',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('favourite',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Reset Password','Réinitialisé le mot de passe','','',NULL,NULL,'2019-10-09 20:26:46',1),('like',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Recherche associée',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Top tendances',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('no result for',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('for',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('result',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('back to home',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('loading',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('by',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('print',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('you must accept to continue','','','',NULL,NULL,'2023-09-14 06:38:06',115),('select purpose',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('select source',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('purpose of funds',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Home','Accueil','','',NULL,NULL,'2022-11-04 14:51:43',104),('source of funds',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('amount to transfer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('please input the OM Wallet number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('How would you like to pay?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('flash sale',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Super Manufacturer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('3 mois',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mensualité',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('32Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('your browser is not compatible with video.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange App Center',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('offer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('When viewing on the map, additional mobile data is required, additional charges may be consumed on your plan.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('top of page',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('The application is unfortunately not available on iOS.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('The application is unfortunately not available on Android.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Voir ma commande','','View your order','',NULL,NULL,'2023-09-14 06:43:11',115),('Numéro de commande','','Order number','',NULL,NULL,'2023-09-14 06:53:12',115),('Homepage','Accueil','','',NULL,NULL,'2022-11-04 14:51:43',104),('Adresse e-mail/Numéro de téléphone','','Email Address/Phone Number','',NULL,NULL,'2023-09-14 07:01:45',115),('O1v','O1 Val','','',NULL,NULL,'2019-10-09 20:26:39',1),('Saisissez votre adresse email ou numéro de téléphone utilisée pour la commande ainsi que votre numéro de commande.','','Enter your email address or telephone number used for the order as well as your order number.','',NULL,NULL,'2023-09-14 07:00:19',115),('Retrouvez en ligne les détails de votre commande Orange.','','','',NULL,NULL,'2023-09-14 06:43:11',115),('Le format du numéro de commande n\'est pas valide.','','','',NULL,NULL,'2023-09-14 06:53:12',115),('L\'email/téléphone est invalide.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le numéro de commande est requis.','','The number is required.','',NULL,NULL,'2023-09-14 06:58:30',115),('128Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Blanc',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('16Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('256Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('64Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('OnePlus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Pack',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('order number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('email address',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('salut',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('contact us',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Contact our customer service, in case of new error:',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('renew the payment',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Repeat the operation by selecting another payment method.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('(price of a local call, free for Orange customers).',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('by phone at',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('by email',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Contact our customer service:',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show more videos',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('description of the season',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('template option',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('watch',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('watch details',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('look for',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('your cart is empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('send',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('mobile number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('To receive the application link by SMS, please fill in the following',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('withdrawal fees',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('transfer fees',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Send with Orange Money',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by descending OS',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by ascending OS',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by ascending brand',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by descending brand',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by descending price',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort by ascending price',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sort results',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('delete',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show more results',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('available colors',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('1 color available',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('new',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('emptying',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('corresponding to your search',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('on',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('all videos','','','',NULL,NULL,'2023-09-14 07:01:45',115),('clear',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('apply',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('operating system',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Avis clients','','Customer reviews','',NULL,NULL,'2022-11-04 14:50:44',104),('avis','','views','',NULL,NULL,'2022-11-04 14:50:44',104),('brand',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('to',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('price',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Indisponible','','Unavailable','',NULL,NULL,'2022-11-04 14:51:43',104),('view more results',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Choisir ce mobile','Acheter','Select this Mobile','',NULL,NULL,'2023-09-14 06:35:22',115),('available offers',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('offer details',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('days',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('hours',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('minutes',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('secondes',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Déjà payé',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Numendo - Card2Wallet - form','','','',NULL,NULL,'2023-09-14 06:53:12',115),('mobiles',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('matching',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('card to wallet','Card to wallet','Card to wallet','Card to wallet',NULL,NULL,'2023-01-24 08:47:31',74),('watch the video',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('free',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('by SMS',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('free applications and services',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('You will not be charged for data consumed via My Orange app to consult your personal data.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Free application and services',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('You will not be charged for data consumed via the My Orange application to consult your personal data.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Scan the QR code with your mobile or tablet',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('my orange',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('To receive the link to the application by SMS, please fill in the following item:',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('phone number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('cancel',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('to receive the application link by SMS, please fill in the following item',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('via flash code',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your browser is not compatible with the video.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your browser does not support HTML audio',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('web offer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your browser does not support HTML audio.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('top of the page',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('FCFA',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('8Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Coupon limit reached','','','',NULL,NULL,'2024-01-16 05:44:38',115),('Invalid promo','','','',NULL,NULL,'2024-01-16 05:44:03',115),('transfer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('withdrawal',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('amount sent',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('amount received',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('transfer fee',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('amount debited','','','',NULL,NULL,'2023-09-14 07:01:45',115),('exchange rate',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sent by Orange Money',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('withdrawal fee',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show on a map',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('do not warn me anymore',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('display',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('no result',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('store locator',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('adress, city...',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('search',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('services available',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('see the map',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('no results match',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show more',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('find a store',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('invalid name',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('list',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('map',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show on map',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('mobile data usage',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('do not warn me',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('cancer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('show',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('search in this area',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('option',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('*call cost per indivisible minute and in FCFA TTC + excise duty.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('A loading error has occurred. Please try again later.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Advance (months)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Find out the rates for your international calls.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('The essential','','The essential','',NULL,NULL,'2019-10-09 20:28:12',1),('filter',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('compare',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('matching your search',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('available',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Valider le paiement','','','',NULL,NULL,'2023-09-14 06:45:09',115),('CVC / CVV',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Numéro CVC / CVV non valide','','','',NULL,NULL,'2023-09-14 06:53:12',115),('frais de livraison et de paiement inclus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Choose this package','','Select this Package','',NULL,NULL,'2022-11-04 14:50:44',104),('AA',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('MM',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('La date est requise.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Date d\'expiration',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le numéro n\'est pas valide.','','','',NULL,NULL,'2023-09-14 06:53:12',115),('Nom de la carte','','Name on the Card','',NULL,NULL,'2023-09-14 06:48:49',115),('Numéro de la carte','','Card Number','',NULL,NULL,'2023-09-14 06:53:12',115),('Remise panier',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Taxe incluse',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Small',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('du panier pour un autre produit en stock','','','',NULL,NULL,'2023-09-14 06:36:28',115),('2M',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('1M',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Length',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Choisir ce produit','','Select this Product','',NULL,NULL,'2023-09-14 06:35:22',115),('M',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('S',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Red',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('64',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Blackberry Mobile',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('S\'inscrire','','Register','',NULL,NULL,'2023-03-06 12:52:07',113),('Mot de passe oublié?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('This file type is not supported. Please select another and try again.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your session is already expired',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Livraison gratuite','','Free Delivery','',NULL,NULL,'2023-09-14 06:34:25',115),('Carte bancaire','','Credit Card','',NULL,NULL,'2023-09-14 06:48:49',115),('Paiement au retrait',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Session expired',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('mois(s)','','Month(s)','',NULL,NULL,'2021-09-14 15:19:19',59),('offre(s)','','offer(s)','',NULL,NULL,'2019-10-14 13:56:39',1),('Vente flash','','Flash Sale','',NULL,NULL,'2022-11-02 14:41:48',104),('Sans','','without','',NULL,NULL,'2019-10-14 14:06:20',1),('Choisir ce forfait','','Select this Package','',NULL,NULL,'2023-09-14 06:35:22',115),('Choisir avec un mobile','','Select with a mobile','',NULL,NULL,'2023-09-14 06:35:22',115),('Détails de l\'offre','','Offer Details','',NULL,NULL,'2022-11-04 14:51:14',104),('Numéro de transaction','','Transaction number','',NULL,NULL,'2023-09-14 06:53:12',115),('Reste à payer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Commande confirmée','','Confirm Order','',NULL,NULL,'2023-09-14 07:01:46',115),('Offert','Inclus','Offer','',NULL,NULL,'2022-05-05 08:08:26',59),('Note moyenne','','Average Ratings','',NULL,NULL,'2019-10-14 13:58:53',1),('Rédiger un avis','','Write a review','',NULL,NULL,'2019-10-14 13:59:18',1),('Frais de paiement',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Frais de livraison',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Offres postpayés','','postpaid offers','',NULL,NULL,'2020-05-06 12:58:55',1),('Offres prépayées','','prepaid offers','',NULL,NULL,'2019-10-14 13:56:39',1),('correspondant à votre recherche','','matching your search','',NULL,NULL,'2022-11-04 14:51:14',104),('Afficher plus de résultats','','Show more results','',NULL,NULL,'2023-09-14 07:01:45',115),('résultat(s)','','result(s)','',NULL,NULL,'2019-10-14 14:03:49',1),('Prix seul','Prix seul','Price alone','',NULL,NULL,'2021-09-03 14:41:39',59),('mobiles correspondant à votre recherche','','mobile matching your search','',NULL,NULL,'2019-10-14 13:57:32',1),('Prix','','Price','',NULL,NULL,'2019-10-14 13:46:41',1),('Retourner sur la page d\'accueil',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Effacer','','Clear','',NULL,NULL,'2022-11-04 14:51:14',104),('couleurs disponibles','','colors available','',NULL,NULL,'2022-11-04 14:51:14',104),('couleur disponible','','color available','',NULL,NULL,'2022-11-04 14:51:14',104),('Redirection automatiquement vers la page d’accueil de notre site dans 30 secondes.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vérifiez vos spams','','Check your spam','',NULL,NULL,'2023-03-06 12:29:52',85),('Un email récapitulant votre commande vous a été envoyé.','','An email summarizing your order has been sent to you','',NULL,NULL,'2023-09-14 06:43:11',115),('Deposit','DepositFR','','',NULL,NULL,'2022-11-04 14:51:14',104),('en',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Votre commande est confirmée','','Your order is confirmed','',NULL,NULL,'2023-09-14 06:43:11',115),('Produits',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Payé',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Revenir au paiement','','Return to payment','',NULL,NULL,'2023-09-14 07:03:48',115),('Plus que <qty> articles','','First 100 items only','',NULL,NULL,'2019-12-17 13:16:44',50),('Si vous rencontrez à nouveau le même problème, merci de contacter le service client',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Merci de sélectionner un autre mode de paiement.','','','',NULL,NULL,'2023-09-14 07:04:44',115),('Votre paiement n\'a pu aboutir, veuillez renouveler votre paiement',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange Money',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange Money OBF',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Frais de paiement estimé',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Urgent - Home Delivery',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Cash on Pickup',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Cash On Delivery','','','',NULL,NULL,'2023-09-14 07:01:45',115),('Mode de paiement','','Payment Method','',NULL,NULL,'2023-09-14 07:04:44',115),('Revenir à la livraison','','Return to delivery','',NULL,NULL,'2023-09-14 07:03:48',115),('Désolé, la commande ne peut être poursuivie','','Sorry, the order cannot be continued','',NULL,NULL,'2023-09-14 07:03:12',115),('Date',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Non',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Souhaitez-vous prendre rendez-vous en boutique ?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Afficher',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ne plus m\'avertir',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('supplémentaires sont nécessaires, un surcoût sera consommé sur votre forfait.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Afficher sur une carte','','','',NULL,NULL,'2023-09-14 06:48:49',115),('Lorsque vous affichez sur la carte, des données mobiles','','When viewing on the map, mobile data','',NULL,NULL,'2023-09-14 06:48:49',115),('Une pièce d’identité vous sera demandée lors de la livraison',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('points relais pour la recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Sélectionné',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Sélectionner',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Colis livré à','','Order wil be delivered to','',NULL,NULL,'2023-09-14 07:02:24',115),('Remise code promo','','Discount Promo Code','',NULL,NULL,'2024-01-16 05:44:03',115),('points relais à proximité',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('point relais pour la recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('point relais à proximité',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('points relais disponibles',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('point relais disponible',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutiques pour la recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutique pour la recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutiques à proximité',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutiques disponibles',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutique à proximité',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('boutique disponible',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Aucun point relais n’est géolocalisé à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Aucune boutique n’est géolocalisée à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Nom non valide','','','',NULL,NULL,'2023-09-14 06:46:23',115),('Type non valide',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Rechercher une boutique',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Type de livraison',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Changer','','Change','',NULL,NULL,'2023-09-14 07:00:46',115),('Dimanche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Samedi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vendredi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Votre sélection','Votre sélection','','',NULL,NULL,'2022-11-04 14:54:21',104),('Jeudi','','THURSDAY','',NULL,NULL,'2023-09-14 06:51:49',115),('Mercredi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Fermé',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mardi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('24h/24',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ouvert',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Lundi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Horaires d\'ouverture',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Retrait sous 48h',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Store Pickup',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Standard - Home Delivery',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mode de livraison','','Delivery Method','',NULL,NULL,'2023-09-14 07:04:44',115),('Boutique directory are not available for the moment. Please choose address method or retry later.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Sorry, maps are unavailable.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Sorry, geolocalisation is not supported by your device.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Voir moins',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Quantité','','Quantity','',NULL,NULL,'2023-09-14 07:02:46',115),('Suivant','','Next','',NULL,NULL,'2023-09-14 06:56:16',115),('Pays non valide','','','',NULL,NULL,'2023-09-14 06:56:38',115),('Le pays est requis.','','','',NULL,NULL,'2023-09-14 06:56:38',115),('Pays','','Country','',NULL,NULL,'2023-09-14 06:56:38',115),('Ville non valide',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('La ville est requise.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Code postal non valide','','Postal Code is not valid','',NULL,NULL,'2023-09-14 07:01:46',115),('Le code postal est requis.','','Postal Code is required.','',NULL,NULL,'2023-09-14 06:57:19',115),('Code postal','','Postal Code','',NULL,NULL,'2023-09-14 07:01:46',115),('Complément d\'adresse','','Additional address (optional)','',NULL,NULL,'2023-09-14 06:55:05',115),('Adresse non valide','','Invalid address','',NULL,NULL,'2023-09-14 07:01:45',115),('L\'adresse est requise.','','Address is required.','',NULL,NULL,'2023-09-14 06:57:03',115),('Adresse de facturation','','Billing address','',NULL,NULL,'2023-09-14 07:01:45',115),('Orange vous propose','','Orange offers you','',NULL,NULL,'2023-09-14 06:53:41',115),('Numéro Orange','','Orange number','',NULL,NULL,'2023-09-14 06:53:12',115),('Confirmer votre adresse email','','Confirm your email address','',NULL,NULL,'2023-09-14 06:54:50',115),('Les deux adresses saisies sont différentes.','','The two addresses entered are different.','',NULL,NULL,'2023-09-14 07:00:19',115),('Je souhaite recevoir la newsletter Orange','','I would like to receive the Orange newsletter','',NULL,NULL,'2023-09-14 06:51:49',115),('L\'email est requis.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le numéro de téléphone doit avoir un format sous la forme 0XXXXXXXXX.','','The phone number should be formatted as 0XXXXXXXXX.','',NULL,NULL,'2023-09-14 06:53:12',115),('Adresse email','','Email Address','',NULL,NULL,'2023-09-14 06:54:50',115),('Numéro de téléphone','','Phone number','',NULL,NULL,'2023-09-14 06:53:12',115),('Veillez à bien indiquer votre numéro de téléphone. Nous vous appellerons pour confirmer cette commande.','','Be sure to include your telephone number. We will call you to confirm this order.','',NULL,NULL,'2023-09-14 06:53:12',115),('Je note que je dois présenter une pièce d\'identité lors de la livraison','','I note that I must present an identity document upon delivery','',NULL,NULL,'2023-09-14 06:51:49',115),('Continuer','','Continue','',NULL,NULL,'2023-09-14 06:38:06',115),('Contacts',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('La photo est requise.','','Photo is required','',NULL,NULL,'2023-09-14 06:58:47',115),('Présentation de la pièce d\'identité requise','','Presentation of required ID','',NULL,NULL,'2023-09-14 06:47:17',115),('Photo de la pièce d’identité','','Photo ID','',NULL,NULL,'2023-09-14 06:49:29',115),('Le numéro est requis.','','The number is required.','',NULL,NULL,'2023-09-14 06:58:30',115),('Numéro de pièce d\'identité','','ID Number','',NULL,NULL,'2023-09-14 06:53:12',115),('Carte de résident','','Resident ID','',NULL,NULL,'2023-09-14 07:01:45',115),('Carte d\'identité','','ID Card','',NULL,NULL,'2023-09-14 07:01:45',115),('Choisissez un type',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('results for',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('passes available','Pass disponibles','passes available','',NULL,NULL,'2022-12-01 08:58:47',74),('Veuillez choisir un type.','','','',NULL,NULL,'2023-09-14 06:35:22',115),('Type de la pièce d\'identité','','Identity type','',NULL,NULL,'2023-09-14 06:47:17',115),('Le prénom n\'est pas valide.','','','',NULL,NULL,'2023-09-14 06:46:23',115),('other amount','autre montant','other amount','',NULL,NULL,'2022-12-01 09:21:27',74),('Le prénom est requis.','','Name is required','',NULL,NULL,'2023-09-14 06:58:04',115),('Le nom n\'est pas valide.','','','',NULL,NULL,'2023-09-14 06:46:23',115),('Le nom est requis.','','Name is required','',NULL,NULL,'2023-09-14 06:58:04',115),('Nom','','Name','',NULL,NULL,'2023-09-14 06:46:23',115),('no results for',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('tax included','TVA incluse','tax included','',NULL,NULL,'2022-11-29 09:11:02',74),('amount to be paid','montant à payer','amount to be paid','',NULL,NULL,'2022-11-29 09:10:22',74),('your selection','votre sélection','your selection','',NULL,NULL,'2022-11-29 09:07:56',74),('100% secure payment','paiement 100% sécurisé','100% secure payment','',NULL,NULL,'2022-11-29 09:12:09',74),('validate','valider','validate','',NULL,NULL,'2023-09-14 06:45:09',115),('order','commander','order','',NULL,NULL,'2023-09-14 06:43:11',115),('no current selection','aucune sélection en cours','no current selection','',NULL,NULL,'2022-11-29 09:08:34',74),('promo code','code promo','promo code','',NULL,NULL,'2024-01-16 05:44:03',115),('instead of','au lieu de','instead of','',NULL,NULL,'2022-11-29 09:07:03',74),('added','ajouté','added','',NULL,NULL,'2023-09-14 07:01:45',115),('fast recharge','recharge rapide','','',NULL,NULL,'2023-02-14 13:37:49',74),('mobile number to recharge','numéro de mobile à recharger','','',NULL,NULL,'2023-09-14 06:53:12',115),('all other passes','tous les autres pass','all other passes','',NULL,NULL,'2022-12-01 09:21:27',74),('out of',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('no results',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('phone number to recharge','','','',NULL,NULL,'2023-09-14 06:53:12',115),('quick recharge','','','',NULL,NULL,'2023-02-14 13:37:49',74),('others',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange mobile number to recharge','','','',NULL,NULL,'2023-09-14 06:53:12',115),('your number','','','',NULL,NULL,'2023-09-14 06:53:12',115),('Topup your airtime',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('voucher code',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('this field is required',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('proceed',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('enter your code',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('How would you like to pay for your pass?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('proceed to payment',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('confirm order',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('summary',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('amount to pay',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('selection',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Déjà client?','','Already a Customer?','',NULL,NULL,'2023-03-06 12:32:20',85),('Nouveau client?','','New Customer','',NULL,NULL,'2023-03-06 12:32:38',85),('Souviens-toi de moi','','Remember Me','',NULL,NULL,'2023-03-06 12:51:27',113),('Bienvenue',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Gérer mon profil',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Changer le mot de passe','','Change Password','',NULL,NULL,'2023-09-14 07:01:45',115),('produit(s) correspondant à votre recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('résultat(s) correspondant à votre recherche',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Promotions','','','',NULL,NULL,'2024-01-16 05:44:03',115),('Nouveautés',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Prix croissants',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Prix décroissants',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Tous les produits',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Filtrer',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mobiwire',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Tecno',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Alcatel',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Itel',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Wiko',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Crosscall',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Huawei',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Jusqu’à',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Manufacturer Name',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Cmdc',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Maxcom',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Transsion',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('None',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Cet article a bien été ajouté à votre panier','','This product has been added to your cart','',NULL,NULL,'2023-09-14 07:11:46',115),('Continuer les achats','','Continue Shopping','',NULL,NULL,'2023-09-14 06:38:06',115),('Voir le panier','','Go to cart','',NULL,NULL,'2023-09-14 06:38:51',115),('Partager sur','','Share on','',NULL,NULL,'2023-09-14 06:36:58',115),('Voir la vidéo',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Voir plus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Merci de sélectionner un choix',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('16 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Dimensions et poids',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Dimensions H x L x W (mm x mm x mm)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Poids',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Capacité de la batterie','','','',NULL,NULL,'2023-09-14 07:01:45',115),('Autonomie en veille (heures)','','','',NULL,NULL,'2023-09-14 06:46:23',115),('Autonomie en communication (heures)','','','',NULL,NULL,'2023-09-14 06:46:23',115),('Chargement rapide','','','',NULL,NULL,'2023-09-14 07:01:45',115),('Chargement sans-fil',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Format de la carte SIM','','SIM card format','',NULL,NULL,'2023-09-14 06:48:49',115),('Multiple SIM',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Wifi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('NFC',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Bluetooth',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Autres connexions',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Partage de connexion',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('DAS',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Système d\'exploitation, écran et mémoire',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Système d\'exploitation',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Capacité mémoire (GB)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('RAM (GB)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Nombre de cœurs CPU','','','',NULL,NULL,'2023-09-14 06:46:23',115),('Mémoire extensible par MicroSD',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ecran',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Taille de l\'écran (pouces)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Résolution',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Luminosité (cd/m2)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Densité de résolution (ppi)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Capteur biométrique',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Photo',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Résolution appareil photo avant (Mpx)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Flash (technologie)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Zoom avant',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ouverture de l\'objectif','','Lens aperture','',NULL,NULL,'2023-09-14 06:51:49',115),('Résolution appareil photo arrière',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Résolution appareil photo arrière 2',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Zoom arrière',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Stabilisateur optique',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Prise casque Jack 3.5',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Prise HDMI',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Voix HD',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Fonctions',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Acceleromètre',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('GPS',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Gyroscope',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Specifications',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Quantity limit reached',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('You have reached the quantity authorized for that product',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('OK',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Stock limit reached','','','',NULL,NULL,'2023-09-14 06:36:28',115),('You have reached the maximum stock for that product','','','',NULL,NULL,'2023-09-14 06:36:28',115),('Avec forfait',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Sans forfait',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('En stock','','Stock Available','',NULL,NULL,'2023-09-14 06:36:28',115),('Promo','','','',NULL,NULL,'2024-01-16 05:44:03',115),('à partir du <start_date>',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('jusqu\'au <end_date>',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Inclus',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Choose',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Selected',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Confirm',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Recevoir une alerte sur la disponibilité du produit par email','','','',NULL,NULL,'2023-09-14 06:38:51',115),('Votre demande a bien été prise en compte.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vos coordonnées seront exclusivement utilisées dans le cadre du service « recevoir une alerte dés que le produit est disponible » et ne seront pas utilisées à d\'autres fins.','','','',NULL,NULL,'2023-09-14 06:38:51',115),('Commander','Commander','Order','',NULL,NULL,'2023-09-14 07:01:46',115),('Veuillez choisir une civilité','','','',NULL,NULL,'2023-09-14 06:35:22',115),('M.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Mme','','Mrs','',NULL,NULL,'2023-09-14 06:46:08',115),('Montant à payer','Montant à payer','Amount to be paid','المبلغ الواجب دفعه',NULL,NULL,'2022-11-29 09:10:22',74),('La civilité est requise.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Code promo','Code promo','Promo Code','',NULL,NULL,'2024-01-16 05:44:38',115),('Informations personnelles','','Personal Information','',NULL,NULL,'2023-09-14 06:45:53',115),('Valider','Valider','validate','',NULL,NULL,'2023-09-14 06:45:09',115),('Sauvegarder et quitter','','Save and exit','',NULL,NULL,'2023-09-14 06:44:36',115),('Sauvegarder','','Save','',NULL,NULL,'2023-09-14 06:44:36',115),('Password',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Cannot checkout as \'Guest\', please select a User from the dropdown.','','','',NULL,NULL,'2023-03-06 12:52:30',113),('Quitter sans sauvegarder','','','',NULL,NULL,'2023-09-14 06:44:36',115),('Renseignez votre email ci-dessous si vous souhaitez sauvegarder votre panier.','','Enter your email below if you would like to save your basket.','',NULL,NULL,'2023-09-14 07:11:46',115),('Vous êtes sur le point de quitter votre commande.','','You are about to check out your order.','',NULL,NULL,'2023-09-14 06:43:11',115),('Veuillez saisir deux fois la mï¿½me valeur.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Commande','','Order','',NULL,NULL,'2023-09-14 07:01:46',115),('Oui',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('XOF','FCFA','','','','','2022-11-04 14:54:21',104),('Are you sure you want to checkout as \'Guest\'?',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('L\'email n\'est pas valide.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Veuillez saisir deux fois la même valeur.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ce champ est non valide.','','','',NULL,NULL,'2023-09-14 07:01:45',115),('Annuler','','Cancel','',NULL,NULL,'2023-03-06 12:52:30',113),('Ce champ est requis.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Retirer','','Remove item from cart','',NULL,NULL,'2023-09-14 07:06:38',115),('de votre panier ?','','from your cart?','',NULL,NULL,'2023-09-14 07:11:46',115),('Êtes-vous sûr de vouloir retirer le produit','','Are you sure you want to remove the product','',NULL,NULL,'2023-09-14 07:06:38',115),('Retirer l\'article du panier','','Remove item from cart','',NULL,NULL,'2023-09-14 07:06:38',115),('Sauvegarder le panier','','Save Cart','',NULL,NULL,'2023-09-14 06:44:36',115),('termes et conditions de vente','','Terms & Conditions','',NULL,NULL,'2023-09-14 06:40:36',115),('Hors-taxe','','Without Tax','',NULL,NULL,'2023-09-14 06:40:18',115),('Vous devez acceptez les termes et conditions.','','You must accept the terms and conditions.','',NULL,NULL,'2023-09-14 06:40:53',115),('Total',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Entrez votre code','','Enter Promo Code','',NULL,NULL,'2024-01-16 05:44:03',115),('Actuellement indisponible',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Ajouter une unité de','','Add a unit of','',NULL,NULL,'2023-09-14 07:01:45',115),('Supprimer une unité de',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('du panier',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('256GB',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('article(s)',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vos coordonnées seront exclusivement utilisées dans le cadre du service « sauvegarder votre panier » par Orange et ne seront pas utilisées à d’autres fins.','','Your contact details will be used exclusively as part of the “save your basket” service by Orange and will not be used for other purposes.','',NULL,NULL,'2023-09-14 07:11:46',115),('Expédié à partir du 01/01/2019',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Frais de livraison à partir de',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('256',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('128',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vous devez accepter pour continuer','','','',NULL,NULL,'2023-09-14 06:38:06',115),('Paiement 100% sécurisé',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('OPPO',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Green',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Aucune sélection en cours',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('more informations',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('accept',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('see more',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('log in',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('sign in',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Log in and win points.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Orange and me',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('au lieu de','','instead of','',NULL,NULL,'2023-09-14 07:01:45',115),('reCAPTCHA is mandatory',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('512 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Infinix',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Xiaomi',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('here',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('or click',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('seconds',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your password is updated successfully. You will be redirected to homepage in',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Nouveau mot de passe',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Confirmez le mot de passe',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Le mot de passe doit contenir au moins 12 caractères',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Utilisateur',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Définir le mot de passe',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your account is verified. You will be redirected automatically to set your password or click here',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Your account is verified. You will be redirected to homepage',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Vérification de compte',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Login is already taken',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('You must select the checkbox',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Browser',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Login is not registered',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('You must fill the value',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('recommended for you','recommandé pour vous','recommended for you','',NULL,NULL,'2023-09-14 06:46:08',115),('White',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('available pass','pass disponible','available pass','',NULL,NULL,'2022-11-29 09:03:05',74),('discount','Promotion','Discount','',NULL,NULL,'2024-01-16 05:44:03',115),('Image is too large. Choose another image.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('recharge amount','montant de la recharge','','',NULL,NULL,'2023-02-14 13:37:49',74),('without commitment','Sans engagement','Without commitment','',NULL,NULL,'2022-11-04 14:54:21',104),('other recharge amount','autre montant de recharge','','',NULL,NULL,'2023-02-14 13:37:49',74),('error','Erreur','Error','',NULL,NULL,'2022-11-04 14:51:14',104),('File is too large. Choose another file.',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Grey',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('64 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('for you','Pour vous','For you','',NULL,NULL,'2022-11-04 14:51:43',104),('32 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('add','ajouter','add','',NULL,NULL,'2022-11-29 09:01:45',74),('8 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Gold',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('Appareil photo secondaire',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('256 Go',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('128GB',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('1 result','1 résultat','1 result','',NULL,NULL,'2022-11-04 14:49:35',104),('Bronze',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('by flash code','Via flash code','By flash code','',NULL,NULL,'2023-09-14 07:01:45',115),('for Android','Pour Android','For Android','',NULL,NULL,'2022-11-04 14:51:43',104),('for iOS','Pour IOS','For IOS','',NULL,NULL,'2022-11-04 14:51:43',104),('available at','Disponible','Available at','',NULL,NULL,'2022-11-04 14:49:35',104),('available on','Disponible sur','Available on','',NULL,NULL,'2022-11-04 14:49:35',104),('previous','Précédent','Previous','',NULL,NULL,'2022-11-02 14:32:14',104),('next','Suivant','Next','',NULL,NULL,'2023-09-14 06:56:16',115),('download','Télécharger','Download','',NULL,NULL,'2022-11-04 14:51:14',104);
/*!40000 ALTER TABLE `langue_msg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login`
--

DROP TABLE IF EXISTS `login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login` (
  `pid` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `language` int(11) NOT NULL DEFAULT 0,
  `pass` varchar(75) NOT NULL,
  `updated_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `access_time` datetime DEFAULT NULL,
  `access_id` varchar(50) DEFAULT NULL,
  `email_verification_code` varchar(10) DEFAULT NULL,
  `sms_verification_code` varchar(10) DEFAULT NULL,
  `sso_id` varchar(36) DEFAULT NULL,
  `last_site_id` int(11) DEFAULT NULL,
  `puid` varchar(36) NOT NULL,
  `pass_expiry` date NOT NULL,
  `is_two_auth_enabled` tinyint(1) DEFAULT 0,
  `send_email` tinyint(1) DEFAULT 0,
  `secret_key` varchar(100) DEFAULT NULL,
  `allowed_ips` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`pid`,`name`),
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
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `url` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `money_notif`
--

DROP TABLE IF EXISTS `money_notif`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `money_notif` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(100) NOT NULL,
  `notif_token` varchar(1000) NOT NULL,
  `txnid` varchar(1000) NOT NULL,
  `request_body` text NOT NULL,
  `created_ts` datetime DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `money_notif`
--

LOCK TABLES `money_notif` WRITE;
/*!40000 ALTER TABLE `money_notif` DISABLE KEYS */;
/*!40000 ALTER TABLE `money_notif` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `os`
--

DROP TABLE IF EXISTS `os`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os` (
  `code_term` int(10) unsigned NOT NULL,
  `os` varchar(50) CHARACTER SET latin1 NOT NULL,
  `os_version` varchar(50) CHARACTER SET latin1 NOT NULL,
  `date_os` varchar(50) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`code_term`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `os`
--

LOCK TABLES `os` WRITE;
/*!40000 ALTER TABLE `os` DISABLE KEYS */;
/*!40000 ALTER TABLE `os` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page` (
  `name` varchar(45) DEFAULT NULL,
  `url` varchar(150) NOT NULL DEFAULT '',
  `parent` varchar(80) DEFAULT NULL,
  `rang` int(10) unsigned DEFAULT NULL,
  `new_tab` tinyint(1) NOT NULL DEFAULT 0,
  `icon` varchar(25) DEFAULT NULL,
  `parent_icon` varchar(25) DEFAULT NULL,
  `requires_ecommerce` tinyint(1) NOT NULL DEFAULT 0,
  `menu_badge` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page`
--

LOCK TABLES `page` WRITE;
/*!40000 ALTER TABLE `page` DISABLE KEYS */;
INSERT INTO `page` VALUES ('Dashboard','/asimina_catalog/admin/gestion.jsp','',0,0,'home','',0,NULL),('FAQ stats','/asimina_menu/pages/prodfaqstats.jsp','Activity',100,0,'chevron-right','activity',0,NULL),('Pending actions','/asimina_catalog/admin/listpublish.jsp','Activity',101,0,'chevron-right','activity',0,NULL),('Stats','/asimina_menu/pages/prodstats.jsp','Activity',102,0,'chevron-right','activity',0,NULL),('Track changes','/asimina_catalog/admin/lastchanges.jsp','Activity',103,0,'chevron-right','activity',0,NULL),('Products','/asimina_catalog/admin/catalogs/catalogs.jsp','Content',302,0,'chevron-right','file-text',0,NULL),('Stores','/asimina_pages/admin/stores.jsp','Content',303,0,'chevron-right','file-text',0,NULL),('Tags','/asimina_catalog/admin/catalogs/tags.jsp','Content',310,0,'chevron-right','file-text',0,NULL),('RSS','/asimina_pages/admin/rssFeeds.jsp','Content',307,0,'chevron-right','file-text',0,NULL),('Blocks','/asimina_pages/admin/blocs.jsp','Content',309,0,'chevron-right','file-text',0,NULL),('Data import','/asimina_pages/admin/load.jsp','Tools',701,0,'chevron-right','grid',0,NULL),('Data export','/asimina_pages/admin/export.jsp','Tools',702,0,'chevron-right','grid',0,NULL),('Forms','/asimina_forms/admin/process.jsp','Content',304,0,'chevron-right','file-text',0,NULL),('Media','/asimina_pages/admin/mediaLibrary.jsp','Content',308,0,'chevron-right','file-text',0,NULL),('Pages','/asimina_pages/admin/pages.jsp','Content',301,0,'chevron-right','file-text',0,NULL),('Translations','/asimina_catalog/admin/libmsgs.jsp','Content',319,0,'chevron-right','file-text',0,NULL),('Additional fees','/asimina_catalog/admin/catalogs/commercialoffers/additionalfees/additionalfees.jsp','Marketing',401,0,'chevron-right','shopping-cart',0,NULL),('Cart rules','/asimina_catalog/admin/catalogs/commercialoffers/cartrules/promotions.jsp','Marketing',402,0,'chevron-right','shopping-cart',1,NULL),('Come-withs','/asimina_catalog/admin/catalogs/commercialoffers/comewith/comewiths.jsp','Marketing',403,0,'chevron-right','shopping-cart',0,NULL),('Promotions','/asimina_catalog/admin/catalogs/commercialoffers/promotions/promotions.jsp','Marketing',404,0,'chevron-right','shopping-cart',0,NULL),('SKUs','/asimina_catalog/admin/catalogs/product_sku_list.jsp','Marketing',405,0,'chevron-right','shopping-cart',0,NULL),('Stocks test','/asimina_catalog/admin/catalogs/productStocks.jsp','Marketing',406,0,'chevron-right','shopping-cart',1,NULL),('Stocks prod','/asimina_catalog/admin/catalogs/prodproductStocks.jsp','Marketing',407,0,'chevron-right','shopping-cart',1,NULL),('Breadcrumbs','/asimina_menu/pages/sitemap/prodbreadcrumbs.jsp','Navigation',200,0,'chevron-right','navigation',0,NULL),('Sitemap','/asimina_menu/pages/sitemap/prodsitemap.jsp','Navigation',204,0,'chevron-right','navigation',0,NULL),('Sitemap audit','/asimina_menu/pages/sitemap/prodaudit.jsp','Navigation',205,0,'chevron-right','navigation',0,NULL),('Forum Tags','/asimina_catalog/admin/catalogs/forum_tags.jsp','Content',311,0,'chevron-right','file-text',0,NULL),('Menu js','/asimina_pages/admin/menuJs.jsp','Navigation',203,0,'chevron-right','file-text',0,'BETA'),('Redirections','/asimina_menu/pages/sitemap/prodredirections.jsp','Navigation',208,0,'chevron-right','navigation',0,NULL),('Themes','/asimina_pages/admin/themes.jsp','Developer',811,0,'chevron-right','layout',0,NULL),('Clear Cache','/asimina_menu/pages/cachemanagement.jsp','',10,0,'refresh-cw','',0,NULL),('Subsidies','/asimina_catalog/admin/catalogs/commercialoffers/subsidies/subsidies.jsp','Marketing',408,0,'chevron-right','shopping-cart',0,NULL),('Portal parameters','/asimina_catalog/admin/portal_parameters.jsp','System',604,0,'chevron-right','settings',0,NULL),('Profiles','/asimina_catalog/admin/manageProfil.jsp','System',605,0,'chevron-right','settings',0,NULL),('Shop Parameters','/asimina_catalog/admin/shop_parameters.jsp','System',606,0,'chevron-right','settings',1,NULL),('Site Parameters','/asimina_menu/pages/siteparameters.jsp','System',607,0,'chevron-right','settings',0,NULL),('Users','/asimina_catalog/admin/userManagement.jsp','System',608,0,'chevron-right','settings',0,NULL),('Dandelion test','/asimina_shop/ibo.jsp','Tools',705,1,'chevron-right','grid',1,NULL),('Dandelion prod','/asimina_prodshop/ibo.jsp','Tools',706,1,'chevron-right','grid',1,NULL),('Templates','/asimina_pages/admin/blocTemplates.jsp','Developer',816,0,'chevron-right','layout',0,NULL),('Files','/asimina_pages/admin/files.jsp','Developer',831,0,'chevron-right','layout',0,NULL),('Libraries','/asimina_pages/admin/libraries.jsp','Developer',836,0,'chevron-right','layout',0,NULL),('Quantity Limits','/asimina_catalog/admin/catalogs/commercialoffers/quantitylimits/quantitylimits.jsp','Marketing',411,0,'chevron-right','shopping-cart',1,NULL),('Module Parameters','/asimina_catalog/admin/moduleparameters.jsp','System',609,0,'chevron-right','settings',0,NULL),('Page templates','/asimina_pages/admin/pageTemplates.jsp','Developer',826,0,'chevron-right','layout',0,NULL),('Clients','/asimina_menu/pages/prodclientprofilhomepage.jsp','System',611,0,'chevron-right','settings',0,NULL),('Search Forms','/asimina_forms/admin/searchforms.jsp','System',613,0,'chevron-right','settings',0,NULL),('Clients Log','/asimina_menu/pages/prodclientslog.jsp','System',612,0,'chevron-right','settings',0,NULL),('Delivery Minimums','/asimina_catalog/admin/catalogs/commercialoffers/delivery/deliverymins.jsp','Marketing',410,0,'chevron-right','shopping-cart',1,NULL),('Delivery Fees','/asimina_catalog/admin/catalogs/commercialoffers/delivery/deliveryfees.jsp','Marketing',409,0,'chevron-right','shopping-cart',1,NULL),('System templates','/asimina_pages/admin/systemTemplates.jsp','Developer',821,0,'chevron-right','layout',0,NULL),('Menus (new)','/asimina_pages/admin/menus.jsp','Navigation',202,0,'chevron-right','file-text',0,'BETA'),('Expert System V2','/asimina_expert_system/pages/v2/queries.jsp','Tools',710,0,'chevron-right','grid',0,NULL),('pages','/asimina_pages/admin/dynamicPages.jsp','Dynamic',902,0,'chevron-right','file',0,NULL),('components','/asimina_pages/admin/components.jsp','Dynamic',903,0,'chevron-right','file',0,NULL),('Accounts Blocking','/asimina_catalog/admin/blockedUserConfig.jsp','System',614,0,'chevron-right','settings',0,NULL),('Structured data','/asimina_pages/admin/structuredContents.jsp','Content',306,0,'chevron-right','file-text',0,NULL),('Trash','/asimina_catalog/admin/catalogs/trash.jsp',NULL,1001,0,'trash',NULL,0,'BETA'),('Engines Activity','/asimina_catalog/admin/catalogs/engineActivity.jsp','System',615,0,'chevron-right','settings',0,'BETA'),('Variables','/asimina_pages/admin/variables.jsp','Developer',837,0,'chevron-right','layout',0,NULL),('Games','/asimina_forms/admin/games.jsp','Content',305,0,'chevron-right','file-text',0,'BETA'),('Global Information','/asimina_pages/admin/globalData.jsp',NULL,1003,0,'globe',NULL,0,NULL),('Product parameters','/asimina_catalog/admin/catalogs/v2/products/product_parameters.jsp','System',603,0,'chevron-right','settings',0,'BETA'),('Products New','/asimina_catalog/admin/catalogs/v2/catalogs/catalogs.jsp','Content',302,0,'chevron-right','file-text',0,'BETA');
/*!40000 ALTER TABLE `page` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `page_profil` VALUES ('/',27),('/',35);
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
  `sub_url` varchar(150) NOT NULL DEFAULT '',
  UNIQUE KEY `url` (`url`,`sub_url`),
  UNIQUE KEY `url_2` (`url`,`sub_url`),
  UNIQUE KEY `url_3` (`url`,`sub_url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_sub_urls`
--

LOCK TABLES `page_sub_urls` WRITE;
/*!40000 ALTER TABLE `page_sub_urls` DISABLE KEYS */;
INSERT INTO `page_sub_urls` VALUES ('/asimina_catalog/admin/accessories.jsp','/asimina_catalog/admin/editAccessory.jsp'),('/asimina_catalog/admin/accessories.jsp','/asimina_catalog/admin/editAccessoryImages.jsp'),('/asimina_catalog/admin/accessories.jsp','/asimina_catalog/admin/editAccessoryLangs.jsp'),('/asimina_catalog/admin/catalogs/catalog.jsp','/asimina_catalog/admin/catalogs/products.jsp'),('/asimina_catalog/admin/catalogs/catalogs.jsp','/asimina_catalog/admin/catalogs/catalog.jsp'),('/asimina_catalog/admin/catalogs/catalogs.jsp','/asimina_catalog/admin/catalogs/product.jsp'),('/asimina_catalog/admin/catalogs/catalogs.jsp','/asimina_catalog/admin/catalogs/products.jsp'),('/asimina_catalog/admin/catalogs/products.jsp','/asimina_catalog/admin/catalogs/product.jsp'),('/asimina_catalog/admin/families.jsp','/asimina_catalog/admin/familie.jsp'),('/asimina_catalog/admin/gotockeditor.jsp','/asimina_ckeditor/pages/htmlPageEditor.jsp'),('/asimina_catalog/admin/gotockeditor.jsp','/asimina_ckeditor/pages/htmlPageMain.jsp'),('/asimina_catalog/admin/listquestions.jsp','/asimina_catalog/admin/answer.jsp'),('/asimina_catalog/admin/listquestions.jsp','/asimina_catalog/admin/question.jsp'),('/asimina_catalog/admin/listtarifs.jsp','/asimina_catalog/admin/tarif.jsp'),('/asimina_catalog/admin/listtarifs.jsp','/asimina_catalog/admin/tarifcategories.jsp'),('/asimina_catalog/admin/menus.jsp','/asimina_menu/pages/menudesigner.jsp'),('/asimina_catalog/admin/menus.jsp','/asimina_menu/pages/portal.jsp'),('/asimina_catalog/admin/menus.jsp','/asimina_menu/pages/previewmenu.jsp'),('/asimina_catalog/admin/menus.jsp','/asimina_menu/pages/site.jsp'),('/asimina_catalog/admin/mobiles.jsp','/asimina_catalog/admin/editMobile.jsp'),('/asimina_catalog/admin/mobiles.jsp','/asimina_catalog/admin/editMobileImages.jsp'),('/asimina_catalog/admin/mobiles.jsp','/asimina_catalog/admin/editMobileLangs.jsp'),('/asimina_catalog/admin/mobiles.jsp','/asimina_catalog/admin/editMobilePrices.jsp'),('/asimina_catalog/admin/preprodcache.jsp','/asimina_menu/pages/cachemanagement.jsp'),('/asimina_catalog/admin/preprodstats.jsp','/asimina_menu/pages/stats.jsp'),('/asimina_catalog/admin/prodcache.jsp','/asimina_menu/pages/cachemanagement.jsp?pr=1'),('/asimina_catalog/admin/prodcache.jsp','/asimina_menu/pages/prodcachemanagement.jsp'),('/asimina_catalog/admin/prodlisttarifs.jsp','/asimina_catalog/admin/prodtarif.jsp'),('/asimina_catalog/admin/prodstats.jsp','/asimina_menu/pages/prodstats.jsp'),('/asimina_menu/pages/site.jsp','/asimina_menu/pages/menudesigner.jsp'),('/asimina_menu/pages/site.jsp','/asimina_menu/pages/portal.jsp'),('/asimina_menu/pages/site.jsp','/asimina_menu/pages/previewmenu.jsp');
/*!40000 ALTER TABLE `page_sub_urls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `method` varchar(25) DEFAULT NULL,
  `displayName` varchar(50) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL,
  `enable` tinyint(4) DEFAULT NULL,
  `helpText` text DEFAULT NULL,
  `orderSeq` int(11) DEFAULT NULL,
  `subText` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`,`method`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_n_delivery_method_excluded_items`
--

DROP TABLE IF EXISTS `payment_n_delivery_method_excluded_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_n_delivery_method_excluded_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(25) NOT NULL,
  `item_id` varchar(70) NOT NULL,
  `method` varchar(50) NOT NULL,
  `method_sub_type` varchar(50) DEFAULT NULL,
  `method_type` enum('payment','delivery') NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_type_method` (`item_type`,`item_id`,`method`,`method_type`,`method_sub_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_n_delivery_method_excluded_items`
--

LOCK TABLES `payment_n_delivery_method_excluded_items` WRITE;
/*!40000 ALTER TABLE `payment_n_delivery_method_excluded_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_n_delivery_method_excluded_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `person_id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `zip_code` varchar(50) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `e_mail` varchar(50) DEFAULT NULL,
  `country_id` int(11) DEFAULT 0,
  `fax` varchar(50) DEFAULT NULL,
  `grade` varchar(100) DEFAULT NULL,
  `ag_post` int(11) DEFAULT 0,
  `archive` int(11) DEFAULT NULL,
  `home_page` varchar(255) DEFAULT NULL,
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
-- Table structure for table `person_forms`
--

DROP TABLE IF EXISTS `person_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_forms` (
  `person_id` int(11) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  PRIMARY KEY (`person_id`,`form_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_forms`
--

LOCK TABLES `person_forms` WRITE;
/*!40000 ALTER TABLE `person_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_forms` ENABLE KEYS */;
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
INSERT INTO `phases` VALUES ('tarifs','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('tarifs','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('devices','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('translations','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('translations','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('tarifs','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('tarifs','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('tarifs','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('devices','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('devices','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('devices','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('devices','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('accessories','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('accessories','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('accessories','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('accessories','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('accessories','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('faqs','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('faqs','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('faqs','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('faqs','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('faqs','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('catalogs','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('catalogs','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('catalogs','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('catalogs','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('catalogs','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('products','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('products','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('products','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('products','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('products','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('shop','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('products','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('shop','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('shop','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('faqs','publish_ordering',126,106,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('families','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('families','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('families','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('families','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('families','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('families','publish_ordering',126,106,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('resources','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('landingpages','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('landingpages','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('resources','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('resources','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('landingpages','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('landingpages','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('landingpages','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('promotions','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('promotions','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('promotions','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('promotions','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('promotions','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('promotions','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('cartrules','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('cartrules','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('cartrules','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('cartrules','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('cartrules','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('cartrules','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('additionalfees','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('additionalfees','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('additionalfees','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('additionalfees','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('additionalfees','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('additionalfees','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('comewiths','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('comewiths','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('comewiths','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('comewiths','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('comewiths','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('comewiths','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('subsidies','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('subsidies','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('subsidies','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('subsidies','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('subsidies','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('subsidies','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('deliveryfees','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('deliveryfees','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('deliveryfees','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('deliveryfees','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('deliveryfees','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('deliveryfees','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('deliverymins','cancel',204,400,NULL,NULL,'','','','','',NULL,'',1,1,'Cancel last action','ADMIN','R','O'),('deliverymins','delete',102,310,NULL,NULL,'','','','','',NULL,'',1,1,'Delete from Prod','ADMIN','R','O'),('deliverymins','deleted',319,303,NULL,NULL,'','','','','',NULL,'',1,1,'Deleted from prod','ADMIN','R','O'),('deliverymins','publish',32,115,NULL,NULL,'','','','','',NULL,'',1,1,'publish','ADMIN','R','O'),('deliverymins','published',228,137,NULL,NULL,'','','','','',NULL,'',1,1,'published','ADMIN','R','O'),('deliverymins','publish_ordering',101,134,NULL,NULL,'','','','','',NULL,'',1,1,'publish ordering','ADMIN','R','O'),('moduleparams','cancel',138,418,NULL,NULL,'','','','','',NULL,NULL,1,1,'cancel last action','ADMIN','R','O'),('moduleparams','delete',45,282,NULL,NULL,'','','','','',NULL,NULL,1,1,'delete from prod','ADMIN','R','O'),('moduleparams','deleted',250,286,NULL,NULL,'','','','','',NULL,NULL,1,1,'deleted from prod','ADMIN','R','O'),('moduleparams','publish',28,65,NULL,NULL,'','','','','',NULL,NULL,1,1,'publish','ADMIN','R','O'),('moduleparams','published',279,83,NULL,NULL,'','','','','',NULL,NULL,1,1,'published','ADMIN','R','O'),('quantitylimits','cancel',138,418,NULL,NULL,'','','','','',NULL,NULL,1,1,'cancel last action','ADMIN','R','O'),('quantitylimits','delete',45,282,NULL,NULL,'','','','','',NULL,NULL,1,1,'delete from prod','ADMIN','R','O'),('quantitylimits','deleted',250,286,NULL,NULL,'','','','','',NULL,NULL,1,1,'deleted from prod','ADMIN','R','O'),('quantitylimits','publish',28,65,NULL,NULL,'','','','','',NULL,NULL,1,1,'publish','ADMIN','R','O'),('quantitylimits','published',279,83,NULL,NULL,'','','','','',NULL,NULL,1,1,'published','ADMIN','R','O');
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
-- Table structure for table `product_answers`
--

DROP TABLE IF EXISTS `product_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) NOT NULL,
  `user` varchar(50) DEFAULT NULL,
  `answer` text DEFAULT NULL,
  `tm` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_answers`
--

LOCK TABLES `product_answers` WRITE;
/*!40000 ALTER TABLE `product_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_attribute_values`
--

DROP TABLE IF EXISTS `product_attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_attribute_values` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `cat_attrib_id` int(11) NOT NULL,
  `attribute_value` varchar(255) NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `small_text` varchar(100) NOT NULL DEFAULT '',
  `color` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_id_cat_attrib_id_attribute_value` (`product_id`,`cat_attrib_id`,`attribute_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_attribute_values`
--

LOCK TABLES `product_attribute_values` WRITE;
/*!40000 ALTER TABLE `product_attribute_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_attribute_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_comments`
--

DROP TABLE IF EXISTS `product_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(1) NOT NULL,
  `user` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `comment` text CHARACTER SET latin1 DEFAULT NULL,
  `is_guest` tinyint(4) DEFAULT 0,
  `tm` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_comments`
--

LOCK TABLES `product_comments` WRITE;
/*!40000 ALTER TABLE `product_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_descriptions`
--

DROP TABLE IF EXISTS `product_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_descriptions` (
  `product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `seo` varchar(500) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `main_features` text DEFAULT NULL,
  `video_url` varchar(1500) NOT NULL DEFAULT '',
  `essentials_alignment` varchar(100) NOT NULL COMMENT 'comes from constants in cleandb_common',
  `seo_title` varchar(500) NOT NULL DEFAULT '',
  `seo_canonical_url` varchar(1000) NOT NULL DEFAULT '',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  `page_template_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`product_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_descriptions`
--

LOCK TABLES `product_descriptions` WRITE;
/*!40000 ALTER TABLE `product_descriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_descriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_essential_blocks`
--

DROP TABLE IF EXISTS `product_essential_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_essential_blocks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `block_text` varchar(4000) NOT NULL,
  `file_name` varchar(500) DEFAULT NULL,
  `actual_file_name` varchar(500) CHARACTER SET latin1 DEFAULT NULL,
  `image_label` varchar(100) DEFAULT NULL,
  `order_seq` int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_essential_blocks`
--

LOCK TABLES `product_essential_blocks` WRITE;
/*!40000 ALTER TABLE `product_essential_blocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_essential_blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_images` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `image_file_name` varchar(500) NOT NULL,
  `image_label` varchar(500) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `langue_id` int(1) DEFAULT NULL COMMENT 'for previous compatibility this is nullable field language for which the resource was added',
  `actual_file_name` varchar(500) DEFAULT NULL COMMENT 'name of the file that was actually uploaded',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_link`
--

DROP TABLE IF EXISTS `product_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stock` int(11) NOT NULL DEFAULT 0,
  `resources` text NOT NULL COMMENT 'resource names for services commma seperated ',
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_link`
--

LOCK TABLES `product_link` WRITE;
/*!40000 ALTER TABLE `product_link` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_link` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_question_clients`
--

DROP TABLE IF EXISTS `product_question_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_question_clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `question_uuid` varchar(50) NOT NULL,
  `client_uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_client` (`client_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_question_clients`
--

LOCK TABLES `product_question_clients` WRITE;
/*!40000 ALTER TABLE `product_question_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_question_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_questions`
--

DROP TABLE IF EXISTS `product_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user` varchar(50) DEFAULT NULL,
  `question` text DEFAULT NULL,
  `is_guest` tinyint(4) DEFAULT 0,
  `tm` timestamp NULL DEFAULT current_timestamp(),
  `email_sent` tinyint(4) DEFAULT 0,
  `question_uuid` varchar(50) DEFAULT NULL,
  `menu_uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_questions`
--

LOCK TABLES `product_questions` WRITE;
/*!40000 ALTER TABLE `product_questions` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_relationship`
--

DROP TABLE IF EXISTS `product_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_relationship` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `related_product_id` int(11) NOT NULL,
  `relationship_type` enum('mandatory','suggested') NOT NULL,
  `parent_price` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_relation` (`product_id`,`related_product_id`,`relationship_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_relationship`
--

LOCK TABLES `product_relationship` WRITE;
/*!40000 ALTER TABLE `product_relationship` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_relationship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_skus`
--

DROP TABLE IF EXISTS `product_skus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_skus` (
  `product_id` int(11) NOT NULL,
  `attribute_values` varchar(300) NOT NULL,
  `sku` varchar(100) NOT NULL DEFAULT '0',
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_values`),
  UNIQUE KEY `uk_sku` (`sku`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_skus`
--

LOCK TABLES `product_skus` WRITE;
/*!40000 ALTER TABLE `product_skus` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_skus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_stocks`
--

DROP TABLE IF EXISTS `product_stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_stocks` (
  `product_id` int(11) NOT NULL,
  `attribute_values` varchar(300) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `resources` text NOT NULL COMMENT 'resource names for services comma seperated',
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_values`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_stocks`
--

LOCK TABLES `product_stocks` WRITE;
/*!40000 ALTER TABLE `product_stocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_tabs`
--

DROP TABLE IF EXISTS `product_tabs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_tabs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `name` varchar(500) DEFAULT NULL,
  `content` text CHARACTER SET utf8 DEFAULT NULL,
  `order_seq` tinyint(3) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_tabs`
--

LOCK TABLES `product_tabs` WRITE;
/*!40000 ALTER TABLE `product_tabs` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_tabs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_tags`
--

DROP TABLE IF EXISTS `product_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_tags` (
  `product_id` int(11) NOT NULL,
  `tag_id` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`product_id`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_tags`
--

LOCK TABLES `product_tags` WRITE;
/*!40000 ALTER TABLE `product_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_types`
--

DROP TABLE IF EXISTS `product_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_types` (
  `name` varchar(50) DEFAULT NULL,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_types`
--

LOCK TABLES `product_types` WRITE;
/*!40000 ALTER TABLE `product_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_types_v2`
--

DROP TABLE IF EXISTS `product_types_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_types_v2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `type_name` varchar(150) NOT NULL,
  `template_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_site` (`type_name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_types_v2`
--

LOCK TABLES `product_types_v2` WRITE;
/*!40000 ALTER TABLE `product_types_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_types_v2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_v2_categories_and_attributes`
--

DROP TABLE IF EXISTS `product_v2_categories_and_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_v2_categories_and_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `reference_uuid` varchar(36) NOT NULL,
  `product_type_uuid` varchar(36) NOT NULL,
  `reference_type` enum('attribute','category') NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_v2_categories_and_attributes`
--

LOCK TABLES `product_v2_categories_and_attributes` WRITE;
/*!40000 ALTER TABLE `product_v2_categories_and_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_v2_categories_and_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_v2_specifications`
--

DROP TABLE IF EXISTS `product_v2_specifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_v2_specifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `product_type_uuid` varchar(36) NOT NULL,
  `data_entry_type` enum('manual','icecat') NOT NULL DEFAULT 'manual',
  `data_type` enum('free','json') DEFAULT NULL,
  `specification` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_v2_specifications`
--

LOCK TABLES `product_v2_specifications` WRITE;
/*!40000 ALTER TABLE `product_v2_specifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_v2_specifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variant_details`
--

DROP TABLE IF EXISTS `product_variant_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_variant_details` (
  `product_variant_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `name` varchar(255) DEFAULT NULL,
  `main_features` text DEFAULT NULL,
  `action_button_desktop` varchar(75) DEFAULT NULL,
  `action_button_desktop_url` varchar(255) DEFAULT NULL,
  `action_button_desktop_url_opentype` varchar(30) DEFAULT 'same_window',
  `action_button_mobile` varchar(75) DEFAULT NULL,
  `action_button_mobile_url` varchar(255) DEFAULT NULL,
  `action_button_mobile_url_opentype` varchar(30) DEFAULT 'same_window',
  PRIMARY KEY (`product_variant_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variant_details`
--

LOCK TABLES `product_variant_details` WRITE;
/*!40000 ALTER TABLE `product_variant_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variant_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variant_ref`
--

DROP TABLE IF EXISTS `product_variant_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_variant_ref` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_variant_id` int(11) unsigned NOT NULL,
  `cat_attrib_id` int(11) unsigned NOT NULL,
  `catalog_attribute_value_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_variant_ref` (`product_variant_id`,`cat_attrib_id`,`catalog_attribute_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variant_ref`
--

LOCK TABLES `product_variant_ref` WRITE;
/*!40000 ALTER TABLE `product_variant_ref` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variant_ref` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variant_resources`
--

DROP TABLE IF EXISTS `product_variant_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_variant_resources` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_variant_id` int(11) unsigned NOT NULL,
  `type` enum('image','video') NOT NULL DEFAULT 'image',
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `path` varchar(500) NOT NULL COMMENT 'url ot disk file name',
  `actual_file_name` varchar(500) DEFAULT NULL COMMENT 'name of the file that was actually uploaded',
  `label` varchar(100) DEFAULT NULL,
  `sort_order` tinyint(3) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variant_resources`
--

LOCK TABLES `product_variant_resources` WRITE;
/*!40000 ALTER TABLE `product_variant_resources` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variant_resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_variants` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL COMMENT 'we need product_id as it will make easy to delete and also there will be variants which will not be created make on product attribute values',
  `uuid` varchar(100) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  `is_default` tinyint(4) NOT NULL DEFAULT 0,
  `is_show_price` tinyint(1) NOT NULL DEFAULT 1,
  `price` decimal(10,2) NOT NULL,
  `frequency` varchar(20) DEFAULT NULL COMMENT 'this comes from commons.constants product_variant_frequency',
  `commitment` varchar(20) DEFAULT NULL COMMENT 'this comes from commons.constats for parent_key depending upon the frequency selected',
  `stock` int(11) unsigned NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `sticker` varchar(100) DEFAULT NULL,
  `order_seq` int(10) NOT NULL DEFAULT 1,
  `stock_thresh` int(11) unsigned NOT NULL DEFAULT 0,
  `ean` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_variants_uuid` (`uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `products`
--

DROP TABLE IF EXISTS `products`;
/*!50001 DROP VIEW IF EXISTS `products`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `products` (
  `id` tinyint NOT NULL,
  `catalog_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `link_id` tinyint NOT NULL,
  `migrated_id` tinyint NOT NULL,
  `is_new` tinyint NOT NULL,
  `show_basket` tinyint NOT NULL,
  `show_quickbuy` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `image_name` tinyint NOT NULL,
  `image_actual_name` tinyint NOT NULL,
  `product_type` tinyint NOT NULL,
  `product_type_custom` tinyint NOT NULL,
  `brand_name` tinyint NOT NULL,
  `lang_1_name` tinyint NOT NULL,
  `lang_2_name` tinyint NOT NULL,
  `lang_3_name` tinyint NOT NULL,
  `lang_4_name` tinyint NOT NULL,
  `lang_5_name` tinyint NOT NULL,
  `lang_1_summary` tinyint NOT NULL,
  `lang_2_summary` tinyint NOT NULL,
  `lang_3_summary` tinyint NOT NULL,
  `lang_4_summary` tinyint NOT NULL,
  `lang_5_summary` tinyint NOT NULL,
  `lang_1_features` tinyint NOT NULL,
  `lang_2_features` tinyint NOT NULL,
  `lang_3_features` tinyint NOT NULL,
  `lang_4_features` tinyint NOT NULL,
  `lang_5_features` tinyint NOT NULL,
  `lang_1_listing_tab` tinyint NOT NULL,
  `lang_2_listing_tab` tinyint NOT NULL,
  `lang_3_listing_tab` tinyint NOT NULL,
  `lang_4_listing_tab` tinyint NOT NULL,
  `lang_5_listing_tab` tinyint NOT NULL,
  `lang_1_meta_keywords` tinyint NOT NULL,
  `lang_2_meta_keywords` tinyint NOT NULL,
  `lang_3_meta_keywords` tinyint NOT NULL,
  `lang_4_meta_keywords` tinyint NOT NULL,
  `lang_5_meta_keywords` tinyint NOT NULL,
  `lang_1_meta_description` tinyint NOT NULL,
  `lang_2_meta_description` tinyint NOT NULL,
  `lang_3_meta_description` tinyint NOT NULL,
  `lang_4_meta_description` tinyint NOT NULL,
  `lang_5_meta_description` tinyint NOT NULL,
  `price` tinyint NOT NULL,
  `price_sent` tinyint NOT NULL,
  `currency` tinyint NOT NULL,
  `currency_frequency` tinyint NOT NULL,
  `combo_prices` tinyint NOT NULL,
  `discount_prices` tinyint NOT NULL,
  `bundle_prices` tinyint NOT NULL,
  `installment_options` tinyint NOT NULL,
  `promo_price` tinyint NOT NULL,
  `stock` tinyint NOT NULL,
  `payment_online` tinyint NOT NULL,
  `payment_cash_on_delivery` tinyint NOT NULL,
  `primary_resource` tinyint NOT NULL,
  `secondary_resource` tinyint NOT NULL,
  `service_duration` tinyint NOT NULL,
  `service_gap` tinyint NOT NULL,
  `service_max_slots` tinyint NOT NULL,
  `service_start_time` tinyint NOT NULL,
  `service_end_time` tinyint NOT NULL,
  `service_available_start_time` tinyint NOT NULL,
  `service_available_days` tinyint NOT NULL,
  `service_schedule` tinyint NOT NULL,
  `service_resources` tinyint NOT NULL,
  `subscription_require_email` tinyint NOT NULL,
  `subscription_require_phone` tinyint NOT NULL,
  `subscription_recurring` tinyint NOT NULL,
  `lang_1_currency` tinyint NOT NULL,
  `lang_2_currency` tinyint NOT NULL,
  `lang_3_currency` tinyint NOT NULL,
  `lang_4_currency` tinyint NOT NULL,
  `lang_5_currency` tinyint NOT NULL,
  `lang_1_currency_freq` tinyint NOT NULL,
  `lang_2_currency_freq` tinyint NOT NULL,
  `lang_3_currency_freq` tinyint NOT NULL,
  `lang_4_currency_freq` tinyint NOT NULL,
  `lang_5_currency_freq` tinyint NOT NULL,
  `allow_ratings` tinyint NOT NULL,
  `allow_comments` tinyint NOT NULL,
  `allow_complaints` tinyint NOT NULL,
  `allow_questions` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `show_store_locator` tinyint NOT NULL,
  `cart_url` tinyint NOT NULL,
  `cart_prod_url` tinyint NOT NULL,
  `cart_url_params` tinyint NOT NULL,
  `store_locator_url` tinyint NOT NULL,
  `store_locator_prod_url` tinyint NOT NULL,
  `store_locator_url_params` tinyint NOT NULL,
  `familie_id` tinyint NOT NULL,
  `lang_1_pricesent` tinyint NOT NULL,
  `lang_2_pricesent` tinyint NOT NULL,
  `lang_3_pricesent` tinyint NOT NULL,
  `lang_4_pricesent` tinyint NOT NULL,
  `lang_5_pricesent` tinyint NOT NULL,
  `product_uuid` tinyint NOT NULL,
  `rating_score` tinyint NOT NULL,
  `rating_count` tinyint NOT NULL,
  `invoice_nature` tinyint NOT NULL,
  `app_id` tinyint NOT NULL,
  `color` tinyint NOT NULL,
  `pack_details` tinyint NOT NULL,
  `import_source` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `device_type` tinyint NOT NULL,
  `sort_variant` tinyint NOT NULL,
  `first_publish_on` tinyint NOT NULL,
  `select_variant_by` tinyint NOT NULL,
  `html_variant` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL,
  `product_definition_id` tinyint NOT NULL,
  `product_version` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `products_definition`
--

DROP TABLE IF EXISTS `products_definition`;
/*!50001 DROP VIEW IF EXISTS `products_definition`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `products_definition` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `save_type` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `url` tinyint NOT NULL,
  `title` tinyint NOT NULL,
  `meta_description` tinyint NOT NULL,
  `product_type` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `catalog_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `piblish_ts` tinyint NOT NULL,
  `piblish_by` tinyint NOT NULL,
  `to_publish` tinyint NOT NULL,
  `created_ts` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_ts` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `products_definition_tbl`
--

DROP TABLE IF EXISTS `products_definition_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_definition_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `save_type` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `url` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `meta_description` text NOT NULL,
  `product_type` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `catalog_id` int(11) NOT NULL,
  `folder_id` int(11) DEFAULT NULL,
  `piblish_ts` datetime DEFAULT NULL,
  `piblish_by` int(11) DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_key` (`name`,`site_id`,`catalog_id`,`folder_id`,`is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_definition_tbl`
--

LOCK TABLES `products_definition_tbl` WRITE;
/*!40000 ALTER TABLE `products_definition_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_definition_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `products_folders`
--

DROP TABLE IF EXISTS `products_folders`;
/*!50001 DROP VIEW IF EXISTS `products_folders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `products_folders` (
  `id` tinyint NOT NULL,
  `uuid` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `catalog_id` tinyint NOT NULL,
  `parent_folder_id` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `products_folders_details`
--

DROP TABLE IF EXISTS `products_folders_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_folders_details` (
  `folder_id` int(11) unsigned NOT NULL,
  `langue_id` int(1) unsigned NOT NULL,
  `path_prefix` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`folder_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_folders_details`
--

LOCK TABLES `products_folders_details` WRITE;
/*!40000 ALTER TABLE `products_folders_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_folders_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `products_folders_lang_path`
--

DROP TABLE IF EXISTS `products_folders_lang_path`;
/*!50001 DROP VIEW IF EXISTS `products_folders_lang_path`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `products_folders_lang_path` (
  `site_id` tinyint NOT NULL,
  `folder_id` tinyint NOT NULL,
  `langue_id` tinyint NOT NULL,
  `concat_path` tinyint NOT NULL,
  `folder_level` tinyint NOT NULL,
  `path1` tinyint NOT NULL,
  `path2` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `products_folders_tbl`
--

DROP TABLE IF EXISTS `products_folders_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_folders_tbl` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL DEFAULT uuid(),
  `name` varchar(300) NOT NULL,
  `site_id` int(10) unsigned NOT NULL DEFAULT 0,
  `catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  `parent_folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `folder_level` int(11) DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_products_folders` (`is_deleted`,`site_id`,`catalog_id`,`name`,`parent_folder_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_folders_tbl`
--

LOCK TABLES `products_folders_tbl` WRITE;
/*!40000 ALTER TABLE `products_folders_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_folders_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_meta_tags`
--

DROP TABLE IF EXISTS `products_meta_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_meta_tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `langue_id` int(11) NOT NULL,
  `meta_name` varchar(100) NOT NULL DEFAULT '',
  `content` varchar(250) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_meta_tags`
--

LOCK TABLES `products_meta_tags` WRITE;
/*!40000 ALTER TABLE `products_meta_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_meta_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_tbl`
--

DROP TABLE IF EXISTS `products_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `catalog_id` int(10) NOT NULL,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `link_id` int(11) DEFAULT NULL COMMENT 'product_link fk , for linked products',
  `migrated_id` varchar(500) DEFAULT NULL COMMENT 'original id from migrated table',
  `is_new` tinyint(1) NOT NULL DEFAULT 0,
  `show_basket` tinyint(1) NOT NULL DEFAULT 0,
  `show_quickbuy` tinyint(1) NOT NULL DEFAULT 0,
  `order_seq` int(10) DEFAULT NULL,
  `image_name` varchar(100) DEFAULT NULL,
  `image_actual_name` varchar(255) DEFAULT NULL,
  `product_type` varchar(100) NOT NULL DEFAULT 'product',
  `product_type_custom` varchar(500) DEFAULT NULL,
  `brand_name` varchar(100) DEFAULT NULL,
  `lang_1_name` varchar(100) DEFAULT NULL,
  `lang_2_name` varchar(100) DEFAULT NULL,
  `lang_3_name` varchar(100) DEFAULT NULL,
  `lang_4_name` varchar(100) DEFAULT NULL,
  `lang_5_name` varchar(100) DEFAULT NULL,
  `lang_1_summary` text DEFAULT NULL,
  `lang_2_summary` text DEFAULT NULL,
  `lang_3_summary` text DEFAULT NULL,
  `lang_4_summary` text DEFAULT NULL,
  `lang_5_summary` text DEFAULT NULL,
  `lang_1_features` text DEFAULT NULL,
  `lang_2_features` text DEFAULT NULL,
  `lang_3_features` text DEFAULT NULL,
  `lang_4_features` text DEFAULT NULL,
  `lang_5_features` text DEFAULT NULL,
  `lang_1_listing_tab` varchar(255) DEFAULT NULL,
  `lang_2_listing_tab` varchar(255) DEFAULT NULL,
  `lang_3_listing_tab` varchar(255) DEFAULT NULL,
  `lang_4_listing_tab` varchar(255) DEFAULT NULL,
  `lang_5_listing_tab` varchar(255) DEFAULT NULL,
  `lang_1_meta_keywords` text DEFAULT NULL,
  `lang_2_meta_keywords` text DEFAULT NULL,
  `lang_3_meta_keywords` text DEFAULT NULL,
  `lang_4_meta_keywords` text DEFAULT NULL,
  `lang_5_meta_keywords` text DEFAULT NULL,
  `lang_1_meta_description` text DEFAULT NULL,
  `lang_2_meta_description` text DEFAULT NULL,
  `lang_3_meta_description` text DEFAULT NULL,
  `lang_4_meta_description` text DEFAULT NULL,
  `lang_5_meta_description` text DEFAULT NULL,
  `price` text DEFAULT NULL,
  `price_sent` text DEFAULT NULL,
  `currency` text DEFAULT NULL,
  `currency_frequency` text DEFAULT NULL,
  `combo_prices` text DEFAULT NULL,
  `discount_prices` text DEFAULT NULL COMMENT 'discount (fixed or percentage)',
  `bundle_prices` text DEFAULT NULL,
  `installment_options` text DEFAULT NULL,
  `promo_price` text DEFAULT NULL,
  `stock` int(10) DEFAULT NULL,
  `payment_online` tinyint(1) DEFAULT 0,
  `payment_cash_on_delivery` tinyint(1) DEFAULT 0,
  `primary_resource` varchar(500) NOT NULL DEFAULT '',
  `secondary_resource` varchar(500) NOT NULL DEFAULT '',
  `service_duration` int(10) DEFAULT NULL COMMENT 'in minutes , multiple of 15',
  `service_gap` int(11) DEFAULT 0 COMMENT 'in minutes',
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max number of slots per service booking',
  `service_start_time` int(10) DEFAULT NULL COMMENT 'minutes since midnight',
  `service_end_time` int(10) DEFAULT NULL COMMENT 'minutes since midnight',
  `service_available_start_time` varchar(20) NOT NULL DEFAULT '00,15,30,45' COMMENT 'allowed starting time',
  `service_available_days` varchar(50) DEFAULT NULL,
  `service_schedule` text DEFAULT NULL COMMENT 'per day schedule in json format',
  `service_resources` text DEFAULT NULL COMMENT 'comma-separated list of secondary resources',
  `subscription_require_email` tinyint(1) DEFAULT 0,
  `subscription_require_phone` tinyint(1) DEFAULT 0,
  `subscription_recurring` enum('no','daily','weekly','monthly','yearly') NOT NULL DEFAULT 'no',
  `lang_1_currency` varchar(5) DEFAULT NULL,
  `lang_2_currency` varchar(5) DEFAULT NULL,
  `lang_3_currency` varchar(5) DEFAULT NULL,
  `lang_4_currency` varchar(5) DEFAULT NULL,
  `lang_5_currency` varchar(5) DEFAULT NULL,
  `lang_1_currency_freq` varchar(50) DEFAULT NULL,
  `lang_2_currency_freq` varchar(50) DEFAULT NULL,
  `lang_3_currency_freq` varchar(50) DEFAULT NULL,
  `lang_4_currency_freq` varchar(50) DEFAULT NULL,
  `lang_5_currency_freq` varchar(50) DEFAULT NULL,
  `allow_ratings` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `allow_comments` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
  `allow_complaints` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `show_store_locator` tinyint(1) NOT NULL DEFAULT 0,
  `cart_url` text DEFAULT NULL,
  `cart_prod_url` text DEFAULT NULL,
  `cart_url_params` text DEFAULT NULL,
  `store_locator_url` text DEFAULT NULL,
  `store_locator_prod_url` text DEFAULT NULL,
  `store_locator_url_params` text DEFAULT NULL,
  `familie_id` int(11) NOT NULL DEFAULT 0,
  `lang_1_pricesent` varchar(255) DEFAULT NULL,
  `lang_2_pricesent` varchar(255) DEFAULT NULL,
  `lang_3_pricesent` varchar(255) DEFAULT NULL,
  `lang_4_pricesent` varchar(255) DEFAULT NULL,
  `lang_5_pricesent` varchar(255) DEFAULT NULL,
  `product_uuid` varchar(50) NOT NULL,
  `rating_score` int(11) DEFAULT NULL,
  `rating_count` int(11) DEFAULT NULL,
  `invoice_nature` varchar(100) NOT NULL DEFAULT '',
  `app_id` varchar(36) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `pack_details` text DEFAULT NULL,
  `import_source` varchar(50) DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `device_type` varchar(50) DEFAULT NULL,
  `sort_variant` char(5) NOT NULL DEFAULT 'cu',
  `first_publish_on` datetime DEFAULT NULL,
  `select_variant_by` enum('attributes','image') NOT NULL DEFAULT 'attributes',
  `html_variant` enum('all','anonymous','logged') NOT NULL DEFAULT 'all',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `product_definition_id` int(11) DEFAULT NULL,
  `product_version` varchar(10) NOT NULL DEFAULT 'V1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_uuid` (`product_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_tbl`
--

LOCK TABLES `products_tbl` WRITE;
/*!40000 ALTER TABLE `products_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_tbl_uuid`
--

DROP TABLE IF EXISTS `products_tbl_uuid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_tbl_uuid` (
  `id` int(11) NOT NULL DEFAULT 0,
  `catalog_id` int(10) NOT NULL,
  `folder_id` int(11) unsigned NOT NULL DEFAULT 0,
  `link_id` int(11) DEFAULT NULL COMMENT 'product_link fk , for linked products',
  `migrated_id` varchar(500) CHARACTER SET utf8 DEFAULT NULL COMMENT 'original id from migrated table',
  `is_new` tinyint(1) NOT NULL DEFAULT 0,
  `show_basket` tinyint(1) NOT NULL DEFAULT 0,
  `show_quickbuy` tinyint(1) NOT NULL DEFAULT 0,
  `order_seq` int(10) DEFAULT NULL,
  `image_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `image_actual_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `product_type` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT 'product',
  `product_type_custom` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `brand_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_name` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_summary` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_summary` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_summary` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_summary` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_summary` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_features` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_features` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_features` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_features` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_features` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_listing_tab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_listing_tab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_listing_tab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_listing_tab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_listing_tab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_meta_keywords` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_meta_keywords` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_meta_keywords` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_meta_keywords` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_meta_keywords` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_meta_description` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_meta_description` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_meta_description` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_meta_description` text CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_meta_description` text CHARACTER SET utf8 DEFAULT NULL,
  `price` text CHARACTER SET utf8 DEFAULT NULL,
  `price_sent` text CHARACTER SET utf8 DEFAULT NULL,
  `currency` text CHARACTER SET utf8 DEFAULT NULL,
  `currency_frequency` text CHARACTER SET utf8 DEFAULT NULL,
  `combo_prices` text CHARACTER SET utf8 DEFAULT NULL,
  `discount_prices` text CHARACTER SET utf8 DEFAULT NULL COMMENT 'discount (fixed or percentage)',
  `bundle_prices` text CHARACTER SET utf8 DEFAULT NULL,
  `installment_options` text CHARACTER SET utf8 DEFAULT NULL,
  `promo_price` text CHARACTER SET utf8 DEFAULT NULL,
  `stock` int(10) DEFAULT NULL,
  `payment_online` tinyint(1) DEFAULT 0,
  `payment_cash_on_delivery` tinyint(1) DEFAULT 0,
  `primary_resource` varchar(500) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `secondary_resource` varchar(500) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `service_duration` int(10) DEFAULT NULL COMMENT 'in minutes , multiple of 15',
  `service_gap` int(11) DEFAULT 0 COMMENT 'in minutes',
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max number of slots per service booking',
  `service_start_time` int(10) DEFAULT NULL COMMENT 'minutes since midnight',
  `service_end_time` int(10) DEFAULT NULL COMMENT 'minutes since midnight',
  `service_available_start_time` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '00,15,30,45' COMMENT 'allowed starting time',
  `service_available_days` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `service_schedule` text CHARACTER SET utf8 DEFAULT NULL COMMENT 'per day schedule in json format',
  `service_resources` text CHARACTER SET utf8 DEFAULT NULL COMMENT 'comma-separated list of secondary resources',
  `subscription_require_email` tinyint(1) DEFAULT 0,
  `subscription_require_phone` tinyint(1) DEFAULT 0,
  `subscription_recurring` enum('no','daily','weekly','monthly','yearly') CHARACTER SET utf8 NOT NULL DEFAULT 'no',
  `lang_1_currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `lang_1_currency_freq` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_currency_freq` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_currency_freq` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_currency_freq` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_currency_freq` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `allow_ratings` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `allow_comments` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
  `allow_complaints` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=logged-in users  , 2= all users',
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `show_store_locator` tinyint(1) NOT NULL DEFAULT 0,
  `cart_url` text CHARACTER SET utf8 DEFAULT NULL,
  `cart_prod_url` text CHARACTER SET utf8 DEFAULT NULL,
  `cart_url_params` text CHARACTER SET utf8 DEFAULT NULL,
  `store_locator_url` text CHARACTER SET utf8 DEFAULT NULL,
  `store_locator_prod_url` text CHARACTER SET utf8 DEFAULT NULL,
  `store_locator_url_params` text CHARACTER SET utf8 DEFAULT NULL,
  `familie_id` int(11) NOT NULL DEFAULT 0,
  `lang_1_pricesent` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_2_pricesent` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_3_pricesent` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_4_pricesent` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `lang_5_pricesent` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `product_uuid` varchar(50) CHARACTER SET utf8 NOT NULL,
  `rating_score` int(11) DEFAULT NULL,
  `rating_count` int(11) DEFAULT NULL,
  `invoice_nature` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `app_id` varchar(36) CHARACTER SET utf8 DEFAULT NULL,
  `color` varchar(7) CHARACTER SET utf8 DEFAULT NULL,
  `pack_details` text CHARACTER SET utf8 DEFAULT NULL,
  `import_source` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 1,
  `device_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sort_variant` char(5) CHARACTER SET utf8 NOT NULL DEFAULT 'cu',
  `first_publish_on` datetime DEFAULT NULL,
  `select_variant_by` enum('attributes','image') CHARACTER SET utf8 NOT NULL DEFAULT 'attributes',
  `html_variant` enum('all','anonymous','logged') CHARACTER SET utf8 NOT NULL DEFAULT 'all',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_tbl_uuid`
--

LOCK TABLES `products_tbl_uuid` WRITE;
/*!40000 ALTER TABLE `products_tbl_uuid` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_tbl_uuid` ENABLE KEYS */;
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
  `bannedPhases` text CHARACTER SET latin1 DEFAULT NULL,
  `home_page` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `color` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `assign_site` tinyint(1) NOT NULL DEFAULT 1,
  `is_webmaster` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`profil_id`)
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profil`
--

LOCK TABLES `profil` WRITE;
/*!40000 ALTER TABLE `profil` DISABLE KEYS */;
INSERT INTO `profil` VALUES (27,'ADMIN','admin',NULL,NULL,NULL,NULL,0,0),(31,'TEST_SITE_ACCESS','Test site access',NULL,NULL,NULL,NULL,0,0),(32,'PROD_SITE_ACCESS','Production site access',NULL,NULL,NULL,NULL,0,0),(35,'SUPER_ADMIN','Super Admin',NULL,NULL,NULL,NULL,0,0);
/*!40000 ALTER TABLE `profil` ENABLE KEYS */;
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
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
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
-- Temporary table structure for view `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!50001 DROP VIEW IF EXISTS `promotions`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `promotions` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `flash_sale` tinyint NOT NULL,
  `flash_sale_quantity` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `discount_type` tinyint NOT NULL,
  `discount_value` tinyint NOT NULL,
  `duration` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `lang_1_title` tinyint NOT NULL,
  `lang_2_title` tinyint NOT NULL,
  `lang_3_title` tinyint NOT NULL,
  `lang_4_title` tinyint NOT NULL,
  `lang_5_title` tinyint NOT NULL,
  `frequency` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promotions_rules`
--

DROP TABLE IF EXISTS `promotions_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotions_rules` (
  `promotion_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions_rules`
--

LOCK TABLES `promotions_rules` WRITE;
/*!40000 ALTER TABLE `promotions_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions_tbl`
--

DROP TABLE IF EXISTS `promotions_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotions_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `flash_sale` varchar(10) NOT NULL,
  `flash_sale_quantity` int(11) DEFAULT NULL,
  `visible_to` varchar(10) NOT NULL,
  `discount_type` varchar(10) NOT NULL,
  `discount_value` varchar(10) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `lang_1_description` text DEFAULT NULL,
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  `lang_1_title` varchar(500) DEFAULT NULL,
  `lang_2_title` varchar(500) DEFAULT NULL,
  `lang_3_title` varchar(500) DEFAULT NULL,
  `lang_4_title` varchar(500) DEFAULT NULL,
  `lang_5_title` varchar(500) DEFAULT NULL,
  `frequency` varchar(10) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions_tbl`
--

LOCK TABLES `promotions_tbl` WRITE;
/*!40000 ALTER TABLE `promotions_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `quantitylimits`
--

DROP TABLE IF EXISTS `quantitylimits`;
/*!50001 DROP VIEW IF EXISTS `quantitylimits`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `quantitylimits` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `quantity_limit` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `quantitylimits_rules`
--

DROP TABLE IF EXISTS `quantitylimits_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quantitylimits_rules` (
  `quantitylimit_id` int(11) NOT NULL,
  `applied_to_type` varchar(20) NOT NULL,
  `applied_to_value` varchar(100) NOT NULL,
  KEY `idx1` (`quantitylimit_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quantitylimits_rules`
--

LOCK TABLES `quantitylimits_rules` WRITE;
/*!40000 ALTER TABLE `quantitylimits_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `quantitylimits_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quantitylimits_tbl`
--

DROP TABLE IF EXISTS `quantitylimits_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quantitylimits_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order_seq` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `quantity_limit` int(11) NOT NULL DEFAULT 0,
  `lang_1_description` text DEFAULT '',
  `lang_2_description` text DEFAULT '',
  `lang_3_description` text DEFAULT '',
  `lang_4_description` text DEFAULT '',
  `lang_5_description` text DEFAULT '',
  `site_id` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx1` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quantitylimits_tbl`
--

LOCK TABLES `quantitylimits_tbl` WRITE;
/*!40000 ALTER TABLE `quantitylimits_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `quantitylimits_tbl` ENABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relation`
--

LOCK TABLES `relation` WRITE;
/*!40000 ALTER TABLE `relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `relation` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
) ENGINE=MyISAM AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules`
--

LOCK TABLES `rules` WRITE;
/*!40000 ALTER TABLE `rules` DISABLE KEYS */;
INSERT INTO `rules` VALUES ('tarifs','publish',0,'tarifs','published',0,'publish:tarif',0,1,0,'And','0','Cancelled'),('devices','delete',0,'devices','deleted',0,'remove:device',0,5,0,'And','0','Cancelled'),('translations','publish',0,'translations','published',0,'publish:translation',0,3,0,'And','0','Cancelled'),('tarifs','delete',0,'tarifs','deleted',0,'remove:tarif',0,4,0,'And','0','Cancelled'),('devices','publish',0,'devices','published',0,'publish:device',0,6,0,'And','0','Cancelled'),('accessories','delete',0,'accessories','deleted',0,'remove:accessory',0,7,0,'And','0','Cancelled'),('accessories','publish',0,'accessories','published',0,'publish:accessory',0,8,0,'And','0','Cancelled'),('faqs','delete',0,'faqs','deleted',0,'remove:faq',0,9,0,'And','0','Cancelled'),('faqs','publish',0,'faqs','published',0,'publish:faq',0,10,0,'And','0','Cancelled'),('catalogs','delete',0,'catalogs','deleted',0,'remove:catalog',0,11,0,'And','0','Cancelled'),('catalogs','publish',0,'catalogs','published',0,'publish:catalog',0,12,0,'And','0','Cancelled'),('products','delete',0,'products','deleted',0,'remove:product',0,13,0,'And','0','Cancelled'),('products','publish',0,'products','published',0,'publish:product',0,14,0,'And','0','Cancelled'),('products','publish_ordering',0,'products','published',0,'publishorder:product',0,17,0,'And','0','Cancelled'),('shop','publish',0,'shop','published',0,'publish:shop',0,16,0,'And','0','Cancelled'),('faqs','publish_ordering',0,'faqs','published',0,'publishorder:faq',0,18,0,'And','0','Cancelled'),('families','delete',0,'families','deleted',0,'remove:familie',0,19,0,'And','0','Cancelled'),('families','publish',0,'families','published',0,'publish:familie',0,20,0,'And','0','Cancelled'),('families','publish_ordering',0,'families','published',0,'publishorder:familie',0,21,0,'And','0','Cancelled'),('landingpages','delete',0,'landingpages','deleted',0,'remove:landingpage',0,25,0,'And','0','Cancelled'),('resources','publish',0,'resources','published',0,'publish:resources',0,23,0,'And','0','Cancelled'),('landingpages','publish',0,'landingpages','published',0,'publish:landingpage',0,26,0,'And','0','Cancelled'),('promotions','delete',0,'promotions','deleted',0,'remove:promotion',0,28,0,'And','0','Cancelled'),('promotions','publish',0,'promotions','published',0,'publish:promotion',0,29,0,'And','0','Cancelled'),('promotions','publish_ordering',0,'promotions','published',0,'publishorder:promotion',0,30,0,'And','0','Cancelled'),('cartrules','delete',0,'cartrules','deleted',0,'remove:cartrule',0,31,0,'And','0','Cancelled'),('cartrules','publish',0,'cartrules','published',0,'publish:cartrule',0,32,0,'And','0','Cancelled'),('cartrules','publish_ordering',0,'cartrules','published',0,'publishorder:cartrule',0,33,0,'And','0','Cancelled'),('additionalfees','delete',0,'additionalfees','deleted',0,'remove:additionalfee',0,34,0,'And','0','Cancelled'),('additionalfees','publish',0,'additionalfees','published',0,'publish:additionalfee',0,35,0,'And','0','Cancelled'),('additionalfees','publish_ordering',0,'additionalfees','published',0,'publishorder:additionalfee',0,36,0,'And','0','Cancelled'),('comewiths','delete',0,'comewiths','deleted',0,'remove:comewith',0,37,0,'And','0','Cancelled'),('comewiths','publish',0,'comewiths','published',0,'publish:comewith',0,38,0,'And','0','Cancelled'),('comewiths','publish_ordering',0,'comewiths','published',0,'publishorder:comewith',0,39,0,'And','0','Cancelled'),('subsidies','delete',0,'subsidies','deleted',0,'remove:subsidy',0,40,0,'And','0','Cancelled'),('subsidies','publish',0,'subsidies','published',0,'publish:subsidy',0,41,0,'And','0','Cancelled'),('subsidies','publish_ordering',0,'subsidies','published',0,'publishorder:subsidy',0,42,0,'And','0','Cancelled'),('deliveryfees','delete',0,'deliveryfees','deleted',0,'remove:deliveryfee',0,43,0,'And','0','Cancelled'),('deliveryfees','publish',0,'deliveryfees','published',0,'publish:deliveryfee',0,44,0,'And','0','Cancelled'),('deliveryfees','publish_ordering',0,'deliveryfees','published',0,'publishorder:deliveryfee',0,45,0,'And','0','Cancelled'),('deliverymins','delete',0,'deliverymins','deleted',0,'remove:deliverymin',0,46,0,'And','0','Cancelled'),('deliverymins','publish',0,'deliverymins','published',0,'publish:deliverymin',0,47,0,'And','0','Cancelled'),('deliverymins','publish_ordering',0,'deliverymins','published',0,'publishorder:deliverymin',0,48,0,'And','0','Cancelled'),('moduleparams','delete',0,'moduleparams','deleted',0,'remove:moduleparams',0,49,0,'And','0','Cancelled'),('moduleparams','publish',0,'moduleparams','published',0,'publish:moduleparams',0,50,0,'And','0','Cancelled'),('quantitylimits','delete',0,'quantitylimits','deleted',0,'remove:quantitylimits',0,51,0,'And','0','Cancelled'),('quantitylimits','publish',0,'quantitylimits','published',0,'publish:quantitylimits',0,52,0,'And','0','Cancelled');
/*!40000 ALTER TABLE `rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `share_bar`
--

DROP TABLE IF EXISTS `share_bar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `share_bar` (
  `id` int(11) unsigned NOT NULL,
  `ptype` enum('tarif','device','accessory','product') NOT NULL DEFAULT 'tarif',
  `lang_1_og_image` varchar(255) DEFAULT NULL,
  `lang_1_og_original_image_name` varchar(255) DEFAULT NULL,
  `lang_1_og_image_label` varchar(255) DEFAULT NULL,
  `lang_2_og_image` varchar(255) DEFAULT NULL,
  `lang_2_og_original_image_name` varchar(255) DEFAULT NULL,
  `lang_2_og_image_label` varchar(255) DEFAULT NULL,
  `lang_3_og_image` varchar(255) DEFAULT NULL,
  `lang_3_og_original_image_name` varchar(255) DEFAULT NULL,
  `lang_3_og_image_label` varchar(255) DEFAULT NULL,
  `lang_4_og_image` varchar(255) DEFAULT NULL,
  `lang_4_og_original_image_name` varchar(255) DEFAULT NULL,
  `lang_4_og_image_label` varchar(255) DEFAULT NULL,
  `lang_5_og_image` varchar(255) DEFAULT NULL,
  `lang_5_og_original_image_name` varchar(255) DEFAULT NULL,
  `lang_5_og_image_label` varchar(255) DEFAULT NULL,
  `og_active` tinyint(4) NOT NULL DEFAULT 1,
  `twitter_active` tinyint(4) NOT NULL DEFAULT 1,
  `email_active` tinyint(4) NOT NULL DEFAULT 1,
  `sms_active` tinyint(4) NOT NULL DEFAULT 1,
  `lang_1_og_title` text DEFAULT NULL,
  `lang_1_og_description` text DEFAULT NULL,
  `lang_1_twitter_message` text DEFAULT NULL,
  `lang_1_twitter_site` varchar(255) DEFAULT NULL,
  `lang_1_email_subject` text DEFAULT NULL,
  `lang_1_email_message` text DEFAULT NULL,
  `lang_1_email_popin_title` varchar(255) DEFAULT NULL,
  `lang_1_sms_text` text DEFAULT NULL,
  `lang_2_og_title` text DEFAULT NULL,
  `lang_2_og_description` text DEFAULT NULL,
  `lang_2_twitter_message` text DEFAULT NULL,
  `lang_2_twitter_site` varchar(255) DEFAULT NULL,
  `lang_2_email_subject` text DEFAULT NULL,
  `lang_2_email_message` text DEFAULT NULL,
  `lang_2_email_popin_title` varchar(255) DEFAULT NULL,
  `lang_2_sms_text` text DEFAULT NULL,
  `lang_3_og_title` text DEFAULT NULL,
  `lang_3_og_description` text DEFAULT NULL,
  `lang_3_twitter_message` text DEFAULT NULL,
  `lang_3_twitter_site` varchar(255) DEFAULT NULL,
  `lang_3_email_subject` text DEFAULT NULL,
  `lang_3_email_message` text DEFAULT NULL,
  `lang_3_email_popin_title` varchar(255) DEFAULT NULL,
  `lang_3_sms_text` text DEFAULT NULL,
  `lang_4_og_title` text DEFAULT NULL,
  `lang_4_og_description` text DEFAULT NULL,
  `lang_4_twitter_message` text DEFAULT NULL,
  `lang_4_twitter_site` varchar(255) DEFAULT NULL,
  `lang_4_email_subject` text DEFAULT NULL,
  `lang_4_email_message` text DEFAULT NULL,
  `lang_4_email_popin_title` varchar(255) DEFAULT NULL,
  `lang_4_sms_text` text DEFAULT NULL,
  `lang_5_og_title` text DEFAULT NULL,
  `lang_5_og_description` text DEFAULT NULL,
  `lang_5_twitter_message` text DEFAULT NULL,
  `lang_5_twitter_site` varchar(255) DEFAULT NULL,
  `lang_5_email_subject` text DEFAULT NULL,
  `lang_5_email_message` text DEFAULT NULL,
  `lang_5_email_popin_title` varchar(255) DEFAULT NULL,
  `lang_5_sms_text` text DEFAULT NULL,
  `created_by` int(11) unsigned NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `og_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`,`ptype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `share_bar`
--

LOCK TABLES `share_bar` WRITE;
/*!40000 ALTER TABLE `share_bar` DISABLE KEYS */;
/*!40000 ALTER TABLE `share_bar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_parameters`
--

DROP TABLE IF EXISTS `shop_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shop_parameters` (
  `site_id` int(11) NOT NULL,
  `catapulte_id_prod` int(11) NOT NULL DEFAULT 0,
  `catapulte_id_test` int(11) NOT NULL DEFAULT 0,
  `lang_1_price_formatter` varchar(25) DEFAULT NULL,
  `lang_2_price_formatter` varchar(25) DEFAULT NULL,
  `lang_3_price_formatter` varchar(25) DEFAULT NULL,
  `lang_4_price_formatter` varchar(25) DEFAULT NULL,
  `lang_5_price_formatter` varchar(25) DEFAULT NULL,
  `lang_1_currency` varchar(25) DEFAULT NULL,
  `lang_2_currency` varchar(25) DEFAULT NULL,
  `lang_3_currency` varchar(25) DEFAULT NULL,
  `lang_4_currency` varchar(25) DEFAULT NULL,
  `lang_5_currency` varchar(25) DEFAULT NULL,
  `lang_1_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_2_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_3_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_4_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_5_round_to_decimals` varchar(1) DEFAULT NULL,
  `lang_1_show_decimals` varchar(1) DEFAULT NULL,
  `lang_2_show_decimals` varchar(1) DEFAULT NULL,
  `lang_3_show_decimals` varchar(1) DEFAULT NULL,
  `lang_4_show_decimals` varchar(1) DEFAULT NULL,
  `lang_5_show_decimals` varchar(1) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `lang_1_terms` text DEFAULT NULL,
  `lang_2_terms` text DEFAULT NULL,
  `lang_3_terms` text DEFAULT NULL,
  `lang_4_terms` text DEFAULT NULL,
  `lang_5_terms` text DEFAULT NULL,
  `checkout_login` tinyint(1) NOT NULL DEFAULT 0,
  `lang_1_sb_title` varchar(255) DEFAULT NULL,
  `lang_2_sb_title` varchar(255) DEFAULT NULL,
  `lang_3_sb_title` varchar(255) DEFAULT NULL,
  `lang_4_sb_title` varchar(255) DEFAULT NULL,
  `lang_5_sb_title` varchar(255) DEFAULT NULL,
  `lang_1_sb_author` varchar(255) DEFAULT NULL,
  `lang_2_sb_author` varchar(255) DEFAULT NULL,
  `lang_3_sb_author` varchar(255) DEFAULT NULL,
  `lang_4_sb_author` varchar(255) DEFAULT NULL,
  `lang_5_sb_author` varchar(255) DEFAULT NULL,
  `lang_1_sb_price` varchar(75) DEFAULT NULL,
  `lang_2_sb_price` varchar(75) DEFAULT NULL,
  `lang_3_sb_price` varchar(75) DEFAULT NULL,
  `lang_4_sb_price` varchar(75) DEFAULT NULL,
  `lang_5_sb_price` varchar(75) DEFAULT NULL,
  `lang_1_sb_button_label` varchar(75) DEFAULT NULL,
  `lang_2_sb_button_label` varchar(75) DEFAULT NULL,
  `lang_3_sb_button_label` varchar(75) DEFAULT NULL,
  `lang_4_sb_button_label` varchar(75) DEFAULT NULL,
  `lang_5_sb_button_label` varchar(75) DEFAULT NULL,
  `sb_platform_ios` tinyint(1) DEFAULT 0,
  `sb_platform_android` tinyint(1) DEFAULT 0,
  `lang_1_sb_ios_price_suffix` varchar(75) DEFAULT NULL,
  `lang_2_sb_ios_price_suffix` varchar(75) DEFAULT NULL,
  `lang_3_sb_ios_price_suffix` varchar(75) DEFAULT NULL,
  `lang_4_sb_ios_price_suffix` varchar(75) DEFAULT NULL,
  `lang_5_sb_ios_price_suffix` varchar(75) DEFAULT NULL,
  `sb_ios_icon` varchar(255) DEFAULT NULL,
  `lang_1_sb_ios_button_url` varchar(255) DEFAULT NULL,
  `lang_2_sb_ios_button_url` varchar(255) DEFAULT NULL,
  `lang_3_sb_ios_button_url` varchar(255) DEFAULT NULL,
  `lang_4_sb_ios_button_url` varchar(255) DEFAULT NULL,
  `lang_5_sb_ios_button_url` varchar(255) DEFAULT NULL,
  `lang_1_sb_android_price_suffix` varchar(75) DEFAULT NULL,
  `lang_2_sb_android_price_suffix` varchar(75) DEFAULT NULL,
  `lang_3_sb_android_price_suffix` varchar(75) DEFAULT NULL,
  `lang_4_sb_android_price_suffix` varchar(75) DEFAULT NULL,
  `lang_5_sb_android_price_suffix` varchar(75) DEFAULT NULL,
  `sb_android_icon` varchar(255) DEFAULT NULL,
  `lang_1_sb_android_button_url` varchar(255) DEFAULT NULL,
  `lang_2_sb_android_button_url` varchar(255) DEFAULT NULL,
  `lang_3_sb_android_button_url` varchar(255) DEFAULT NULL,
  `lang_4_sb_android_button_url` varchar(255) DEFAULT NULL,
  `lang_5_sb_android_button_url` varchar(255) DEFAULT NULL,
  `installment_duration_units` varchar(255) DEFAULT NULL,
  `lang_1_terms_error` varchar(255) DEFAULT NULL,
  `lang_2_terms_error` varchar(255) DEFAULT NULL,
  `lang_3_terms_error` varchar(255) DEFAULT NULL,
  `lang_4_terms_error` varchar(255) DEFAULT NULL,
  `lang_5_terms_error` varchar(255) DEFAULT NULL,
  `lang_1_cart_message` varchar(255) DEFAULT NULL,
  `lang_2_cart_message` varchar(255) DEFAULT NULL,
  `lang_3_cart_message` varchar(255) DEFAULT NULL,
  `lang_4_cart_message` varchar(255) DEFAULT NULL,
  `lang_5_cart_message` varchar(255) DEFAULT NULL,
  `lang_1_order_tracking` text DEFAULT NULL,
  `lang_2_order_tracking` text DEFAULT NULL,
  `lang_3_order_tracking` text DEFAULT NULL,
  `lang_4_order_tracking` text DEFAULT NULL,
  `lang_5_order_tracking` text DEFAULT NULL,
  `service_params` varchar(1) DEFAULT NULL COMMENT '1 = Show; 0 = Hide;',
  `lang_1_stock_alert_button` varchar(255) DEFAULT NULL,
  `lang_2_stock_alert_button` varchar(255) DEFAULT NULL,
  `lang_3_stock_alert_button` varchar(255) DEFAULT NULL,
  `lang_4_stock_alert_button` varchar(255) DEFAULT NULL,
  `lang_5_stock_alert_button` varchar(255) DEFAULT NULL,
  `lang_1_stock_alert_text` varchar(255) DEFAULT NULL,
  `lang_2_stock_alert_text` varchar(255) DEFAULT NULL,
  `lang_3_stock_alert_text` varchar(255) DEFAULT NULL,
  `lang_4_stock_alert_text` varchar(255) DEFAULT NULL,
  `lang_5_stock_alert_text` varchar(255) DEFAULT NULL,
  `lang_1_coming_soon_button` varchar(255) DEFAULT NULL,
  `lang_2_coming_soon_button` varchar(255) DEFAULT NULL,
  `lang_3_coming_soon_button` varchar(255) DEFAULT NULL,
  `lang_4_coming_soon_button` varchar(255) DEFAULT NULL,
  `lang_5_coming_soon_button` varchar(255) DEFAULT NULL,
  `datalayer_domain` varchar(255) DEFAULT NULL,
  `datalayer_brand` varchar(255) DEFAULT NULL,
  `datalayer_market` varchar(255) DEFAULT NULL,
  `lang_1_no_price_display_label` varchar(75) DEFAULT NULL,
  `lang_2_no_price_display_label` varchar(75) DEFAULT NULL,
  `lang_3_no_price_display_label` varchar(75) DEFAULT NULL,
  `lang_4_no_price_display_label` varchar(75) DEFAULT NULL,
  `lang_5_no_price_display_label` varchar(75) DEFAULT NULL,
  `lang_1_empty_cart_url` varchar(255) DEFAULT NULL,
  `lang_2_empty_cart_url` varchar(255) DEFAULT NULL,
  `lang_3_empty_cart_url` varchar(255) DEFAULT NULL,
  `lang_4_empty_cart_url` varchar(255) DEFAULT NULL,
  `lang_5_empty_cart_url` varchar(255) DEFAULT NULL,
  `deliver_outside_dep` tinyint(1) DEFAULT 0,
  `lang_1_deliver_outside_dep_error` varchar(255) DEFAULT '',
  `lang_2_deliver_outside_dep_error` varchar(255) DEFAULT '',
  `lang_3_deliver_outside_dep_error` varchar(255) DEFAULT '',
  `lang_4_deliver_outside_dep_error` varchar(255) DEFAULT '',
  `lang_5_deliver_outside_dep_error` varchar(255) DEFAULT '',
  `multiple_catalogs_checkout` tinyint(1) DEFAULT 1,
  `show_product_detail_delivery_fee` tinyint(1) NOT NULL DEFAULT 0,
  `save_cart_email_id_test` int(11) NOT NULL DEFAULT 0,
  `save_cart_email_id_prod` int(11) NOT NULL DEFAULT 0,
  `stock_alert_email_id_test` int(11) DEFAULT NULL,
  `stock_alert_email_id_prod` int(11) DEFAULT NULL,
  `lang_1_save_cart_text` text DEFAULT NULL,
  `lang_2_save_cart_text` text DEFAULT NULL,
  `lang_3_save_cart_text` text DEFAULT NULL,
  `lang_4_save_cart_text` text DEFAULT NULL,
  `lang_5_save_cart_text` text DEFAULT NULL,
  `lang_1_currency_position` enum('after','before') NOT NULL DEFAULT 'after',
  `lang_2_currency_position` enum('after','before') NOT NULL DEFAULT 'after',
  `lang_3_currency_position` enum('after','before') NOT NULL DEFAULT 'after',
  `lang_4_currency_position` enum('after','before') NOT NULL DEFAULT 'after',
  `lang_5_currency_position` enum('after','before') NOT NULL DEFAULT 'after',
  `lang_1_continue_shop_url` varchar(255) DEFAULT NULL,
  `lang_2_continue_shop_url` varchar(255) DEFAULT NULL,
  `lang_3_continue_shop_url` varchar(255) DEFAULT NULL,
  `lang_4_continue_shop_url` varchar(255) DEFAULT NULL,
  `lang_5_continue_shop_url` varchar(255) DEFAULT NULL,
  `lang_1_free_payment_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when payment method has no charged',
  `lang_2_free_payment_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when payment method has no charged',
  `lang_3_free_payment_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when payment method has no charged',
  `lang_4_free_payment_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when payment method has no charged',
  `lang_5_free_payment_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when payment method has no charged',
  `lang_1_free_delivery_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when delivery method has no charged',
  `lang_2_free_delivery_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when delivery method has no charged',
  `lang_3_free_delivery_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when delivery method has no charged',
  `lang_4_free_delivery_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when delivery method has no charged',
  `lang_5_free_delivery_method` varchar(255) NOT NULL DEFAULT 'Free' COMMENT 'Text to show when delivery method has no charged',
  `incomplete_cart_email_id_prod` int(11) DEFAULT NULL,
  `incomplete_cart_email_id_test` int(11) DEFAULT NULL,
  `topup_max_amount` double DEFAULT NULL,
  `card2wallet_max_amount` double DEFAULT NULL,
  PRIMARY KEY (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_parameters`
--

LOCK TABLES `shop_parameters` WRITE;
/*!40000 ALTER TABLE `shop_parameters` DISABLE KEYS */;
/*!40000 ALTER TABLE `shop_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shortcuts`
--

DROP TABLE IF EXISTS `shortcuts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shortcuts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `url` varchar(255) NOT NULL,
  `created_by` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shrt_cut` (`name`,`site_id`,`created_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shortcuts`
--

LOCK TABLES `shortcuts` WRITE;
/*!40000 ALTER TABLE `shortcuts` DISABLE KEYS */;
/*!40000 ALTER TABLE `shortcuts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_log`
--

DROP TABLE IF EXISTS `stat_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_log` (
  `date_l` datetime NOT NULL,
  `ip` varchar(15) CHARACTER SET latin1 NOT NULL,
  `session_j` varchar(70) CHARACTER SET latin1 NOT NULL,
  `user_agent` varchar(128) CHARACTER SET latin1 DEFAULT NULL,
  `screen_width` int(11) DEFAULT NULL,
  `screen_height` int(11) DEFAULT NULL,
  `page_c` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `page_ref` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`date_l`,`ip`,`session_j`)
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
-- Table structure for table `stickers`
--

DROP TABLE IF EXISTS `stickers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stickers` (
  `site_id` int(11) NOT NULL,
  `sname` varchar(50) NOT NULL DEFAULT '',
  `display_name_1` varchar(50) DEFAULT '',
  `display_name_2` varchar(50) DEFAULT '',
  `display_name_3` varchar(50) DEFAULT '',
  `display_name_4` varchar(50) DEFAULT '',
  `display_name_5` varchar(50) DEFAULT '',
  `color` varchar(10) DEFAULT '',
  `priority` int(10) DEFAULT NULL,
  PRIMARY KEY (`sname`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stickers`
--

LOCK TABLES `stickers` WRITE;
/*!40000 ALTER TABLE `stickers` DISABLE KEYS */;
/*!40000 ALTER TABLE `stickers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `status` varchar(10) CHARACTER SET latin1 DEFAULT NULL,
  `type` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `custom_id` int(11) DEFAULT NULL,
  `address` text CHARACTER SET latin1 DEFAULT NULL,
  `city` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `postal_code` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `country_code` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `monday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `tuesday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `wednesday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `thursday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `friday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `saturday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `sunday` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `latitude` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `longitude` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
/*!40000 ALTER TABLE `stores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `subsidies`
--

DROP TABLE IF EXISTS `subsidies`;
/*!50001 DROP VIEW IF EXISTS `subsidies`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `subsidies` (
  `id` tinyint NOT NULL,
  `order_seq` tinyint NOT NULL,
  `site_id` tinyint NOT NULL,
  `version` tinyint NOT NULL,
  `created_by` tinyint NOT NULL,
  `created_on` tinyint NOT NULL,
  `updated_by` tinyint NOT NULL,
  `updated_on` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `lang_1_description` tinyint NOT NULL,
  `lang_2_description` tinyint NOT NULL,
  `lang_3_description` tinyint NOT NULL,
  `lang_4_description` tinyint NOT NULL,
  `lang_5_description` tinyint NOT NULL,
  `visible_to` tinyint NOT NULL,
  `start_date` tinyint NOT NULL,
  `end_date` tinyint NOT NULL,
  `discount_type` tinyint NOT NULL,
  `discount_value` tinyint NOT NULL,
  `applied_to_type` tinyint NOT NULL,
  `applied_to_value` tinyint NOT NULL,
  `redirect_url` tinyint NOT NULL,
  `open_as` tinyint NOT NULL,
  `is_deleted` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `subsidies_rules`
--

DROP TABLE IF EXISTS `subsidies_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subsidies_rules` (
  `subsidy_id` int(11) NOT NULL,
  `associated_to_type` varchar(50) DEFAULT NULL,
  `associated_to_value` varchar(255) DEFAULT NULL,
  UNIQUE KEY `subsidy_id` (`subsidy_id`,`associated_to_type`,`associated_to_value`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subsidies_rules`
--

LOCK TABLES `subsidies_rules` WRITE;
/*!40000 ALTER TABLE `subsidies_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `subsidies_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subsidies_tbl`
--

DROP TABLE IF EXISTS `subsidies_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subsidies_tbl` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `lang_1_description` text DEFAULT NULL,
  `lang_2_description` text DEFAULT NULL,
  `lang_3_description` text DEFAULT NULL,
  `lang_4_description` text DEFAULT NULL,
  `lang_5_description` text DEFAULT NULL,
  `visible_to` varchar(50) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `discount_type` varchar(10) NOT NULL,
  `discount_value` varchar(10) NOT NULL,
  `applied_to_type` varchar(50) DEFAULT NULL,
  `applied_to_value` varchar(255) DEFAULT NULL,
  `redirect_url` varchar(255) NOT NULL DEFAULT '',
  `open_as` enum('new_tab','new_window','same_window') NOT NULL DEFAULT 'same_window',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subsidies_tbl`
--

LOCK TABLES `subsidies_tbl` WRITE;
/*!40000 ALTER TABLE `subsidies_tbl` DISABLE KEYS */;
/*!40000 ALTER TABLE `subsidies_tbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` varchar(100) NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT 0,
  `label` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  `folder_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags_folders`
--

DROP TABLE IF EXISTS `tags_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) DEFAULT NULL,
  `folder_id` varchar(100) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `parent_folder_id` int(11) DEFAULT 0,
  `folder_level` int(11) DEFAULT 0,
  `site_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(4) DEFAULT 0,
  `created_on` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `updated_on` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_id` (`site_id`,`parent_folder_id`,`folder_id`,`is_deleted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags_folders`
--

LOCK TABLES `tags_folders` WRITE;
/*!40000 ALTER TABLE `tags_folders` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags_folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tarif_categories`
--

DROP TABLE IF EXISTS `tarif_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tarif_categories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tarif_id` int(11) unsigned NOT NULL,
  `lang_1_name` varchar(100) DEFAULT NULL,
  `lang_2_name` varchar(100) DEFAULT NULL,
  `lang_3_name` varchar(100) DEFAULT NULL,
  `lang_4_name` varchar(100) DEFAULT NULL,
  `lang_5_name` varchar(100) DEFAULT NULL,
  `order_seq` int(10) DEFAULT NULL,
  `product_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarif_categories`
--

LOCK TABLES `tarif_categories` WRITE;
/*!40000 ALTER TABLE `tarif_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarif_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tarif_category_items`
--

DROP TABLE IF EXISTS `tarif_category_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tarif_category_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tarif_category_id` int(11) unsigned NOT NULL,
  `lang_1_item` varchar(100) DEFAULT NULL,
  `lang_2_item` varchar(100) DEFAULT NULL,
  `lang_3_item` varchar(100) DEFAULT NULL,
  `lang_4_item` varchar(100) DEFAULT NULL,
  `lang_5_item` varchar(100) DEFAULT NULL,
  `lang_1_value` varchar(100) DEFAULT NULL,
  `lang_2_value` varchar(100) DEFAULT NULL,
  `lang_3_value` varchar(100) DEFAULT NULL,
  `lang_4_value` varchar(100) DEFAULT NULL,
  `lang_5_value` varchar(100) DEFAULT NULL,
  `show_in_details_only` tinyint(1) NOT NULL DEFAULT 0,
  `order_seq` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarif_category_items`
--

LOCK TABLES `tarif_category_items` WRITE;
/*!40000 ALTER TABLE `tarif_category_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarif_category_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tarif_default_categories`
--

DROP TABLE IF EXISTS `tarif_default_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tarif_default_categories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cat_name` varchar(100) DEFAULT NULL,
  `item_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarif_default_categories`
--

LOCK TABLES `tarif_default_categories` WRITE;
/*!40000 ALTER TABLE `tarif_default_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarif_default_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `theme_id` int(11) NOT NULL AUTO_INCREMENT,
  `theme` varchar(50) NOT NULL,
  `parent_theme_id` int(11) NOT NULL DEFAULT 0,
  `ordre` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`theme_id`)
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
-- Table structure for table `variant_tags`
--

DROP TABLE IF EXISTS `variant_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `variant_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `variant_id` int(11) NOT NULL,
  `tag_id` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_item_type_method` (`variant_id`,`tag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variant_tags`
--

LOCK TABLES `variant_tags` WRITE;
/*!40000 ALTER TABLE `variant_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `variant_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `additionalfees`
--

/*!50001 DROP TABLE IF EXISTS `additionalfees`*/;
/*!50001 DROP VIEW IF EXISTS `additionalfees`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `additionalfees` AS select `additionalfees_tbl`.`id` AS `id`,`additionalfees_tbl`.`order_seq` AS `order_seq`,`additionalfees_tbl`.`site_id` AS `site_id`,`additionalfees_tbl`.`version` AS `version`,`additionalfees_tbl`.`created_by` AS `created_by`,`additionalfees_tbl`.`created_on` AS `created_on`,`additionalfees_tbl`.`updated_by` AS `updated_by`,`additionalfees_tbl`.`updated_on` AS `updated_on`,`additionalfees_tbl`.`additional_fee` AS `additional_fee`,`additionalfees_tbl`.`lang_1_description` AS `lang_1_description`,`additionalfees_tbl`.`lang_2_description` AS `lang_2_description`,`additionalfees_tbl`.`lang_3_description` AS `lang_3_description`,`additionalfees_tbl`.`lang_4_description` AS `lang_4_description`,`additionalfees_tbl`.`lang_5_description` AS `lang_5_description`,`additionalfees_tbl`.`visible_to` AS `visible_to`,`additionalfees_tbl`.`start_date` AS `start_date`,`additionalfees_tbl`.`end_date` AS `end_date`,`additionalfees_tbl`.`is_deleted` AS `is_deleted` from `additionalfees_tbl` where `additionalfees_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cart_promotion`
--

/*!50001 DROP TABLE IF EXISTS `cart_promotion`*/;
/*!50001 DROP VIEW IF EXISTS `cart_promotion`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cart_promotion` AS select `cart_promotion_tbl`.`id` AS `id`,`cart_promotion_tbl`.`order_seq` AS `order_seq`,`cart_promotion_tbl`.`site_id` AS `site_id`,`cart_promotion_tbl`.`version` AS `version`,`cart_promotion_tbl`.`created_by` AS `created_by`,`cart_promotion_tbl`.`created_on` AS `created_on`,`cart_promotion_tbl`.`updated_by` AS `updated_by`,`cart_promotion_tbl`.`updated_on` AS `updated_on`,`cart_promotion_tbl`.`name` AS `name`,`cart_promotion_tbl`.`description` AS `description`,`cart_promotion_tbl`.`visible_to` AS `visible_to`,`cart_promotion_tbl`.`start_date` AS `start_date`,`cart_promotion_tbl`.`end_date` AS `end_date`,`cart_promotion_tbl`.`auto_generate_cc` AS `auto_generate_cc`,`cart_promotion_tbl`.`uses_per_coupon` AS `uses_per_coupon`,`cart_promotion_tbl`.`uses_per_customer` AS `uses_per_customer`,`cart_promotion_tbl`.`coupon_quantity` AS `coupon_quantity`,`cart_promotion_tbl`.`cc_length` AS `cc_length`,`cart_promotion_tbl`.`cc_prefix` AS `cc_prefix`,`cart_promotion_tbl`.`rule_field` AS `rule_field`,`cart_promotion_tbl`.`rule_type` AS `rule_type`,`cart_promotion_tbl`.`verify_condition` AS `verify_condition`,`cart_promotion_tbl`.`rule_condition` AS `rule_condition`,`cart_promotion_tbl`.`rule_condition_value` AS `rule_condition_value`,`cart_promotion_tbl`.`discount_type` AS `discount_type`,`cart_promotion_tbl`.`discount_value` AS `discount_value`,`cart_promotion_tbl`.`element_on` AS `element_on`,`cart_promotion_tbl`.`is_deleted` AS `is_deleted` from `cart_promotion_tbl` where `cart_promotion_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `catalogs`
--

/*!50001 DROP TABLE IF EXISTS `catalogs`*/;
/*!50001 DROP VIEW IF EXISTS `catalogs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `catalogs` AS select `catalogs_tbl`.`id` AS `id`,`catalogs_tbl`.`name` AS `name`,`catalogs_tbl`.`catalog_uuid` AS `catalog_uuid`,`catalogs_tbl`.`lang_1_heading` AS `lang_1_heading`,`catalogs_tbl`.`lang_2_heading` AS `lang_2_heading`,`catalogs_tbl`.`lang_3_heading` AS `lang_3_heading`,`catalogs_tbl`.`lang_4_heading` AS `lang_4_heading`,`catalogs_tbl`.`lang_5_heading` AS `lang_5_heading`,`catalogs_tbl`.`created_by` AS `created_by`,`catalogs_tbl`.`created_on` AS `created_on`,`catalogs_tbl`.`updated_by` AS `updated_by`,`catalogs_tbl`.`updated_on` AS `updated_on`,`catalogs_tbl`.`lang_1_details_heading` AS `lang_1_details_heading`,`catalogs_tbl`.`lang_2_details_heading` AS `lang_2_details_heading`,`catalogs_tbl`.`lang_3_details_heading` AS `lang_3_details_heading`,`catalogs_tbl`.`lang_4_details_heading` AS `lang_4_details_heading`,`catalogs_tbl`.`lang_5_details_heading` AS `lang_5_details_heading`,`catalogs_tbl`.`product_types_custom` AS `product_types_custom`,`catalogs_tbl`.`is_special` AS `is_special`,`catalogs_tbl`.`lang_1_price_formatter` AS `lang_1_price_formatter`,`catalogs_tbl`.`lang_2_price_formatter` AS `lang_2_price_formatter`,`catalogs_tbl`.`lang_3_price_formatter` AS `lang_3_price_formatter`,`catalogs_tbl`.`lang_4_price_formatter` AS `lang_4_price_formatter`,`catalogs_tbl`.`lang_5_price_formatter` AS `lang_5_price_formatter`,`catalogs_tbl`.`lang_1_currency` AS `lang_1_currency`,`catalogs_tbl`.`lang_2_currency` AS `lang_2_currency`,`catalogs_tbl`.`lang_3_currency` AS `lang_3_currency`,`catalogs_tbl`.`lang_4_currency` AS `lang_4_currency`,`catalogs_tbl`.`lang_5_currency` AS `lang_5_currency`,`catalogs_tbl`.`lang_1_round_to_decimals` AS `lang_1_round_to_decimals`,`catalogs_tbl`.`lang_2_round_to_decimals` AS `lang_2_round_to_decimals`,`catalogs_tbl`.`lang_3_round_to_decimals` AS `lang_3_round_to_decimals`,`catalogs_tbl`.`lang_4_round_to_decimals` AS `lang_4_round_to_decimals`,`catalogs_tbl`.`lang_5_round_to_decimals` AS `lang_5_round_to_decimals`,`catalogs_tbl`.`lang_1_show_decimals` AS `lang_1_show_decimals`,`catalogs_tbl`.`lang_2_show_decimals` AS `lang_2_show_decimals`,`catalogs_tbl`.`lang_3_show_decimals` AS `lang_3_show_decimals`,`catalogs_tbl`.`lang_4_show_decimals` AS `lang_4_show_decimals`,`catalogs_tbl`.`lang_5_show_decimals` AS `lang_5_show_decimals`,`catalogs_tbl`.`cart_url` AS `cart_url`,`catalogs_tbl`.`cart_prod_url` AS `cart_prod_url`,`catalogs_tbl`.`cart_url_params` AS `cart_url_params`,`catalogs_tbl`.`store_locator_url` AS `store_locator_url`,`catalogs_tbl`.`store_locator_prod_url` AS `store_locator_prod_url`,`catalogs_tbl`.`store_locator_url_params` AS `store_locator_url_params`,`catalogs_tbl`.`lang_1_hub_page_heading` AS `lang_1_hub_page_heading`,`catalogs_tbl`.`lang_2_hub_page_heading` AS `lang_2_hub_page_heading`,`catalogs_tbl`.`lang_3_hub_page_heading` AS `lang_3_hub_page_heading`,`catalogs_tbl`.`lang_4_hub_page_heading` AS `lang_4_hub_page_heading`,`catalogs_tbl`.`lang_5_hub_page_heading` AS `lang_5_hub_page_heading`,`catalogs_tbl`.`lang_1_top_banner_path` AS `lang_1_top_banner_path`,`catalogs_tbl`.`topban_product_list` AS `topban_product_list`,`catalogs_tbl`.`topban_product_detail` AS `topban_product_detail`,`catalogs_tbl`.`topban_hub` AS `topban_hub`,`catalogs_tbl`.`lang_2_top_banner_path` AS `lang_2_top_banner_path`,`catalogs_tbl`.`lang_3_top_banner_path` AS `lang_3_top_banner_path`,`catalogs_tbl`.`lang_4_top_banner_path` AS `lang_4_top_banner_path`,`catalogs_tbl`.`lang_5_top_banner_path` AS `lang_5_top_banner_path`,`catalogs_tbl`.`lang_1_bottom_banner_path` AS `lang_1_bottom_banner_path`,`catalogs_tbl`.`bottomban_product_list` AS `bottomban_product_list`,`catalogs_tbl`.`bottomban_product_detail` AS `bottomban_product_detail`,`catalogs_tbl`.`bottomban_hub` AS `bottomban_hub`,`catalogs_tbl`.`lang_2_bottom_banner_path` AS `lang_2_bottom_banner_path`,`catalogs_tbl`.`lang_3_bottom_banner_path` AS `lang_3_bottom_banner_path`,`catalogs_tbl`.`lang_4_bottom_banner_path` AS `lang_4_bottom_banner_path`,`catalogs_tbl`.`lang_5_bottom_banner_path` AS `lang_5_bottom_banner_path`,`catalogs_tbl`.`hub_page_orientation` AS `hub_page_orientation`,`catalogs_tbl`.`view_name` AS `view_name`,`catalogs_tbl`.`lang_1_meta_keywords` AS `lang_1_meta_keywords`,`catalogs_tbl`.`lang_2_meta_keywords` AS `lang_2_meta_keywords`,`catalogs_tbl`.`lang_3_meta_keywords` AS `lang_3_meta_keywords`,`catalogs_tbl`.`lang_4_meta_keywords` AS `lang_4_meta_keywords`,`catalogs_tbl`.`lang_5_meta_keywords` AS `lang_5_meta_keywords`,`catalogs_tbl`.`lang_1_meta_description` AS `lang_1_meta_description`,`catalogs_tbl`.`lang_2_meta_description` AS `lang_2_meta_description`,`catalogs_tbl`.`lang_3_meta_description` AS `lang_3_meta_description`,`catalogs_tbl`.`lang_4_meta_description` AS `lang_4_meta_description`,`catalogs_tbl`.`lang_5_meta_description` AS `lang_5_meta_description`,`catalogs_tbl`.`invoice_nature` AS `invoice_nature`,`catalogs_tbl`.`manufacturers` AS `manufacturers`,`catalogs_tbl`.`price_tax_included` AS `price_tax_included`,`catalogs_tbl`.`catalog_type` AS `catalog_type`,`catalogs_tbl`.`site_id` AS `site_id`,`catalogs_tbl`.`tax_percentage` AS `tax_percentage`,`catalogs_tbl`.`show_amount_tax_included` AS `show_amount_tax_included`,`catalogs_tbl`.`essentials_alignment_lang_1` AS `essentials_alignment_lang_1`,`catalogs_tbl`.`essentials_alignment_lang_2` AS `essentials_alignment_lang_2`,`catalogs_tbl`.`essentials_alignment_lang_3` AS `essentials_alignment_lang_3`,`catalogs_tbl`.`essentials_alignment_lang_4` AS `essentials_alignment_lang_4`,`catalogs_tbl`.`essentials_alignment_lang_5` AS `essentials_alignment_lang_5`,`catalogs_tbl`.`version` AS `version`,`catalogs_tbl`.`lang_1_description` AS `lang_1_description`,`catalogs_tbl`.`lang_2_description` AS `lang_2_description`,`catalogs_tbl`.`lang_3_description` AS `lang_3_description`,`catalogs_tbl`.`lang_4_description` AS `lang_4_description`,`catalogs_tbl`.`lang_5_description` AS `lang_5_description`,`catalogs_tbl`.`buy_status` AS `buy_status`,`catalogs_tbl`.`default_sort` AS `default_sort`,`catalogs_tbl`.`html_variant` AS `html_variant`,`catalogs_tbl`.`is_deleted` AS `is_deleted`,`catalogs_tbl`.`catalog_version` AS `catalog_version` from `catalogs_tbl` where `catalogs_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `comewiths`
--

/*!50001 DROP TABLE IF EXISTS `comewiths`*/;
/*!50001 DROP VIEW IF EXISTS `comewiths`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `comewiths` AS select `comewiths_tbl`.`id` AS `id`,`comewiths_tbl`.`order_seq` AS `order_seq`,`comewiths_tbl`.`site_id` AS `site_id`,`comewiths_tbl`.`version` AS `version`,`comewiths_tbl`.`created_by` AS `created_by`,`comewiths_tbl`.`created_on` AS `created_on`,`comewiths_tbl`.`updated_by` AS `updated_by`,`comewiths_tbl`.`updated_on` AS `updated_on`,`comewiths_tbl`.`name` AS `name`,`comewiths_tbl`.`lang_1_description` AS `lang_1_description`,`comewiths_tbl`.`lang_2_description` AS `lang_2_description`,`comewiths_tbl`.`lang_3_description` AS `lang_3_description`,`comewiths_tbl`.`lang_4_description` AS `lang_4_description`,`comewiths_tbl`.`lang_5_description` AS `lang_5_description`,`comewiths_tbl`.`visible_to` AS `visible_to`,`comewiths_tbl`.`start_date` AS `start_date`,`comewiths_tbl`.`end_date` AS `end_date`,`comewiths_tbl`.`comewith` AS `comewith`,`comewiths_tbl`.`type` AS `type`,`comewiths_tbl`.`applied_to_type` AS `applied_to_type`,`comewiths_tbl`.`applied_to_value` AS `applied_to_value`,`comewiths_tbl`.`title` AS `title`,`comewiths_tbl`.`variant_type` AS `variant_type`,`comewiths_tbl`.`frequency` AS `frequency`,`comewiths_tbl`.`is_deleted` AS `is_deleted`,`comewiths_tbl`.`price_difference` AS `price_difference` from `comewiths_tbl` where `comewiths_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `deliveryfees`
--

/*!50001 DROP TABLE IF EXISTS `deliveryfees`*/;
/*!50001 DROP VIEW IF EXISTS `deliveryfees`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `deliveryfees` AS select `deliveryfees_tbl`.`id` AS `id`,`deliveryfees_tbl`.`name` AS `name`,`deliveryfees_tbl`.`order_seq` AS `order_seq`,`deliveryfees_tbl`.`created_by` AS `created_by`,`deliveryfees_tbl`.`created_on` AS `created_on`,`deliveryfees_tbl`.`updated_by` AS `updated_by`,`deliveryfees_tbl`.`updated_on` AS `updated_on`,`deliveryfees_tbl`.`visible_to` AS `visible_to`,`deliveryfees_tbl`.`dep_type` AS `dep_type`,`deliveryfees_tbl`.`dep_value` AS `dep_value`,`deliveryfees_tbl`.`fee` AS `fee`,`deliveryfees_tbl`.`applicable_per_item` AS `applicable_per_item`,`deliveryfees_tbl`.`lang_1_description` AS `lang_1_description`,`deliveryfees_tbl`.`lang_2_description` AS `lang_2_description`,`deliveryfees_tbl`.`lang_3_description` AS `lang_3_description`,`deliveryfees_tbl`.`lang_4_description` AS `lang_4_description`,`deliveryfees_tbl`.`lang_5_description` AS `lang_5_description`,`deliveryfees_tbl`.`site_id` AS `site_id`,`deliveryfees_tbl`.`version` AS `version`,`deliveryfees_tbl`.`is_deleted` AS `is_deleted`,`deliveryfees_tbl`.`delivery_type` AS `delivery_type`,`deliveryfees_tbl`.`UUID` AS `UUID` from `deliveryfees_tbl` where `deliveryfees_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `deliverymins`
--

/*!50001 DROP TABLE IF EXISTS `deliverymins`*/;
/*!50001 DROP VIEW IF EXISTS `deliverymins`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `deliverymins` AS select `deliverymins_tbl`.`id` AS `id`,`deliverymins_tbl`.`name` AS `name`,`deliverymins_tbl`.`order_seq` AS `order_seq`,`deliverymins_tbl`.`created_by` AS `created_by`,`deliverymins_tbl`.`created_on` AS `created_on`,`deliverymins_tbl`.`updated_by` AS `updated_by`,`deliverymins_tbl`.`updated_on` AS `updated_on`,`deliverymins_tbl`.`visible_to` AS `visible_to`,`deliverymins_tbl`.`dep_type` AS `dep_type`,`deliverymins_tbl`.`dep_value` AS `dep_value`,`deliverymins_tbl`.`criteria_type` AS `criteria_type`,`deliverymins_tbl`.`minimum_type` AS `minimum_type`,`deliverymins_tbl`.`minimum_total` AS `minimum_total`,`deliverymins_tbl`.`lang_1_description` AS `lang_1_description`,`deliverymins_tbl`.`lang_2_description` AS `lang_2_description`,`deliverymins_tbl`.`lang_3_description` AS `lang_3_description`,`deliverymins_tbl`.`lang_4_description` AS `lang_4_description`,`deliverymins_tbl`.`lang_5_description` AS `lang_5_description`,`deliverymins_tbl`.`site_id` AS `site_id`,`deliverymins_tbl`.`version` AS `version`,`deliverymins_tbl`.`applied_to_type` AS `applied_to_type`,`deliverymins_tbl`.`applied_to_value` AS `applied_to_value`,`deliverymins_tbl`.`is_deleted` AS `is_deleted` from `deliverymins_tbl` where `deliverymins_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products`
--

/*!50001 DROP TABLE IF EXISTS `products`*/;
/*!50001 DROP VIEW IF EXISTS `products`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products` AS select `products_tbl`.`id` AS `id`,`products_tbl`.`catalog_id` AS `catalog_id`,`products_tbl`.`folder_id` AS `folder_id`,`products_tbl`.`link_id` AS `link_id`,`products_tbl`.`migrated_id` AS `migrated_id`,`products_tbl`.`is_new` AS `is_new`,`products_tbl`.`show_basket` AS `show_basket`,`products_tbl`.`show_quickbuy` AS `show_quickbuy`,`products_tbl`.`order_seq` AS `order_seq`,`products_tbl`.`image_name` AS `image_name`,`products_tbl`.`image_actual_name` AS `image_actual_name`,`products_tbl`.`product_type` AS `product_type`,`products_tbl`.`product_type_custom` AS `product_type_custom`,`products_tbl`.`brand_name` AS `brand_name`,`products_tbl`.`lang_1_name` AS `lang_1_name`,`products_tbl`.`lang_2_name` AS `lang_2_name`,`products_tbl`.`lang_3_name` AS `lang_3_name`,`products_tbl`.`lang_4_name` AS `lang_4_name`,`products_tbl`.`lang_5_name` AS `lang_5_name`,`products_tbl`.`lang_1_summary` AS `lang_1_summary`,`products_tbl`.`lang_2_summary` AS `lang_2_summary`,`products_tbl`.`lang_3_summary` AS `lang_3_summary`,`products_tbl`.`lang_4_summary` AS `lang_4_summary`,`products_tbl`.`lang_5_summary` AS `lang_5_summary`,`products_tbl`.`lang_1_features` AS `lang_1_features`,`products_tbl`.`lang_2_features` AS `lang_2_features`,`products_tbl`.`lang_3_features` AS `lang_3_features`,`products_tbl`.`lang_4_features` AS `lang_4_features`,`products_tbl`.`lang_5_features` AS `lang_5_features`,`products_tbl`.`lang_1_listing_tab` AS `lang_1_listing_tab`,`products_tbl`.`lang_2_listing_tab` AS `lang_2_listing_tab`,`products_tbl`.`lang_3_listing_tab` AS `lang_3_listing_tab`,`products_tbl`.`lang_4_listing_tab` AS `lang_4_listing_tab`,`products_tbl`.`lang_5_listing_tab` AS `lang_5_listing_tab`,`products_tbl`.`lang_1_meta_keywords` AS `lang_1_meta_keywords`,`products_tbl`.`lang_2_meta_keywords` AS `lang_2_meta_keywords`,`products_tbl`.`lang_3_meta_keywords` AS `lang_3_meta_keywords`,`products_tbl`.`lang_4_meta_keywords` AS `lang_4_meta_keywords`,`products_tbl`.`lang_5_meta_keywords` AS `lang_5_meta_keywords`,`products_tbl`.`lang_1_meta_description` AS `lang_1_meta_description`,`products_tbl`.`lang_2_meta_description` AS `lang_2_meta_description`,`products_tbl`.`lang_3_meta_description` AS `lang_3_meta_description`,`products_tbl`.`lang_4_meta_description` AS `lang_4_meta_description`,`products_tbl`.`lang_5_meta_description` AS `lang_5_meta_description`,`products_tbl`.`price` AS `price`,`products_tbl`.`price_sent` AS `price_sent`,`products_tbl`.`currency` AS `currency`,`products_tbl`.`currency_frequency` AS `currency_frequency`,`products_tbl`.`combo_prices` AS `combo_prices`,`products_tbl`.`discount_prices` AS `discount_prices`,`products_tbl`.`bundle_prices` AS `bundle_prices`,`products_tbl`.`installment_options` AS `installment_options`,`products_tbl`.`promo_price` AS `promo_price`,`products_tbl`.`stock` AS `stock`,`products_tbl`.`payment_online` AS `payment_online`,`products_tbl`.`payment_cash_on_delivery` AS `payment_cash_on_delivery`,`products_tbl`.`primary_resource` AS `primary_resource`,`products_tbl`.`secondary_resource` AS `secondary_resource`,`products_tbl`.`service_duration` AS `service_duration`,`products_tbl`.`service_gap` AS `service_gap`,`products_tbl`.`service_max_slots` AS `service_max_slots`,`products_tbl`.`service_start_time` AS `service_start_time`,`products_tbl`.`service_end_time` AS `service_end_time`,`products_tbl`.`service_available_start_time` AS `service_available_start_time`,`products_tbl`.`service_available_days` AS `service_available_days`,`products_tbl`.`service_schedule` AS `service_schedule`,`products_tbl`.`service_resources` AS `service_resources`,`products_tbl`.`subscription_require_email` AS `subscription_require_email`,`products_tbl`.`subscription_require_phone` AS `subscription_require_phone`,`products_tbl`.`subscription_recurring` AS `subscription_recurring`,`products_tbl`.`lang_1_currency` AS `lang_1_currency`,`products_tbl`.`lang_2_currency` AS `lang_2_currency`,`products_tbl`.`lang_3_currency` AS `lang_3_currency`,`products_tbl`.`lang_4_currency` AS `lang_4_currency`,`products_tbl`.`lang_5_currency` AS `lang_5_currency`,`products_tbl`.`lang_1_currency_freq` AS `lang_1_currency_freq`,`products_tbl`.`lang_2_currency_freq` AS `lang_2_currency_freq`,`products_tbl`.`lang_3_currency_freq` AS `lang_3_currency_freq`,`products_tbl`.`lang_4_currency_freq` AS `lang_4_currency_freq`,`products_tbl`.`lang_5_currency_freq` AS `lang_5_currency_freq`,`products_tbl`.`allow_ratings` AS `allow_ratings`,`products_tbl`.`allow_comments` AS `allow_comments`,`products_tbl`.`allow_complaints` AS `allow_complaints`,`products_tbl`.`allow_questions` AS `allow_questions`,`products_tbl`.`created_by` AS `created_by`,`products_tbl`.`created_on` AS `created_on`,`products_tbl`.`updated_by` AS `updated_by`,`products_tbl`.`updated_on` AS `updated_on`,`products_tbl`.`show_store_locator` AS `show_store_locator`,`products_tbl`.`cart_url` AS `cart_url`,`products_tbl`.`cart_prod_url` AS `cart_prod_url`,`products_tbl`.`cart_url_params` AS `cart_url_params`,`products_tbl`.`store_locator_url` AS `store_locator_url`,`products_tbl`.`store_locator_prod_url` AS `store_locator_prod_url`,`products_tbl`.`store_locator_url_params` AS `store_locator_url_params`,`products_tbl`.`familie_id` AS `familie_id`,`products_tbl`.`lang_1_pricesent` AS `lang_1_pricesent`,`products_tbl`.`lang_2_pricesent` AS `lang_2_pricesent`,`products_tbl`.`lang_3_pricesent` AS `lang_3_pricesent`,`products_tbl`.`lang_4_pricesent` AS `lang_4_pricesent`,`products_tbl`.`lang_5_pricesent` AS `lang_5_pricesent`,`products_tbl`.`product_uuid` AS `product_uuid`,`products_tbl`.`rating_score` AS `rating_score`,`products_tbl`.`rating_count` AS `rating_count`,`products_tbl`.`invoice_nature` AS `invoice_nature`,`products_tbl`.`app_id` AS `app_id`,`products_tbl`.`color` AS `color`,`products_tbl`.`pack_details` AS `pack_details`,`products_tbl`.`import_source` AS `import_source`,`products_tbl`.`version` AS `version`,`products_tbl`.`device_type` AS `device_type`,`products_tbl`.`sort_variant` AS `sort_variant`,`products_tbl`.`first_publish_on` AS `first_publish_on`,`products_tbl`.`select_variant_by` AS `select_variant_by`,`products_tbl`.`html_variant` AS `html_variant`,`products_tbl`.`is_deleted` AS `is_deleted`,`products_tbl`.`product_definition_id` AS `product_definition_id`,`products_tbl`.`product_version` AS `product_version` from `products_tbl` where `products_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products_definition`
--

/*!50001 DROP TABLE IF EXISTS `products_definition`*/;
/*!50001 DROP VIEW IF EXISTS `products_definition`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products_definition` AS select `products_definition_tbl`.`id` AS `id`,`products_definition_tbl`.`uuid` AS `uuid`,`products_definition_tbl`.`save_type` AS `save_type`,`products_definition_tbl`.`name` AS `name`,`products_definition_tbl`.`url` AS `url`,`products_definition_tbl`.`title` AS `title`,`products_definition_tbl`.`meta_description` AS `meta_description`,`products_definition_tbl`.`product_type` AS `product_type`,`products_definition_tbl`.`site_id` AS `site_id`,`products_definition_tbl`.`catalog_id` AS `catalog_id`,`products_definition_tbl`.`folder_id` AS `folder_id`,`products_definition_tbl`.`piblish_ts` AS `piblish_ts`,`products_definition_tbl`.`piblish_by` AS `piblish_by`,`products_definition_tbl`.`to_publish` AS `to_publish`,`products_definition_tbl`.`created_ts` AS `created_ts`,`products_definition_tbl`.`created_by` AS `created_by`,`products_definition_tbl`.`updated_ts` AS `updated_ts`,`products_definition_tbl`.`updated_by` AS `updated_by`,`products_definition_tbl`.`is_deleted` AS `is_deleted` from `products_definition_tbl` where `products_definition_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products_folders`
--

/*!50001 DROP TABLE IF EXISTS `products_folders`*/;
/*!50001 DROP VIEW IF EXISTS `products_folders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products_folders` AS select `products_folders_tbl`.`id` AS `id`,`products_folders_tbl`.`uuid` AS `uuid`,`products_folders_tbl`.`name` AS `name`,`products_folders_tbl`.`site_id` AS `site_id`,`products_folders_tbl`.`catalog_id` AS `catalog_id`,`products_folders_tbl`.`parent_folder_id` AS `parent_folder_id`,`products_folders_tbl`.`folder_level` AS `folder_level`,`products_folders_tbl`.`version` AS `version`,`products_folders_tbl`.`created_on` AS `created_on`,`products_folders_tbl`.`updated_on` AS `updated_on`,`products_folders_tbl`.`created_by` AS `created_by`,`products_folders_tbl`.`updated_by` AS `updated_by`,`products_folders_tbl`.`is_deleted` AS `is_deleted` from `products_folders_tbl` where `products_folders_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products_folders_lang_path`
--

/*!50001 DROP TABLE IF EXISTS `products_folders_lang_path`*/;
/*!50001 DROP VIEW IF EXISTS `products_folders_lang_path`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products_folders_lang_path` AS select `f`.`site_id` AS `site_id`,`f`.`id` AS `folder_id`,`fd`.`langue_id` AS `langue_id`,concat_ws('/',nullif(`fd2`.`path_prefix`,''),nullif(`fd`.`path_prefix`,'')) AS `concat_path`,`f`.`folder_level` AS `folder_level`,`fd`.`path_prefix` AS `path1`,`fd2`.`path_prefix` AS `path2` from (((`products_folders` `f` join `products_folders_details` `fd` on(`fd`.`folder_id` = `f`.`id`)) left join `products_folders` `f2` on(`f`.`parent_folder_id` = `f2`.`id`)) left join `products_folders_details` `fd2` on(`fd2`.`folder_id` = `f2`.`id` and `fd`.`langue_id` = `fd2`.`langue_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `promotions`
--

/*!50001 DROP TABLE IF EXISTS `promotions`*/;
/*!50001 DROP VIEW IF EXISTS `promotions`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `promotions` AS select `promotions_tbl`.`id` AS `id`,`promotions_tbl`.`name` AS `name`,`promotions_tbl`.`order_seq` AS `order_seq`,`promotions_tbl`.`created_by` AS `created_by`,`promotions_tbl`.`created_on` AS `created_on`,`promotions_tbl`.`updated_by` AS `updated_by`,`promotions_tbl`.`updated_on` AS `updated_on`,`promotions_tbl`.`start_date` AS `start_date`,`promotions_tbl`.`end_date` AS `end_date`,`promotions_tbl`.`flash_sale` AS `flash_sale`,`promotions_tbl`.`flash_sale_quantity` AS `flash_sale_quantity`,`promotions_tbl`.`visible_to` AS `visible_to`,`promotions_tbl`.`discount_type` AS `discount_type`,`promotions_tbl`.`discount_value` AS `discount_value`,`promotions_tbl`.`duration` AS `duration`,`promotions_tbl`.`lang_1_description` AS `lang_1_description`,`promotions_tbl`.`lang_2_description` AS `lang_2_description`,`promotions_tbl`.`lang_3_description` AS `lang_3_description`,`promotions_tbl`.`lang_4_description` AS `lang_4_description`,`promotions_tbl`.`lang_5_description` AS `lang_5_description`,`promotions_tbl`.`site_id` AS `site_id`,`promotions_tbl`.`version` AS `version`,`promotions_tbl`.`lang_1_title` AS `lang_1_title`,`promotions_tbl`.`lang_2_title` AS `lang_2_title`,`promotions_tbl`.`lang_3_title` AS `lang_3_title`,`promotions_tbl`.`lang_4_title` AS `lang_4_title`,`promotions_tbl`.`lang_5_title` AS `lang_5_title`,`promotions_tbl`.`frequency` AS `frequency`,`promotions_tbl`.`is_deleted` AS `is_deleted` from `promotions_tbl` where `promotions_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `quantitylimits`
--

/*!50001 DROP TABLE IF EXISTS `quantitylimits`*/;
/*!50001 DROP VIEW IF EXISTS `quantitylimits`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `quantitylimits` AS select `quantitylimits_tbl`.`id` AS `id`,`quantitylimits_tbl`.`name` AS `name`,`quantitylimits_tbl`.`order_seq` AS `order_seq`,`quantitylimits_tbl`.`created_by` AS `created_by`,`quantitylimits_tbl`.`created_on` AS `created_on`,`quantitylimits_tbl`.`updated_by` AS `updated_by`,`quantitylimits_tbl`.`updated_on` AS `updated_on`,`quantitylimits_tbl`.`quantity_limit` AS `quantity_limit`,`quantitylimits_tbl`.`lang_1_description` AS `lang_1_description`,`quantitylimits_tbl`.`lang_2_description` AS `lang_2_description`,`quantitylimits_tbl`.`lang_3_description` AS `lang_3_description`,`quantitylimits_tbl`.`lang_4_description` AS `lang_4_description`,`quantitylimits_tbl`.`lang_5_description` AS `lang_5_description`,`quantitylimits_tbl`.`site_id` AS `site_id`,`quantitylimits_tbl`.`version` AS `version`,`quantitylimits_tbl`.`is_deleted` AS `is_deleted` from `quantitylimits_tbl` where `quantitylimits_tbl`.`is_deleted` = 0 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `subsidies`
--

/*!50001 DROP TABLE IF EXISTS `subsidies`*/;
/*!50001 DROP VIEW IF EXISTS `subsidies`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `subsidies` AS select `subsidies_tbl`.`id` AS `id`,`subsidies_tbl`.`order_seq` AS `order_seq`,`subsidies_tbl`.`site_id` AS `site_id`,`subsidies_tbl`.`version` AS `version`,`subsidies_tbl`.`created_by` AS `created_by`,`subsidies_tbl`.`created_on` AS `created_on`,`subsidies_tbl`.`updated_by` AS `updated_by`,`subsidies_tbl`.`updated_on` AS `updated_on`,`subsidies_tbl`.`name` AS `name`,`subsidies_tbl`.`lang_1_description` AS `lang_1_description`,`subsidies_tbl`.`lang_2_description` AS `lang_2_description`,`subsidies_tbl`.`lang_3_description` AS `lang_3_description`,`subsidies_tbl`.`lang_4_description` AS `lang_4_description`,`subsidies_tbl`.`lang_5_description` AS `lang_5_description`,`subsidies_tbl`.`visible_to` AS `visible_to`,`subsidies_tbl`.`start_date` AS `start_date`,`subsidies_tbl`.`end_date` AS `end_date`,`subsidies_tbl`.`discount_type` AS `discount_type`,`subsidies_tbl`.`discount_value` AS `discount_value`,`subsidies_tbl`.`applied_to_type` AS `applied_to_type`,`subsidies_tbl`.`applied_to_value` AS `applied_to_value`,`subsidies_tbl`.`redirect_url` AS `redirect_url`,`subsidies_tbl`.`open_as` AS `open_as`,`subsidies_tbl`.`is_deleted` AS `is_deleted` from `subsidies_tbl` where `subsidies_tbl`.`is_deleted` = 0 */;
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

-- Dump completed on 2025-03-22 20:48:59
