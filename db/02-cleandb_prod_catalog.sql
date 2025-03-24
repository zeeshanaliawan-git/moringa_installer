-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: cleandb_prod_catalog
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
-- Table structure for table `additionalfee_rules_v44`
--

DROP TABLE IF EXISTS `additionalfee_rules_v44`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additionalfee_rules_v44` (
  `id` int(11) NOT NULL DEFAULT 0,
  `add_fee_id` int(11) NOT NULL,
  `rule_apply` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `rule_apply_value` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `element_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `element_type_value` varchar(100) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `additionalfee_rules_v44`
--

LOCK TABLES `additionalfee_rules_v44` WRITE;
/*!40000 ALTER TABLE `additionalfee_rules_v44` DISABLE KEYS */;
INSERT INTO `additionalfee_rules_v44` VALUES (81,19,'deposit','3','sku','Offer-prepaid-2V-1'),(71,15,'deposit','40000','sku','Offre_Fibre_essentiel'),(63,13,'adv_amt','10','product_type','44');
/*!40000 ALTER TABLE `additionalfee_rules_v44` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `additionalfees`
--

DROP TABLE IF EXISTS `additionalfees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `additionalfees` (
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
-- Dumping data for table `additionalfees`
--

LOCK TABLES `additionalfees` WRITE;
/*!40000 ALTER TABLE `additionalfees` DISABLE KEYS */;
/*!40000 ALTER TABLE `additionalfees` ENABLE KEYS */;
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
-- Table structure for table `calendar`
--

DROP TABLE IF EXISTS `calendar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calendar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `type` varchar(50) NOT NULL COMMENT '1-Public Holiday, 2-Exclusion',
  `product_id` varchar(10) DEFAULT NULL,
  `catalog_id` varchar(10) DEFAULT NULL,
  `minus_stock` varchar(5) DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `resources` varchar(50) DEFAULT '',
  `linked_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calendar`
--

LOCK TABLES `calendar` WRITE;
/*!40000 ALTER TABLE `calendar` DISABLE KEYS */;
INSERT INTO `calendar` VALUES (8,'2017-10-18','1',NULL,NULL,NULL,NULL,NULL,'',NULL),(9,'2017-10-19','1',NULL,NULL,NULL,NULL,NULL,'',NULL),(10,'2017-10-20','1',NULL,NULL,NULL,NULL,NULL,'',NULL),(11,'2017-10-21','1',NULL,NULL,NULL,NULL,NULL,'',NULL),(12,'2017-10-22','2',NULL,NULL,NULL,'00:30:00','00:45:00','AA',NULL),(13,'2017-10-23','2',NULL,NULL,NULL,'00:30:00','00:45:00','AA',NULL),(14,'2017-10-24','2',NULL,NULL,NULL,'00:30:00','00:45:00','AA',NULL);
/*!40000 ALTER TABLE `calendar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_promotion`
--

DROP TABLE IF EXISTS `cart_promotion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_promotion` (
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
-- Dumping data for table `cart_promotion`
--

LOCK TABLES `cart_promotion` WRITE;
/*!40000 ALTER TABLE `cart_promotion` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_promotion` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `cart_promotion_v48`
--

DROP TABLE IF EXISTS `cart_promotion_v48`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cart_promotion_v48` (
  `id` int(11) NOT NULL DEFAULT 0,
  `order_seq` int(11) DEFAULT NULL,
  `site_id` int(10) NOT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `description` text CHARACTER SET utf8 DEFAULT NULL,
  `visible_to` varchar(10) CHARACTER SET utf8 NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `auto_generate_cc` tinyint(1) NOT NULL DEFAULT 0,
  `uses_per_coupon` int(10) DEFAULT NULL,
  `uses_per_customer` int(10) DEFAULT NULL,
  `coupon_quantity` int(10) DEFAULT NULL,
  `cc_length` int(10) DEFAULT NULL,
  `cc_prefix` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `rule_field` tinyint(1) NOT NULL DEFAULT 0,
  `rule_type` varchar(25) CHARACTER SET utf8 DEFAULT NULL,
  `verify_condition` varchar(25) CHARACTER SET utf8 DEFAULT NULL,
  `rule_condition` varchar(12) CHARACTER SET utf8 DEFAULT NULL,
  `rule_condition_value` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `discount_type` varchar(10) CHARACTER SET utf8 NOT NULL,
  `discount_value` varchar(10) CHARACTER SET utf8 NOT NULL,
  `element_on` varchar(20) CHARACTER SET utf8 NOT NULL,
  `element_on_value` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_promotion_v48`
--

LOCK TABLES `cart_promotion_v48` WRITE;
/*!40000 ALTER TABLE `cart_promotion_v48` DISABLE KEYS */;
INSERT INTO `cart_promotion_v48` VALUES (36,0,8,0,59,'2022-08-04 07:06:48',0,NULL,'Promo code','','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,0,0,0,0,'',0,'','','','','fixed','10','cart_total','',0),(45,0,3,0,85,'2022-12-20 10:15:43',0,NULL,'3905','3905','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,50,0,0,0,'',0,'','','','','percentage','90','cart_total','',0),(24,0,3,0,85,'2021-05-28 06:31:32',0,NULL,'TESTB','','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,1,0,0,0,'',0,'cart_product','sku','is','Apple-iPhone-7-128Go','fixed','100','sku','Apple-iPhone-7-128Go',0),(21,0,3,0,59,'2021-05-19 13:26:06',0,NULL,'COUPONB','','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,0,0,0,0,'',0,'cart_product','sku','is','Apple-iPhone-7-128Go','fixed','50','sku','Apple-iPhone-7-128Go',0),(25,0,3,2,62,'2021-05-28 07:17:01',62,NULL,'Summer Exclusive','Shan - Summer Exclusive','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,3,0,0,0,'',1,'cart_product','sku','is','OnePlus_Nord_Blanc_128Go','fixed','49','sku','OnePlus_Nord_Blanc_128Go',0),(20,0,3,2,59,'2021-05-28 06:15:58',62,NULL,'COUPON','test coupon cart on a product','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,0,0,0,0,'',0,'cart_product','sku','is','Apple-iPhone-7-128Go','fixed','50','sku','Apple-iPhone-7-128Go',0),(27,0,3,2,59,'2022-05-04 12:23:21',59,NULL,'VOUCHER','Voucher','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,0,0,0,0,'',0,'','','','','fixed','39900','cart_total','',0),(28,0,3,0,59,'2021-10-14 14:29:03',0,NULL,'VOUCHERP','ssss','all','0000-00-00 00:00:00','0000-00-00 00:00:00',1,0,0,10,8,'VP',0,'','','','','percentage','10','cart_total','',0),(29,0,3,0,59,'2021-10-14 14:31:37',0,NULL,'VOUCHERP2','','all','0000-00-00 00:00:00','0000-00-00 00:00:00',1,1,0,6,10,'VP2',0,'','','','','fixed','10000','cart_total','',0),(16,0,3,0,59,'2021-10-14 14:32:32',0,NULL,'Promotion salarié','Promotion salarié','all','0000-00-00 00:00:00','0000-00-00 00:00:00',1,1,0,100,10,'ORA',0,'cart_attribute','total_quantity','is','1','percentage','20','cart_total','',0),(31,0,3,0,89,'2022-07-11 09:21:28',0,NULL,'NOEL2022','Bénéficiez de la livraison à domicile gratuite pour vos achats de Noël!','all','0000-00-00 00:00:00','0000-00-00 00:00:00',0,10000,0,0,0,'',1,'cart_attribute','delivery_method','is','home_delivery','percentage','100','shipping_fee','',0),(32,0,3,0,89,'2022-07-11 09:21:28',0,NULL,'Orange VIP 2022','Orange Burkina Faso récompense ses meilleurs clients avec un bon de réduction de 20% sur votre prochaine commande !','all','0000-00-00 00:00:00','0000-00-00 00:00:00',1,0,0,100,13,'OrangeVIP',0,'cart_product','catalog','is','7','percentage','20','cart_total','',0),(34,0,3,0,89,'2022-07-11 09:34:01',0,NULL,'VIP 2022','Orange Burkina Faso récompense ses meilleurs clients avec un bon de réduction de 20% sur votre prochaine commande !','all','0000-00-00 00:00:00','0000-00-00 00:00:00',1,1,0,100,11,'VIP2022',0,'','','','','percentage','20','cart_total','',0);
/*!40000 ALTER TABLE `cart_promotion_v48` ENABLE KEYS */;
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
-- Table structure for table `catalogs`
--

DROP TABLE IF EXISTS `catalogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalogs` (
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
  `product_types_custom` text DEFAULT NULL COMMENT 'comma-seperated custom product types for this catalog',
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
  `price_tax_included` tinyint(1) NOT NULL DEFAULT 0,
  `manufacturers` text DEFAULT NULL,
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
  UNIQUE KEY `site_id_name` (`site_id`,`name`),
  UNIQUE KEY `site_id_uuid` (`site_id`,`catalog_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `catalogs`
--

LOCK TABLES `catalogs` WRITE;
/*!40000 ALTER TABLE `catalogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `catalogs` ENABLE KEYS */;
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
-- Table structure for table `comewiths`
--

DROP TABLE IF EXISTS `comewiths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comewiths` (
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
-- Dumping data for table `comewiths`
--

LOCK TABLES `comewiths` WRITE;
/*!40000 ALTER TABLE `comewiths` DISABLE KEYS */;
/*!40000 ALTER TABLE `comewiths` ENABLE KEYS */;
UNLOCK TABLES;

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
INSERT INTO `config` VALUES ('CART_COOKIE','asimina_prodcatalogCartItems',NULL),('CART_URL','/asimina_prodportal/',NULL),('CATALOG_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/catalogs/essentials/',NULL),('CATALOG_INTERNAL_LINK','http://127.0.0.1/asimina_prodcatalog/',NULL),('COMMONS_DB','cleandb_commons',NULL),('EXTERNAL_CATALOG_LINK','/asimina_prodcatalog/',NULL),('FAMILIE_IMAGES_PATH','/asimina_prodcatalog/uploads/familie/',NULL),('IS_PROD_ENVIRONMENT','1',NULL),('LANDINGPAGE_IMAGES_PATH','/asimina_prodcatalog/uploads/landingpage/',NULL),('max_catalogs_folder_level','4',NULL),('max_category_level','5',NULL),('PORTAL_DB','cleandb_prod_portal',NULL),('PORTAL_URL','/asimina_prodportal/',NULL),('PRODUCTS_IMG_PATH','/asimina_prodcatalog/uploads/products/',NULL),('PRODUCTS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/products/',NULL),('PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/essentials/',NULL),('PRODUCT_SHAREBAR_IMAGES_PATH','/asimina_prodcatalog/uploads/sharebar/products/',NULL),('PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY','/home/asimina/tomcat/webapps/asimina_prodcatalog/uploads/sharebar/products/',NULL),('share_bar_twitter_bitly_token','',NULL),('SHOP_DB','cleandb_prod_shop',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
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
-- Table structure for table `deliveryfees`
--

DROP TABLE IF EXISTS `deliveryfees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveryfees` (
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
-- Dumping data for table `deliveryfees`
--

LOCK TABLES `deliveryfees` WRITE;
/*!40000 ALTER TABLE `deliveryfees` DISABLE KEYS */;
/*!40000 ALTER TABLE `deliveryfees` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `deliverymins`
--

DROP TABLE IF EXISTS `deliverymins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliverymins` (
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
-- Dumping data for table `deliverymins`
--

LOCK TABLES `deliverymins` WRITE;
/*!40000 ALTER TABLE `deliverymins` DISABLE KEYS */;
/*!40000 ALTER TABLE `deliverymins` ENABLE KEYS */;
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
  `attribute_value` varchar(100) NOT NULL DEFAULT '',
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
  `product_id` int(11) NOT NULL,
  `user` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `comment` text CHARACTER SET latin1 DEFAULT NULL,
  `is_guest` tinyint(4) DEFAULT 0,
  `tm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
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
  `actual_file_name` varchar(500) DEFAULT NULL,
  `image_label` varchar(100) DEFAULT NULL,
  `order_seq` int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
  `content` text DEFAULT NULL,
  `order_seq` tinyint(3) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
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
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max consecutive no of slots per service booking',
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
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
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
  `familie_id` int(11) DEFAULT NULL,
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
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_02122022`
--

DROP TABLE IF EXISTS `products_02122022`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_02122022` (
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
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max consecutive no of slots per service booking',
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
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
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
  `familie_id` int(11) DEFAULT NULL,
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
-- Dumping data for table `products_02122022`
--

LOCK TABLES `products_02122022` WRITE;
/*!40000 ALTER TABLE `products_02122022` DISABLE KEYS */;
INSERT INTO `products_02122022` VALUES (1,3,0,NULL,'',0,0,0,2,'','','product','','Apple','iPhone 7','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e51ec17f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',17,'','cu',NULL,'attributes','all',0),(2,3,0,NULL,'',0,0,0,7,'','','product','','Samsung','Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e52258e3-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0),(3,3,0,NULL,'',0,0,0,8,'','','product','','Samsung','Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e524eb7d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(4,3,0,NULL,'',0,0,0,11,'','','product','','Tecno','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e5275f7a-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0),(5,3,0,NULL,'',0,0,0,3,'','','product','','Apple','iPhone X','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e529a69d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(6,3,0,NULL,'',0,0,0,1,'','','product','','Alcatel','1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52bfeb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(7,3,0,NULL,'',0,0,0,5,'','','product','','Samsung','Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52e4cb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(8,3,0,NULL,'',0,0,0,6,'','','product','','Samsung','Galaxy A8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e530bbef-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(9,3,0,NULL,'',0,0,0,4,'','','product','','Apple','iPhone XS Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5330b16-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(10,3,0,NULL,'',0,0,0,9,'','','product','','Samsung','S10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5358bed-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(11,3,0,NULL,'',0,0,0,12,'','','product','','Tecno','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e537c161-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(12,3,0,NULL,'',0,0,0,10,'','','product','','Samsung','S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e539c73f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(19,7,0,NULL,'NA71311',1,1,0,8,'','','product','','Samsung','Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',82,NULL,0,'','','','','','',0,'','','','','','37e46c49-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',13,'mobile','cu','2021-05-04 14:07:50','attributes','all',0),(30,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','b9fec1af-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-05-18 14:37:20','attributes','all',0),(32,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba0271d1-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cu','2021-05-18 14:37:41','attributes','all',0),(29,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba050e3d-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-05-18 14:38:44','attributes','all',0),(31,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba079127-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cu','2021-05-18 14:38:33','attributes','all',0),(34,7,0,NULL,'NA73732',1,1,0,6,'','','product','','Itel','it2130','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-04-20 15:17:45',59,NULL,0,'','','','','','',0,'','','','','','3819aaab-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-05-04 14:08:09','attributes','all',0),(231,1,0,NULL,'',0,0,0,22,'','','product','','','Orange Halona','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:39:59',84,NULL,0,'','','','','','',0,'','','','','','bdaeccfe-1184-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-09 15:44:50','attributes','all',0),(26,7,0,0,'NA70452',1,0,0,11,'','','product','','Tecno','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',56,NULL,0,'','','','','','',0,'','','','','','3814dd16-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:52','attributes','all',0),(25,7,3,NULL,'NA86072',1,1,0,5,'','','product','','Apple','iPhone XS Max','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','380d4afa-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-05-04 14:06:55','attributes','all',0),(24,7,0,NULL,'NA79551',1,1,0,7,'','','product','','Samsung','Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',82,NULL,0,'','','','','','',0,'','','','','','3806c3a0-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-05-04 14:08:20','attributes','all',0),(23,7,0,NULL,'NA79511',1,1,0,2,'','','product','','Alcatel','Neo 1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-05-12 12:33:09',59,NULL,0,'','','','','','',0,'','','','','','3800b9bc-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-05-04 14:08:04','attributes','all',0),(22,7,0,NULL,'NA76351',1,1,0,10,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',82,NULL,0,'','','','','','',0,'','','','','','37f9f305-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-05-04 14:07:50','attributes','all',0),(20,7,0,NULL,'NA78851',1,1,0,9,'','','product','','Samsung','Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',82,NULL,0,'','','','','','',0,'','','','','','37eae657-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',10,'mobile','cu','2021-05-04 14:07:38','attributes','all',0),(21,7,3,NULL,'NA77753',1,1,0,4,'','','product','','Apple','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','37f16683-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2021-05-04 14:06:45','attributes','all',0),(17,6,0,NULL,'',0,0,0,0,'','','product','','Samsung','Galaxy S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-08-05 14:01:40',1,NULL,0,'','','','','','',0,'','','','','','280fea73-d724-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0),(92,7,0,0,'NA80112',1,0,0,12,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-08-18 13:43:03',56,NULL,0,'','','','','','',0,'','','','','','5d452512-53f8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:25','attributes','all',0),(117,1,0,NULL,'',0,0,0,56,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','0bc7ddd2-4b5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2020-12-31 11:20:05','attributes','all',0),(126,1,0,NULL,'NA99371',1,0,0,54,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','79f5c526-617a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-01-28 15:07:16','attributes','all',0),(133,21,0,NULL,'',0,0,0,0,'','','product','','Test','test','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-02-24 09:42:37',0,NULL,0,'','','','','','',0,'','','','','','a0f996ea-7684-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-02-24 09:43:10','attributes','all',0),(218,7,0,NULL,'',0,1,1,0,'','','product','','OnePlus','Nord','Nord','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2021-08-18 13:43:04',62,NULL,0,'','','','','','',0,'','','','','','8551df06-bf84-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-05-28 07:16:30','attributes','all',0),(41,13,0,NULL,'',0,0,0,0,'','','product','','Testift','testift','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-12 09:29:21',0,NULL,0,'','','','','','',0,'','','','','','68d9d606-0c6d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0),(42,1,0,NULL,'NA85811',1,0,0,28,'','','product','','Orange','Sanza','Orange Sanza','Orange Sanza','Orange Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','908f5515-0d5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-11-03 14:53:11','attributes','all',0),(84,15,0,NULL,'NA99191',1,1,1,1,'','','product','','OPPO','Reno 2','Reno 2','Reno 2','Reno 2','Reno 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','5403e5ff-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',24,'mobile','cu','2022-09-07 06:01:45','attributes','all',0),(86,15,0,NULL,'NA97251',1,1,1,4,'','','product','','Samsung','Galaxy Note 9','Galaxy Note 9','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','540fef9a-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-05 04:19:07','attributes','all',0),(85,15,0,NULL,'NA99292',1,1,1,5,'','','product','','OPPO','A91','A91','A91','A91','A91','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','540ace4f-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',18,'mobile','cu','2021-03-05 04:18:18','attributes','all',0),(43,1,0,NULL,'NA96411',1,0,0,20,'','','product','','Itel','MC20','MC20','MC20','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','41806800-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:34:03','attributes','all',0),(44,1,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ebc041dd-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:51:45','attributes','all',0),(45,1,0,NULL,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','61c0bfa9-0fc0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-30 14:51:54','attributes','all',0),(48,1,0,NULL,'NA99307',1,0,0,45,'','','product','','Samsung','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','43c4e363-0fc2-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 09:54:04','attributes','all',0),(49,1,0,NULL,'NA99308',1,0,0,46,'','','product','','Samsung','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','6ca3550d-0fc3-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:55:03','attributes','all',0),(50,1,0,NULL,'NA99526',1,0,0,53,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','62801c47-0fc4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 11:11:57','attributes','all',0),(51,1,0,NULL,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iPhone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','192596fc-0fc6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 15:51:00','attributes','all',0),(91,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Monthly Mega Plus','Jazz - Monthly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12211677-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:37','attributes','all',0),(90,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','122acaee-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:31','attributes','all',0),(199,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','1232e5e4-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:42:18','attributes','all',0),(33,7,0,NULL,'NA80551',1,1,1,1,'','','product','','Alcatel','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-11-18 10:25:20',62,NULL,0,'','','','','','',0,'','','','','','7d73b01d-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2021-05-04 14:07:27','attributes','all',0),(35,11,0,NULL,'',0,0,0,0,'','','product','','','Homebox haut-débit 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-11-03 14:59:25',1,NULL,0,'','','','','','',0,'','','','','','2a10bb19-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',22,'','cu','2020-11-03 15:01:01','attributes','all',0),(37,11,0,0,'',0,0,0,0,'','','product','','','Airbox 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-02-17 15:36:54',56,NULL,0,'','','','','','',0,'','','','','','2a16f2b0-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cu','2022-02-17 15:36:55','attributes','all',0),(97,1,0,NULL,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','6e3aef88-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-11-26 10:59:49','attributes','logged',0),(58,1,0,NULL,'NA76351',1,0,0,58,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','e6198413-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-26 11:03:16','attributes','all',0),(59,1,0,NULL,'NA80112',1,0,0,60,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','31c2b493-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:04:46','attributes','all',0),(98,1,0,NULL,'',0,0,0,48,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','c5bfed7f-2fd8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2020-11-26 11:16:57','attributes','all',0),(99,1,0,NULL,'NA99975',1,0,0,49,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','5fe0bbf7-3328-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 16:23:58','attributes','all',0),(102,1,0,NULL,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14a8df75-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:30','attributes','all',0),(103,1,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3','U3 4G','U3 4G','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14af9103-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:55','attributes','all',0),(105,1,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s','iPhone 6s 16GB','iPhone 6s 16GB','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','80638f62-4aae-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 14:51:44','attributes','all',0),(106,1,0,NULL,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','iPhone XS','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','5036f54c-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:12:49','attributes','all',0),(107,1,0,NULL,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max','iPhone XS Max 512GB','iPhone XS Max 512GB','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','f02d2074-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:16:22','attributes','all',0),(52,1,0,NULL,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','33cb4a44-4ab4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:33:00','attributes','all',0),(108,1,0,NULL,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','0794ea79-4ab5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:38:28','attributes','all',0),(109,1,0,NULL,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ae75c665-4ab6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:51:19','attributes','all',0),(110,1,0,NULL,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','4c394816-4ab7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:55:40','attributes','all',0),(96,1,0,NULL,'NA73732',1,0,0,17,'','','product','','Itel','IT2130','IT2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','2281091f-4ab8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:01:09','attributes','all',0),(111,1,0,NULL,'NA85691',1,0,0,19,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','7973f18c-4abc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:31:48','attributes','all',0),(62,1,0,NULL,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','Mahpee','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f84fe49c-4abd-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:43:37','attributes','all',0),(63,1,0,NULL,'NA76811',1,0,0,26,'','','product','','Orange','Rise 53','Rise 53','Rise 53','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','37536730-4ac0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:58:55','attributes','all',0),(112,1,0,NULL,'NA97811',1,0,0,27,'','','product','','Orange','Rise 55','Rise 55','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9a4d5326-4ac6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 17:45:19','attributes','all',0),(113,1,0,NULL,'NA99129',1,0,0,38,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3eff26ac-4b4a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:26:31','attributes','all',0),(114,1,0,NULL,'NA99225',1,0,0,39,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','0f5485af-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:40:35','attributes','all',0),(57,1,0,NULL,'NA99197',1,0,0,42,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','ece291b1-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:46:46','attributes','all',0),(53,1,0,NULL,'NA99212',1,0,0,44,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','a963e4f4-4b4d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:51:32','attributes','all',0),(46,1,0,NULL,'NA99730',1,0,0,32,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','0e3e7f7d-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:53:56','attributes','all',0),(47,1,0,NULL,'NA99224',1,0,0,33,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','98b16401-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:54:47','attributes','all',0),(56,1,0,NULL,'NA99128',1,0,0,34,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','c82806ff-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:09:08','attributes','all',0),(100,1,0,NULL,'NA99374',1,0,0,36,'','','product','','Samsung','Galaxy A11','Galaxy A11','MEA only - A11','MEA only - A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','11495a56-332a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2020-11-30 16:35:50','attributes','all',0),(101,1,0,NULL,'NA99378',1,0,0,47,'','','product','','Samsung','Galaxy M11','MEA only - M11','MEA only - M11','MEA only - M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','4ef8da0c-332d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 17:00:05','attributes','all',0),(115,1,0,NULL,'NA97291',1,0,0,50,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3f8a4505-4b56-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 10:53:10','attributes','all',0),(116,1,0,NULL,'NA97293',1,0,0,51,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','266fbe41-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:07:18','attributes','all',0),(60,1,0,NULL,'NA99367',1,0,0,52,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','bbf20cc9-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:10:20','attributes','all',0),(118,1,0,NULL,'NA96431',1,0,0,57,'','','product','','Tecno','N11','N11','N11','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','19e2818a-4b6a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 13:14:25','attributes','all',0),(119,1,0,NULL,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','bb045aa5-4b71-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 14:09:26','attributes','all',0),(120,1,0,NULL,'NA99062',1,0,0,18,'','','product','','Itel','IT2132','IT2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','8907ffc6-4b73-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-31 14:22:06','attributes','all',0),(121,1,0,NULL,'NA84092',1,0,0,21,'','','product','','Mobiwire','AX2408','AX2408','AX2408','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f7dae2d4-4b74-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 14:32:17','attributes','all',0),(122,1,0,NULL,'NA99960',1,0,0,35,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','100e8834-4b79-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-12-31 15:03:01','attributes','all',0),(123,1,0,NULL,'NA99508',1,0,0,30,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','ec3349e3-4b7c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-31 15:30:25','attributes','all',0),(124,1,0,NULL,'NA99662',1,0,0,41,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','d36cae36-4b81-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:04:51','attributes','all',0),(55,1,0,NULL,'NA71191',1,0,0,64,'','','product','','Wiko','Sunny','SUNNY','SUNNY','SUNNY','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','4312afeb-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:07:32','attributes','all',0),(54,1,0,NULL,'NA79491',1,0,0,65,'','','product','','Wiko','Tommy3','TOMMY3','TOMMY3','TOMMY3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','bf7ea052-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:12:16','attributes','all',0),(132,1,0,NULL,'NA99294',1,0,0,61,'','','product','','Tecno','R7+','R7+','R7+','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','5273cd2f-61af-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-01-28 21:26:15','attributes','all',0),(128,1,0,NULL,'NA99210',1,0,0,29,'','','product','','Orange','Sanza 2','Sanza 2','Sanza 2','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9264ecbd-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:29','attributes','all',0),(129,1,0,NULL,'NA99064',1,0,0,31,'','','product','','Orange','Sanza XL','Sanza XL','Sanza XL','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','92717ac5-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:19','attributes','all',0),(130,1,0,NULL,'NA99736',1,0,0,43,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','92b46e91-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:20','attributes','all',0),(131,1,0,NULL,'',0,0,0,55,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',0,NULL,0,'','','','','','',0,'','','','','','93067e8f-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-01-28 18:28:25','attributes','all',0),(192,15,0,NULL,'NA74171',1,1,1,9,'','','product','','Blackberry Mobile','KEYone','KEYone','KEYone','KEYone','KEYone','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',85,NULL,0,'','','','','','',0,'','','','','','7adc0aeb-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-03-06 12:36:56','attributes','all',0),(193,15,0,NULL,'NA99266',1,1,1,8,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7ae4c517-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-06 12:35:51','attributes','all',0),(194,15,0,NULL,'NA65430',1,1,1,7,'','','product','','Apple','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7aebe125-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'Tablet','cu','2021-03-06 12:36:22','attributes','all',0),(195,15,0,NULL,'NA83732',1,1,1,11,'','','product','','Samsung','Galaxy S9+','Galaxy S9+','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af2d920-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-03-06 12:37:03','attributes','all',0),(214,15,0,NULL,'NA99971',1,0,0,6,'','','product','','Apple','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',0,NULL,0,'','','','','','',0,'','','','','','b180c68e-da66-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-07-01 12:21:37','attributes','all',0),(196,15,0,NULL,'NA55627',1,1,1,10,'','','product','','Samsung','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af9c988-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'Tablet','cu','2021-03-06 12:35:50','attributes','all',0),(191,15,0,NULL,'',0,1,1,3,'','','product','','','One Plus','One Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','7b00e72f-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-03-06 12:37:24','attributes','all',0),(89,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','123ad363-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',8,'','cu','2020-11-03 14:59:20','attributes','all',0),(198,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12185468-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:41:24','attributes','all',0),(197,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 06:49:31',62,NULL,0,'','','','','','',0,'','','','','','1206ed96-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-03-06 12:41:12','attributes','all',0),(88,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Punjab Package','Jazz - Punjab Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','120fcedb-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cu','2020-11-03 14:59:25','attributes','all',0),(211,1,0,NULL,'',0,0,0,16,'','','product','','Infinix','Hot 9','Hot 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','b6f0b4fa-8741-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-03-17 16:57:06','attributes','all',0),(209,1,0,NULL,'NA99821',1,0,0,25,'','','product','','Orange','Nola play','Nola play','Orange Nola play (New chipset)','Orange Nola play (New chipset)','Orange Nola play (New chipset)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','311b896e-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-03-17 16:10:42','attributes','all',0),(210,1,0,NULL,'NA99680',1,0,0,63,'','','product','','Tecno','Spark 6 Go','Spark Go_POM','Spark Go_POM','Spark Go_POM','Spark Go_POM','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','3123b12c-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-03-17 16:10:32','attributes','all',0),(212,7,0,NULL,'NA99662',1,0,0,999,'','','product','','Samsung','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-08-18 13:43:03',0,NULL,0,'','','','','','',0,'','','','','','f418e8ad-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:00','attributes','all',0),(213,7,0,NULL,'NA53703',1,0,0,999,'','','product','','Samsung','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-08-18 13:43:04',0,NULL,0,'','','','','','',0,'','','','','','f41f9d0c-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:30','attributes','all',0),(215,15,0,NULL,'',0,1,1,2,'','','product','','OPPO','F19 Pro','F19 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','541df8a9-bf85-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-05-28 07:22:41','attributes','all',0),(254,7,5,NULL,'NA99062',1,0,0,999,'','','product','','Itel','it2132','it2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-25 16:41:15',59,NULL,0,'','','','','','',0,'','','','','','81a604c1-4e0e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-25 16:41:57','attributes','all',0),(227,1,0,NULL,'NA99954',1,0,0,24,'','','product','','Orange','Nola fun','Nola fun','Nola fun (itel A1)','Nola fun (itel A1)','Nola fun (itel A1)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','98d508bd-ce9d-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-06-16 12:23:06','attributes','all',0),(230,1,0,NULL,'',0,0,0,68,'','','product','','Xiaomi','Redmi Note 9','Redmi Note 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','1a246a1c-f38a-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-08-02 12:08:02','attributes','all',0),(228,1,0,NULL,'',0,0,0,66,'','','product','','Xiaomi','Mi Note 10 lite','Mi Note 10 lite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','02f4b33a-f372-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-08-02 09:14:57','attributes','all',0),(229,1,0,NULL,'',0,0,0,67,'','','product','','Xiaomi','Redmi 9','Redmi 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','a06253f7-f379-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-08-02 10:09:46','attributes','all',0),(219,32,0,NULL,'',0,1,0,4,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:10:09',74,NULL,0,'','','','','','',0,'','','','','','e15bf54e-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-09-10 10:01:38','attributes','all',0),(220,32,0,NULL,'',0,1,0,3,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:30:51',74,NULL,0,'','','','','','',0,'','','','','','e1629d6f-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-09-10 10:01:14','attributes','all',0),(221,32,0,NULL,'',0,1,0,2,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:28:38',74,NULL,0,'','','','','','',0,'','','','','','e16a7bc4-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-09-10 10:00:08','attributes','all',0),(222,32,0,NULL,'',0,1,0,1,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:10:09',74,NULL,0,'','','','','','',0,'','','','','','e170fcae-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',21,'','cu','2021-09-10 10:01:25','attributes','all',0),(127,1,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:39:58',56,NULL,0,'','','','','','',0,'','','','','','e2074089-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:23','attributes','all',0),(235,1,0,NULL,'NA99808',1,0,0,37,'','','product','','Samsung','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','e2d6f79e-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:27:05','attributes','all',0),(234,1,0,NULL,'NA99373',1,0,0,40,'','','product','','Samsung','Galaxy A21','Galaxy A21','MEA only - A21','MEA only - A21','MEA only - A21','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','e2efb596-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:26:58','attributes','all',0),(232,1,0,NULL,'',0,0,0,59,'','','product','','Tecno','Pop 4 Pro','Pop 4 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e38ca015-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:10','attributes','all',0),(233,1,0,NULL,'',0,0,0,62,'','','product','','Tecno','Spark 6 Air','Spark 6 Air','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e3a4d80b-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:16','attributes','all',0),(236,47,0,NULL,'',0,0,0,0,'','','offer_postpaid','','','Offre Fibre essentiel','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:11:43',59,NULL,0,'','','','','','',0,'','','','','','5b4fa810-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-09-22 13:09:57','attributes','all',0),(237,47,0,NULL,'',0,1,1,0,'','','offer_postpaid','','','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:16:55',59,NULL,0,'','','','','','',0,'','','','','','a1f14aaf-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-09-22 13:11:55','attributes','all',0),(238,1,0,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','b930a803-1caf-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-23 20:50:16','attributes','all',0),(239,1,0,NULL,'NA100887',1,0,0,999,'','','product','','Apple','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','2ba30e56-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0),(240,1,0,NULL,'NA100891',1,0,0,999,'','','product','','Apple','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2babc0bd-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-09-30 12:17:22','attributes','all',0),(241,1,0,NULL,'NA100898',1,0,0,999,'','','product','','Apple','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2bb4778b-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0),(190,26,1,NULL,'',0,1,1,0,'','','product','','','Baseus Power Bank','Baseus Power Bank','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 12:27:56',62,NULL,0,'','','','','','',0,'','','','','','0b5891df-7d23-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-03-05 04:15:16','attributes','all',0),(225,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:27:22',74,NULL,0,'','','','','','',0,'','','','','','757155df-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-11-08 10:28:33','attributes','all',0),(226,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:28:06',74,NULL,0,'','','','','','',0,'','','','','','8fd2b8f8-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',20,'','cu','2021-11-08 10:29:18','attributes','all',0),(224,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:26',74,NULL,0,'','','','','','',0,'','','','','','9ac2d8c3-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cu','2021-11-08 10:29:46','attributes','all',0),(223,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:48',74,NULL,0,'','','','','','',0,'','','','','','b71d802b-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cu','2021-11-08 10:30:12','attributes','all',0),(18,7,3,NULL,'NA68832',1,1,0,3,'','','product','','Apple','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df2763a2-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',48,'mobile','cu','2021-05-04 14:07:43','attributes','all',0),(251,7,3,NULL,'NA99259',1,0,0,999,'','','product','','Apple','iphone 11','iphone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df48e350-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:50:50','attributes','all',0),(250,7,3,NULL,'NA99964',1,0,0,999,'','','product','','Apple','iPhone 12','iPhone 12','iPhone 12','iPhone 12','iPhone 12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df4fbd88-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:13','attributes','all',0),(249,7,3,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df58429d-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:03','attributes','all',0),(168,24,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:47:28',74,NULL,0,'','','','','','',0,'','','','','','90024f0a-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-12-15 13:49:11','attributes','all',0),(135,24,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',92,NULL,0,'','','','','','',0,'','','','','','f0fc7f2c-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-12-15 13:51:12','attributes','all',0),(340,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Premium','Konnecta Postpaid Max Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d66d432-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',24,'','cda','2022-02-21 10:03:23','attributes','all',0),(336,50,17,NULL,'',0,1,0,0,'','','offer_prepaid','','','Konnecta Prepaid Max','Konnecta Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-24 08:02:17',89,NULL,0,'','','','','','',0,'','','','','','709a74cb-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cda','2022-02-21 10:04:12','attributes','all',0),(332,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d6e0827-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-15 16:14:04','attributes','all',0),(334,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d5e6537-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',19,'','cda','2022-02-15 16:15:02','attributes','all',0),(333,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d66919b-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cda','2022-02-15 16:14:31','attributes','all',0),(331,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Basic','Konnecta Basic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','5a7f1988-8e78-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cda','2022-02-15 16:00:33','attributes','all',0),(266,11,0,NULL,'',0,0,0,0,'','','product','','Orange','Flybox','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2021-12-30 10:00:30',89,NULL,0,'','','','','','',0,'','','','','','52192130-6957-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-12-30 10:01:32','attributes','all',0),(78,14,0,NULL,'NA77252',1,0,0,999,'','','product','','Alcatel','1066G','1066G','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',74,NULL,0,'','','','','','',0,'','','','','','3b9b75bb-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 08:26:14','attributes','all',0),(75,14,0,NULL,'NA76751',1,0,0,999,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',74,NULL,0,'','','','','','',0,'','','','','','aa9c9224-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 08:30:03','attributes','all',0),(79,14,39,NULL,'NA99715',1,0,0,999,'','','product','','Alcatel','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','04a677c7-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 08:32:45','attributes','all',0),(80,14,39,NULL,'NA99195',1,0,0,999,'','','product','','Alcatel','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','6f0fac0b-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 08:35:40','attributes','all',0),(163,24,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','1595ce71-7393-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 10:33:43','attributes','all',0),(161,24,0,NULL,'NA79511',1,1,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-09-19 13:26:23',59,NULL,0,'','','','','','',0,'','','','','','f5b85283-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:01','attributes','all',0),(166,24,0,0,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:16',74,NULL,0,'','','','','','',0,'','','','','','f5c20176-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:48','attributes','all',0),(167,24,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:45:25',74,NULL,0,'','','','','','',0,'','','','','','f5cb5e43-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:39:43','attributes','all',0),(139,24,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-24 09:49:29',74,NULL,0,'','','','','','',0,'','','','','','f5de9a22-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:05','attributes','all',0),(140,24,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5e7f0f3-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:12','attributes','all',0),(169,24,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f0e21a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:12','attributes','all',0),(170,24,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f9bee5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:17','attributes','all',0),(146,24,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f602e11c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:03','attributes','all',0),(147,24,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f60c0b40-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:11','attributes','all',0),(159,24,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f615364f-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:14','attributes','all',0),(171,24,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6277b5b-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:12','attributes','all',0),(172,24,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6306227-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0),(173,24,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f63914d9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:55','attributes','all',0),(160,24,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f641bfba-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:42','attributes','all',0),(181,24,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f64a3f6c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:11','attributes','all',0),(174,24,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f652c6c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:23','attributes','all',0),(138,24,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f65b382a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:43','attributes','all',0),(182,24,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f663eb07-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:18','attributes','all',0),(158,24,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f66c4ebf-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:44','attributes','all',0),(156,24,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f674cd49-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:52','attributes','all',0),(157,24,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f67d3dfc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:21','attributes','all',0),(137,24,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f685b91c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:38:52','attributes','all',0),(136,24,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f68e4766-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:14','attributes','all',0),(184,24,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f696be74-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0),(186,24,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f69f4752-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0),(141,24,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6a7e231-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:51','attributes','all',0),(142,24,0,0,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6b0aa50-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:38:48','attributes','all',0),(151,24,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6b96303-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:38:56','attributes','all',0),(183,24,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6c1fd6e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:41','attributes','all',0),(164,24,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6cab4b9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0),(175,24,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6d37761-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:50','attributes','all',0),(176,24,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6dc4270-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:26','attributes','all',0),(185,24,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6e52400-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:51','attributes','all',0),(152,24,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6edcc26-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:44','attributes','all',0),(187,24,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6f687c6-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:27','attributes','all',0),(148,24,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6ff3783-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:56','attributes','all',0),(143,24,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f707d4a7-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:58','attributes','all',0),(144,24,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7108112-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:26','attributes','all',0),(165,24,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f71935e4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:59','attributes','all',0),(162,24,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7223409-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-01-12 13:40:08','attributes','all',0),(177,24,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f733ed2e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:00','attributes','all',0),(178,24,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f73ca2db-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:02','attributes','all',0),(155,24,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f74568c0-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:34','attributes','all',0),(145,24,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f74e554a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0),(134,24,0,NULL,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-29 13:34:58',74,NULL,0,'','','','','','',0,'','','','','','f75745a5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-12 13:38:46','attributes','all',0),(188,24,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7606092-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-01-12 13:38:48','attributes','all',0),(179,24,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7693297-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-01-12 13:39:24','attributes','all',0),(180,24,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f771e0c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:57','attributes','all',0),(153,24,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f77a8f29-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0),(154,24,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78351cc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:20','attributes','all',0),(189,24,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78c0a04-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:43','attributes','all',0),(150,24,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7950589-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:39','attributes','all',0),(149,24,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f79de0ee-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:49','attributes','all',0),(243,1,10,NULL,'NA99955',1,0,0,999,'','','product','','Orange','Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-01-20 12:55:57',59,NULL,0,'','','','','','',0,'','','','','','4f939f5b-79f0-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-20 12:56:43','attributes','all',0),(200,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-28 06:16:03',85,NULL,0,'','','','','','',0,'','','','','','1242e8e0-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-03-06 12:41:25','attributes','all',0),(339,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Prestige','Konnecta Postpaid Max Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d6eecab-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-21 10:04:12','attributes','all',0),(338,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Standard','Konnecta Postpaid Max Standard','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d76e45b-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cda','2022-02-21 10:04:50','attributes','all',0),(335,1,0,NULL,'NA101009',1,0,0,999,'','','product','','Samsung','Galaxy S22','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:41:05',84,NULL,0,'','','','','','',0,'','','','','','d63fd194-9319-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',21,'mobile','cu','2022-02-21 13:27:38','attributes','all',0),(341,1,8,NULL,'NA101276',1,0,0,999,'','','product','','Samsung','Galaxy A13','Galaxy A13','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:33:31',84,NULL,0,'','','','','','',0,'','','','','','19c3dcbe-93ec-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',25,'mobile','cu','2022-02-22 14:31:33','attributes','all',0),(337,50,18,NULL,'',0,1,0,0,'','','offer_prepaid','','','Unlimited Prepaid Max','Unlimited Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:39',89,NULL,0,'','','','','','',0,'','','','','','70a25627-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-02-21 10:03:57','attributes','all',0),(342,1,8,NULL,'NA100838',1,0,0,999,'','','product','','Samsung','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:14:21',84,NULL,0,'','','','','','',0,'','','','','','26c45a7a-9552-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',17,'mobile','cu','2022-02-24 09:15:40','attributes','all',0),(349,7,21,NULL,'',0,1,0,0,'','','product','','Orange','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-05-05 08:09:15',59,NULL,0,'','','','','','',0,'','','','','','15f5729a-c566-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-04-26 13:38:57','attributes','all',0),(294,51,0,0,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a42f9a42-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:20:53','attributes','all',0),(299,51,0,0,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a43b2608-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:42','attributes','all',0),(300,51,0,0,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a4464695-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:35','attributes','all',0),(301,51,0,0,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45175ce-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:47','attributes','all',0),(272,51,0,0,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45cde96-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:23','attributes','all',0),(273,51,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a46824aa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0),(302,51,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4730519-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0),(303,51,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a47df9fa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:29','attributes','all',0),(279,51,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4892058-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:07','attributes','all',0),(280,51,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4949a9b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:17','attributes','all',0),(292,51,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a49ee3ba-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:31','attributes','all',0),(268,51,0,0,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4a97c46-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:57','attributes','all',0),(304,51,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4b3fb76-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0),(305,51,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4bdf2f5-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0),(306,51,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4c7f700-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:22','attributes','all',0),(293,51,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4d20694-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0),(314,51,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4dbee29-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0),(307,51,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4e5c9be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:35','attributes','all',0),(271,51,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4f03c16-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:03','attributes','all',0),(315,51,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4fa3ceb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:25','attributes','all',0),(291,51,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5043653-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:16','attributes','all',0),(289,51,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a50e1dc0-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:55','attributes','all',0),(290,51,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5186534-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0),(270,51,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5225ef8-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:41','attributes','all',0),(269,51,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a52c65e7-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0),(317,51,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5367510-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:45','attributes','all',0),(319,51,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5405250-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0),(274,51,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a54a46bf-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:57','attributes','all',0),(275,51,0,0,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a55c44a9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0),(284,51,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a566ee8a-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:46','attributes','all',0),(316,51,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a57172f3-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:43','attributes','all',0),(297,51,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a57c4b4f-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:46','attributes','all',0),(308,51,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a58703dd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:26','attributes','all',0),(309,51,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59176ad-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:29','attributes','all',0),(318,51,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59bce97-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:52','attributes','all',0),(285,51,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5a5de39-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:47','attributes','all',0),(320,51,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5afeab1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:42','attributes','all',0),(281,51,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5b9f0be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:06','attributes','all',0),(276,51,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5c419f1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:26','attributes','all',0),(277,51,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ce4b7b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:05','attributes','all',0),(298,51,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5d8626e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:22','attributes','all',0),(295,51,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5e347fb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-03 10:21:54','attributes','all',0),(296,51,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ed9c24-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:24','attributes','all',0),(310,51,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5f81fcd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:38','attributes','all',0),(311,51,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a602846e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:51','attributes','all',0),(288,51,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a60cdc45-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0),(278,51,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a61727ea-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:52','attributes','all',0),(267,51,0,0,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6215be9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:22:05','attributes','all',0),(321,51,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a62bd425-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-05-03 10:20:47','attributes','all',0),(312,51,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a63615d1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-05-03 10:20:45','attributes','all',0),(313,51,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64006b1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:37','attributes','all',0),(286,51,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64a3e6b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:59','attributes','all',0),(287,51,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6543d18-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:41','attributes','all',0),(322,51,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a65e5e92-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:30','attributes','all',0),(283,51,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a668a392-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0),(282,51,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a672ac3d-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:05','attributes','all',0),(255,49,0,NULL,'NA68012',1,0,0,1,'','','product','','Samsung','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad543c1d-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:35:44','attributes','all',0),(256,49,0,NULL,'NA57406',1,0,0,2,'','','product','','Samsung','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad5e2e59-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:19','attributes','all',0),(257,49,0,NULL,'NA69997',1,0,0,3,'','','product','','Samsung','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad67cea7-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:44','attributes','all',0),(258,49,0,NULL,'NA63614',1,0,0,4,'','','product','','Samsung','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad719209-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-05-03 15:36:11','attributes','all',0),(352,14,0,NULL,'NA99508',1,0,0,999,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-12 07:56:47',59,NULL,0,'','','','','','',0,'','','','','','4b3a7d19-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-04 15:03:50','attributes','all',0),(351,14,39,NULL,'NA100175',1,0,0,999,'','','product','','Alcatel','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:02',59,NULL,0,'','','','','','',0,'','','','','','4b44cd56-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-04 15:04:24','attributes','all',0),(350,14,39,NULL,'',0,0,0,0,'','','product','','Pack','Alcatel Neo + Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','d3d8d6f9-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-04 15:08:26','attributes','all',0),(353,7,0,NULL,'',0,1,0,0,'','','product','','Pack','Alcatel Neo 1 + Orange Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-05 08:07:00',59,NULL,0,'','','','','','',0,'','','','','','f86c0e85-cc49-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-05 08:04:55','attributes','all',0),(356,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-07-28 13:18:45',92,NULL,0,'','','','','','',0,'','','','','','cb2209e3-0288-11ed-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-13 08:51:08','attributes','all',0),(357,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:19:17',92,NULL,0,'','','','','','',0,'','','','','','bb196cf0-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-07-25 12:39:59','attributes','all',0),(358,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:16:04',92,NULL,0,'','','','','','',0,'','','','','','db9f50da-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-07-25 12:40:32','attributes','all',0),(360,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-25 12:40:53',92,NULL,0,'','','','','','',0,'','','','','','05a12f65-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-25 12:42:05','attributes','all',0),(359,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-25 12:40:53',92,NULL,0,'','','','','','',0,'','','','','','05aaac7e-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-25 12:42:25','attributes','all',0),(362,63,29,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:23:18',92,NULL,0,'','','','','','',0,'','','','','','05b3caaa-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-07-25 12:41:52','attributes','all',0),(361,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-25 12:40:53',92,NULL,0,'','','','','','',0,'','','','','','05bcdf80-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-25 12:41:19','attributes','all',0),(364,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-03 20:23:12',92,NULL,0,'','','','','','',0,'','','','','','71ba0605-1331-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-08-03 13:38:03','attributes','all',0),(71,14,0,NULL,'NA97011',1,0,0,999,'','','product','','Samsung','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c2f0301-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:06','attributes','all',0),(83,14,0,NULL,'NA73732',1,0,0,999,'','','product','','Itel','it2130','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c397d4e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:56','attributes','all',0),(70,14,0,NULL,'NA97013',1,0,0,999,'','','product','','Samsung','Galaxy S10+  (128GB)','Galaxy S10+  (128GB)','Galaxy S10+  (128GB)','Galaxy S10+  (128GB)','Galaxy S10+  (128GB)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c43c482-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:49','attributes','all',0),(82,14,0,NULL,'NA85691',1,0,0,999,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c4de382-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:12','attributes','all',0),(69,14,0,NULL,'NA99526',1,0,0,999,'','','product','','Samsung','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c5810d9-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:16','attributes','all',0),(81,14,0,NULL,'NA76351',1,0,0,999,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c628373-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:46','attributes','all',0),(68,14,0,NULL,'NA99525',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c6cbb12-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:49','attributes','all',0),(67,14,0,NULL,'NA69131',1,0,0,999,'','','product','','Tecno','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c81f304-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-08-12 07:58:02','attributes','all',0),(77,14,0,NULL,'NA70090',1,0,0,999,'','','product','','Huawei','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c8c14a7-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0),(66,14,0,NULL,'NA86072',1,0,0,999,'','','product','','Apple','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c988c18-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:56','attributes','all',0),(76,14,0,NULL,'NA85531',1,0,0,999,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ca22689-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:31','attributes','all',0),(65,14,0,NULL,'NA86031',1,0,0,999,'','','product','','Apple','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cabf40e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:30','attributes','all',0),(74,14,0,NULL,'NA99367',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cc12cd0-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:14','attributes','all',0),(73,14,0,NULL,'NA99129',1,0,0,999,'','','product','','Samsung','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ccec63d-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0),(72,14,0,NULL,'NA99225',1,0,0,999,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cd7a638-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:45','attributes','all',0),(371,65,0,0,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:04',74,NULL,0,'','','','','','',0,'','','','','','c8df59a9-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-08-29 08:23:07','attributes','all',0),(366,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d31b5354-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-08-29 08:23:36','attributes','all',0),(365,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d324da98-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-08-29 08:24:19','attributes','all',0),(369,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da820a50-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:30','attributes','all',0),(368,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da8bed01-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:24:04','attributes','all',0),(367,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:26',74,NULL,0,'','','','','','',0,'','','','','','da954ca2-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:50','attributes','all',0),(370,65,42,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:38',74,NULL,0,'','','','','','',0,'','','','','','e1bf8e55-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-08-29 08:24:55','attributes','all',0),(355,59,25,NULL,'',0,1,1,0,'','','product','','Xiaomi','Pad 5','Pad 5','AR','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 05:59:46',62,NULL,0,'','','','','','',0,'','','','','','46b0f37b-2e72-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-09-07 06:00:49','attributes','all',0),(372,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Card2wallet','Card2wallet','Card2wallet','Card2wallet','Card2wallet','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-11-21 20:39:02',59,NULL,0,'','','','','','',0,'','','','','','f67b81a7-69db-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-11-21 20:40:23','attributes','all',0);
/*!40000 ALTER TABLE `products_02122022` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_definition`
--

DROP TABLE IF EXISTS `products_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_definition` (
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
-- Dumping data for table `products_definition`
--

LOCK TABLES `products_definition` WRITE;
/*!40000 ALTER TABLE `products_definition` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_definition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_folders`
--

DROP TABLE IF EXISTS `products_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_folders` (
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
  UNIQUE KEY `uk_products_folders` (`site_id`,`catalog_id`,`name`,`parent_folder_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_folders`
--

LOCK TABLES `products_folders` WRITE;
/*!40000 ALTER TABLE `products_folders` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_folders` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `products_v49`
--

DROP TABLE IF EXISTS `products_v49`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_v49` (
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
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max consecutive no of slots per service booking',
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
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
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
  `familie_id` int(11) DEFAULT NULL,
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
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `product_definition_id` int(11) DEFAULT NULL,
  `product_version` varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT 'V1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_v49`
--

LOCK TABLES `products_v49` WRITE;
/*!40000 ALTER TABLE `products_v49` DISABLE KEYS */;
INSERT INTO `products_v49` VALUES (1,3,0,NULL,'',0,0,0,2,'','','product','','Apple','iPhone 7','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e51ec17f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',17,'','cu',NULL,'attributes','all',0,NULL,'V1'),(2,3,0,NULL,'',0,0,0,7,'','','product','','Samsung','Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e52258e3-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(3,3,0,NULL,'',0,0,0,8,'','','product','','Samsung','Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e524eb7d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(4,3,0,NULL,'',0,0,0,11,'','','product','','Tecno','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e5275f7a-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(5,3,0,NULL,'',0,0,0,3,'','','product','','Apple','iPhone X','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e529a69d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(6,3,0,NULL,'',0,0,0,1,'','','product','','Alcatel','1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52bfeb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(7,3,0,NULL,'',0,0,0,5,'','','product','','Samsung','Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52e4cb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(8,3,0,NULL,'',0,0,0,6,'','','product','','Samsung','Galaxy A8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e530bbef-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(9,3,0,NULL,'',0,0,0,4,'','','product','','Apple','iPhone XS Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5330b16-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(10,3,0,NULL,'',0,0,0,9,'','','product','','Samsung','S10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5358bed-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(11,3,0,NULL,'',0,0,0,12,'','','product','','Tecno','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e537c161-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(12,3,0,NULL,'',0,0,0,10,'','','product','','Samsung','S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e539c73f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(19,7,0,NULL,'NA71311',1,1,0,8,'','','product','','Samsung','Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:43',82,NULL,0,'','','','','','',0,'','','','','','37e46c49-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',13,'mobile','cu','2021-05-04 14:07:50','attributes','all',0,NULL,'V1'),(30,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','b9fec1af-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-05-18 14:37:20','attributes','all',0,NULL,'V1'),(32,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba0271d1-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cu','2021-05-18 14:37:41','attributes','all',0,NULL,'V1'),(29,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba050e3d-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-05-18 14:38:44','attributes','all',0,NULL,'V1'),(31,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-01-03 15:23:01',59,NULL,0,'','','','','','',0,'','','','','','ba079127-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cu','2021-05-18 14:38:33','attributes','all',0,NULL,'V1'),(34,7,0,NULL,'NA73732',1,1,0,6,'','','product','','Itel','it2130 new','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-05-11 11:59:20',60,NULL,0,'','','','','','',0,'','','','','','3819aaab-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-05-04 14:08:09','attributes','all',0,NULL,'V1'),(231,1,0,NULL,'',0,0,0,22,'','','product','','','Orange Halona','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:39:59',84,NULL,0,'','','','','','',0,'','','','','','bdaeccfe-1184-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-09 15:44:50','attributes','all',0,NULL,'V1'),(26,7,0,0,'NA70452',1,0,0,11,'','','product','','Tecno','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:45',56,NULL,0,'','','','','','',0,'','','','','','3814dd16-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:52','attributes','all',0,NULL,'V1'),(25,7,3,NULL,'NA86072',1,1,0,5,'','','product','','Apple','iPhone XS Max','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','380d4afa-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-05-04 14:06:55','attributes','all',0,NULL,'V1'),(23,7,0,NULL,'NA79511',1,1,0,2,'','','product','','Alcatel','Neo 1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-16 22:04:14',57,NULL,0,'','','','','','',0,'','','','','','3800b9bc-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',12,'mobile','cu','2021-05-04 14:08:04','attributes','all',0,NULL,'V1'),(22,7,0,NULL,'NA76351',1,1,0,10,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:44',82,NULL,0,'','','','','','',0,'','','','','','37f9f305-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-05-04 14:07:50','attributes','all',0,NULL,'V1'),(20,7,0,NULL,'NA78851',1,1,0,9,'','','product','','Samsung','Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:44',82,NULL,0,'','','','','','',0,'','','','','','37eae657-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',10,'mobile','cu','2021-05-04 14:07:38','attributes','all',0,NULL,'V1'),(21,7,3,NULL,'NA77753',1,1,0,4,'','','product','','Apple','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-12-14 23:01:44',60,NULL,0,'','','','','','',0,'','','','','','37f16683-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',10,'mobile','cu','2021-05-04 14:06:45','attributes','all',0,NULL,'V1'),(17,6,0,NULL,'',0,0,0,0,'','','product','','Samsung','Galaxy S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-08-05 14:01:40',1,NULL,0,'','','','','','',0,'','','','','','280fea73-d724-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(92,7,0,0,'NA80112',1,0,0,12,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:46',56,NULL,0,'','','','','','',0,'','','','','','5d452512-53f8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:25','attributes','all',0,NULL,'V1'),(117,1,0,NULL,'',0,0,0,56,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','0bc7ddd2-4b5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2020-12-31 11:20:05','attributes','all',0,NULL,'V1'),(126,1,0,NULL,'NA99371',1,0,0,54,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','79f5c526-617a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-01-28 15:07:16','attributes','all',0,NULL,'V1'),(133,21,0,NULL,'',0,0,0,0,'','','product','','Test','test','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-02-24 09:42:37',0,NULL,0,'','','','','','',0,'','','','','','a0f996ea-7684-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-02-24 09:43:10','attributes','all',0,NULL,'V1'),(218,7,0,NULL,'',0,1,1,0,'','','product','','OnePlus','Nord','Nord','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2023-04-17 08:42:49',62,NULL,0,'','','','','','',0,'','','','','','8551df06-bf84-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-05-28 07:16:30','attributes','all',0,NULL,'V1'),(41,13,0,NULL,'',0,0,0,0,'','','product','','Testift','testift','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-12 09:29:21',0,NULL,0,'','','','','','',0,'','','','','','68d9d606-0c6d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(42,1,0,NULL,'NA85811',1,0,0,28,'','','product','','Orange','Sanza','Orange Sanza','Orange Sanza','Orange Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','908f5515-0d5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-11-03 14:53:11','attributes','all',0,NULL,'V1'),(84,15,0,NULL,'NA99191',1,1,1,1,'','','product','','OPPO','Reno 2','Reno 2','Reno 2','Reno 2','Reno 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','5403e5ff-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',24,'mobile','cu','2022-09-07 06:01:45','attributes','all',0,NULL,'V1'),(86,15,0,NULL,'NA97251',1,1,1,4,'','','product','','Samsung','Galaxy Note 9','Galaxy Note 9','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','540fef9a-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-05 04:19:07','attributes','all',0,NULL,'V1'),(85,15,0,NULL,'NA99292',1,1,1,5,'','','product','','OPPO','A91','A91','A91','A91','A91','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','540ace4f-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',18,'mobile','cu','2021-03-05 04:18:18','attributes','all',0,NULL,'V1'),(43,1,0,NULL,'NA96411',1,0,0,20,'','','product','','Itel','MC20','MC20','MC20','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','41806800-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:34:03','attributes','all',0,NULL,'V1'),(44,1,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ebc041dd-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:51:45','attributes','all',0,NULL,'V1'),(45,1,0,NULL,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','61c0bfa9-0fc0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-30 14:51:54','attributes','all',0,NULL,'V1'),(48,1,0,NULL,'NA99307',1,0,0,45,'','','product','','Samsung','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','43c4e363-0fc2-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 09:54:04','attributes','all',0,NULL,'V1'),(49,1,0,NULL,'NA99308',1,0,0,46,'','','product','','Samsung','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','6ca3550d-0fc3-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:55:03','attributes','all',0,NULL,'V1'),(50,1,0,NULL,'NA99526',1,0,0,53,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','62801c47-0fc4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 11:11:57','attributes','all',0,NULL,'V1'),(51,1,0,NULL,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iPhone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','192596fc-0fc6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 15:51:00','attributes','all',0,NULL,'V1'),(91,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Monthly Mega Plus','Jazz - Monthly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12211677-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:37','attributes','all',0,NULL,'V1'),(90,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','122acaee-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:31','attributes','all',0,NULL,'V1'),(199,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','1232e5e4-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:42:18','attributes','all',0,NULL,'V1'),(33,7,0,NULL,'NA80551',1,1,1,1,'','','product','','Alcatel','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-17 12:29:40',59,NULL,0,'','','','','','',0,'','','','','','7d73b01d-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',11,'mobile','cu','2021-05-04 14:07:27','attributes','all',0,NULL,'V1'),(35,11,0,NULL,'',0,0,0,0,'','','product','','','Homebox haut-débit 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-11-03 14:59:25',1,NULL,0,'','','','','','',0,'','','','','','2a10bb19-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',22,'','cu','2020-11-03 15:01:01','attributes','all',0,NULL,'V1'),(37,11,0,0,'',0,0,0,0,'','','product','','','Airbox 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-02-17 15:36:54',56,NULL,0,'','','','','','',0,'','','','','','2a16f2b0-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cu','2022-02-17 15:36:55','attributes','all',0,NULL,'V1'),(97,1,0,NULL,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','6e3aef88-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-11-26 10:59:49','attributes','logged',0,NULL,'V1'),(58,1,0,NULL,'NA76351',1,0,0,58,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','e6198413-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-26 11:03:16','attributes','all',0,NULL,'V1'),(59,1,0,NULL,'NA80112',1,0,0,60,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','31c2b493-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:04:46','attributes','all',0,NULL,'V1'),(98,1,0,NULL,'',0,0,0,48,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','c5bfed7f-2fd8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2020-11-26 11:16:57','attributes','all',0,NULL,'V1'),(99,1,0,NULL,'NA99975',1,0,0,49,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','5fe0bbf7-3328-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 16:23:58','attributes','all',0,NULL,'V1'),(102,1,0,NULL,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14a8df75-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:30','attributes','all',0,NULL,'V1'),(103,1,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3','U3 4G','U3 4G','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14af9103-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:55','attributes','all',0,NULL,'V1'),(105,1,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s','iPhone 6s 16GB','iPhone 6s 16GB','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','80638f62-4aae-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 14:51:44','attributes','all',0,NULL,'V1'),(106,1,0,NULL,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','iPhone XS','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','5036f54c-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:12:49','attributes','all',0,NULL,'V1'),(107,1,0,NULL,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max','iPhone XS Max 512GB','iPhone XS Max 512GB','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','f02d2074-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:16:22','attributes','all',0,NULL,'V1'),(52,1,0,NULL,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','33cb4a44-4ab4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:33:00','attributes','all',0,NULL,'V1'),(108,1,0,NULL,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','0794ea79-4ab5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:38:28','attributes','all',0,NULL,'V1'),(109,1,0,NULL,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ae75c665-4ab6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:51:19','attributes','all',0,NULL,'V1'),(110,1,0,NULL,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','4c394816-4ab7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:55:40','attributes','all',0,NULL,'V1'),(96,1,0,NULL,'NA73732',1,0,0,17,'','','product','','Itel','IT2130','IT2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','2281091f-4ab8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:01:09','attributes','all',0,NULL,'V1'),(111,1,0,NULL,'NA85691',1,0,0,19,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','7973f18c-4abc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:31:48','attributes','all',0,NULL,'V1'),(62,1,0,NULL,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','Mahpee','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f84fe49c-4abd-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:43:37','attributes','all',0,NULL,'V1'),(63,1,0,NULL,'NA76811',1,0,0,26,'','','product','','Orange','Rise 53','Rise 53','Rise 53','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','37536730-4ac0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:58:55','attributes','all',0,NULL,'V1'),(112,1,0,NULL,'NA97811',1,0,0,27,'','','product','','Orange','Rise 55','Rise 55','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9a4d5326-4ac6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 17:45:19','attributes','all',0,NULL,'V1'),(113,1,0,NULL,'NA99129',1,0,0,38,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3eff26ac-4b4a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:26:31','attributes','all',0,NULL,'V1'),(114,1,0,NULL,'NA99225',1,0,0,39,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','0f5485af-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:40:35','attributes','all',0,NULL,'V1'),(57,1,0,NULL,'NA99197',1,0,0,42,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','ece291b1-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:46:46','attributes','all',0,NULL,'V1'),(53,1,0,NULL,'NA99212',1,0,0,44,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','a963e4f4-4b4d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:51:32','attributes','all',0,NULL,'V1'),(46,1,0,NULL,'NA99730',1,0,0,32,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','0e3e7f7d-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:53:56','attributes','all',0,NULL,'V1'),(47,1,0,NULL,'NA99224',1,0,0,33,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','98b16401-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:54:47','attributes','all',0,NULL,'V1'),(56,1,0,NULL,'NA99128',1,0,0,34,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','c82806ff-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:09:08','attributes','all',0,NULL,'V1'),(100,1,0,NULL,'NA99374',1,0,0,36,'','','product','','Samsung','Galaxy A11','Galaxy A11','MEA only - A11','MEA only - A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','11495a56-332a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2020-11-30 16:35:50','attributes','all',0,NULL,'V1'),(101,1,0,NULL,'NA99378',1,0,0,47,'','','product','','Samsung','Galaxy M11','MEA only - M11','MEA only - M11','MEA only - M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','4ef8da0c-332d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 17:00:05','attributes','all',0,NULL,'V1'),(115,1,0,NULL,'NA97291',1,0,0,50,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3f8a4505-4b56-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 10:53:10','attributes','all',0,NULL,'V1'),(116,1,0,NULL,'NA97293',1,0,0,51,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','266fbe41-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:07:18','attributes','all',0,NULL,'V1'),(60,1,0,NULL,'NA99367',1,0,0,52,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','bbf20cc9-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:10:20','attributes','all',0,NULL,'V1'),(118,1,0,NULL,'NA96431',1,0,0,57,'','','product','','Tecno','N11','N11','N11','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','19e2818a-4b6a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 13:14:25','attributes','all',0,NULL,'V1'),(119,1,0,NULL,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','bb045aa5-4b71-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 14:09:26','attributes','all',0,NULL,'V1'),(120,1,0,NULL,'NA99062',1,0,0,18,'','','product','','Itel','IT2132','IT2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','8907ffc6-4b73-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-31 14:22:06','attributes','all',0,NULL,'V1'),(121,1,0,NULL,'NA84092',1,0,0,21,'','','product','','Mobiwire','AX2408','AX2408','AX2408','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f7dae2d4-4b74-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 14:32:17','attributes','all',0,NULL,'V1'),(122,1,0,NULL,'NA99960',1,0,0,35,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','100e8834-4b79-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-12-31 15:03:01','attributes','all',0,NULL,'V1'),(123,1,0,NULL,'NA99508',1,0,0,30,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','ec3349e3-4b7c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-31 15:30:25','attributes','all',0,NULL,'V1'),(124,1,0,NULL,'NA99662',1,0,0,41,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','d36cae36-4b81-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:04:51','attributes','all',0,NULL,'V1'),(55,1,0,NULL,'NA71191',1,0,0,64,'','','product','','Wiko','Sunny','SUNNY','SUNNY','SUNNY','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','4312afeb-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:07:32','attributes','all',0,NULL,'V1'),(54,1,0,NULL,'NA79491',1,0,0,65,'','','product','','Wiko','Tommy3','TOMMY3','TOMMY3','TOMMY3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','bf7ea052-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:12:16','attributes','all',0,NULL,'V1'),(132,1,0,NULL,'NA99294',1,0,0,61,'','','product','','Tecno','R7+','R7+','R7+','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','5273cd2f-61af-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-01-28 21:26:15','attributes','all',0,NULL,'V1'),(128,1,0,NULL,'NA99210',1,0,0,29,'','','product','','Orange','Sanza 2','Sanza 2','Sanza 2','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9264ecbd-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:29','attributes','all',0,NULL,'V1'),(129,1,0,NULL,'NA99064',1,0,0,31,'','','product','','Orange','Sanza XL','Sanza XL','Sanza XL','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','92717ac5-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:19','attributes','all',0,NULL,'V1'),(130,1,0,NULL,'NA99736',1,0,0,43,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','92b46e91-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:20','attributes','all',0,NULL,'V1'),(131,1,0,NULL,'',0,0,0,55,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',0,NULL,0,'','','','','','',0,'','','','','','93067e8f-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-01-28 18:28:25','attributes','all',0,NULL,'V1'),(192,15,0,NULL,'NA74171',1,1,1,9,'','','product','','Blackberry Mobile','KEYone','KEYone','KEYone','KEYone','KEYone','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',85,NULL,0,'','','','','','',0,'','','','','','7adc0aeb-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-03-06 12:36:56','attributes','all',0,NULL,'V1'),(193,15,0,NULL,'NA99266',1,1,1,8,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7ae4c517-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-06 12:35:51','attributes','all',0,NULL,'V1'),(194,15,0,NULL,'NA65430',1,1,1,7,'','','product','','Apple','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7aebe125-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'Tablet','cu','2021-03-06 12:36:22','attributes','all',0,NULL,'V1'),(195,15,0,NULL,'NA83732',1,1,1,11,'','','product','','Samsung','Galaxy S9+','Galaxy S9+','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af2d920-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-03-06 12:37:03','attributes','all',0,NULL,'V1'),(214,15,0,NULL,'NA99971',1,0,0,6,'','','product','','Apple','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',0,NULL,0,'','','','','','',0,'','','','','','b180c68e-da66-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-07-01 12:21:37','attributes','all',0,NULL,'V1'),(196,15,0,NULL,'NA55627',1,1,1,10,'','','product','','Samsung','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af9c988-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'Tablet','cu','2021-03-06 12:35:50','attributes','all',0,NULL,'V1'),(191,15,0,NULL,'',0,1,1,3,'','','product','','','One Plus','One Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','7b00e72f-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-03-06 12:37:24','attributes','all',0,NULL,'V1'),(89,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','123ad363-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',8,'','cu','2020-11-03 14:59:20','attributes','all',0,NULL,'V1'),(198,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12185468-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:41:24','attributes','all',0,NULL,'V1'),(197,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 06:49:31',62,NULL,0,'','','','','','',0,'','','','','','1206ed96-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-03-06 12:41:12','attributes','all',0,NULL,'V1'),(88,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Punjab Package','Jazz - Punjab Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','120fcedb-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cu','2020-11-03 14:59:25','attributes','all',0,NULL,'V1'),(211,1,0,NULL,'',0,0,0,16,'','','product','','Infinix','Hot 9','Hot 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','b6f0b4fa-8741-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-03-17 16:57:06','attributes','all',0,NULL,'V1'),(209,1,0,NULL,'NA99821',1,0,0,25,'','','product','','Orange','Nola play','Nola play','Orange Nola play (New chipset)','Orange Nola play (New chipset)','Orange Nola play (New chipset)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','311b896e-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-03-17 16:10:42','attributes','all',0,NULL,'V1'),(210,1,0,NULL,'NA99680',1,0,0,63,'','','product','','Tecno','Spark 6 Go','Spark Go_POM','Spark Go_POM','Spark Go_POM','Spark Go_POM','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','3123b12c-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-03-17 16:10:32','attributes','all',0,NULL,'V1'),(212,7,0,NULL,'NA99662',1,0,0,999,'','','product','','Samsung','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:47',0,NULL,0,'','','','','','',0,'','','','','','f418e8ad-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:00','attributes','all',0,NULL,'V1'),(213,7,0,NULL,'NA53703',1,0,0,999,'','','product','','Samsung','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:47',0,NULL,0,'','','','','','',0,'','','','','','f41f9d0c-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:30','attributes','all',0,NULL,'V1'),(215,15,0,NULL,'',0,1,1,2,'','','product','','OPPO','F19 Pro','F19 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','541df8a9-bf85-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-05-28 07:22:41','attributes','all',0,NULL,'V1'),(254,7,5,NULL,'NA99062',1,0,0,999,'','','product','','Itel','it2132','it2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-25 16:41:15',59,NULL,0,'','','','','','',0,'','','','','','81a604c1-4e0e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-25 16:41:57','attributes','all',0,NULL,'V1'),(227,1,0,NULL,'NA99954',1,0,0,24,'','','product','','Orange','Nola fun','Nola fun','Nola fun (itel A1)','Nola fun (itel A1)','Nola fun (itel A1)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','98d508bd-ce9d-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-06-16 12:23:06','attributes','all',0,NULL,'V1'),(230,1,0,NULL,'',0,0,0,68,'','','product','','Xiaomi','Redmi Note 9','Redmi Note 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','1a246a1c-f38a-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-08-02 12:08:02','attributes','all',0,NULL,'V1'),(228,1,0,NULL,'',0,0,0,66,'','','product','','Xiaomi','Mi Note 10 lite','Mi Note 10 lite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','02f4b33a-f372-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-08-02 09:14:57','attributes','all',0,NULL,'V1'),(229,1,0,NULL,'',0,0,0,67,'','','product','','Xiaomi','Redmi 9','Redmi 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','a06253f7-f379-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-08-02 10:09:46','attributes','all',0,NULL,'V1'),(219,32,0,NULL,'',0,1,0,4,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:10:09',74,NULL,0,'','','','','','',0,'','','','','','e15bf54e-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-09-10 10:01:38','attributes','all',0,NULL,'V1'),(220,32,0,NULL,'',0,1,0,3,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:30:51',74,NULL,0,'','','','','','',0,'','','','','','e1629d6f-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-09-10 10:01:14','attributes','all',0,NULL,'V1'),(221,32,0,NULL,'',0,1,0,2,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:28:38',74,NULL,0,'','','','','','',0,'','','','','','e16a7bc4-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-09-10 10:00:08','attributes','all',0,NULL,'V1'),(222,32,0,NULL,'',0,1,0,1,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-21 14:25:53',74,NULL,0,'','','','','','',0,'','','','','','e170fcae-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',21,'','cu','2021-09-10 10:01:25','attributes','all',0,NULL,'V1'),(127,1,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:39:58',56,NULL,0,'','','','','','',0,'','','','','','e2074089-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:23','attributes','all',0,NULL,'V1'),(235,1,0,NULL,'NA99808',1,0,0,37,'','','product','','Samsung','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','e2d6f79e-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:27:05','attributes','all',0,NULL,'V1'),(234,1,0,NULL,'NA99373',1,0,0,40,'','','product','','Samsung','Galaxy A21','Galaxy A21','MEA only - A21','MEA only - A21','MEA only - A21','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','e2efb596-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:26:58','attributes','all',0,NULL,'V1'),(232,1,0,NULL,'',0,0,0,59,'','','product','','Tecno','Pop 4 Pro','Pop 4 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e38ca015-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:10','attributes','all',0,NULL,'V1'),(233,1,0,NULL,'',0,0,0,62,'','','product','','Tecno','Spark 6 Air','Spark 6 Air','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e3a4d80b-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:16','attributes','all',0,NULL,'V1'),(236,47,0,NULL,'',0,0,0,0,'','','offer_postpaid','','','Offre Fibre essentiel','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:11:43',59,NULL,0,'','','','','','',0,'','','','','','5b4fa810-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-09-22 13:09:57','attributes','all',0,NULL,'V1'),(237,47,0,NULL,'',0,1,1,0,'','','offer_postpaid','','','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:16:55',59,NULL,0,'','','','','','',0,'','','','','','a1f14aaf-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-09-22 13:11:55','attributes','all',0,NULL,'V1'),(238,1,0,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','b930a803-1caf-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-23 20:50:16','attributes','all',0,NULL,'V1'),(239,1,0,NULL,'NA100887',1,0,0,999,'','','product','','Apple','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','2ba30e56-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0,NULL,'V1'),(240,1,0,NULL,'NA100891',1,0,0,999,'','','product','','Apple','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2babc0bd-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-09-30 12:17:22','attributes','all',0,NULL,'V1'),(241,1,0,NULL,'NA100898',1,0,0,999,'','','product','','Apple','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2bb4778b-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0,NULL,'V1'),(190,26,1,NULL,'',0,1,1,0,'','','product','','','Baseus Power Bank','Baseus Power Bank','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 12:27:56',62,NULL,0,'','','','','','',0,'','','','','','0b5891df-7d23-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-03-05 04:15:16','attributes','all',0,NULL,'V1'),(225,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:27:22',74,NULL,0,'','','','','','',0,'','','','','','757155df-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-11-08 10:28:33','attributes','all',0,NULL,'V1'),(226,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:28:06',74,NULL,0,'','','','','','',0,'','','','','','8fd2b8f8-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',20,'','cu','2021-11-08 10:29:18','attributes','all',0,NULL,'V1'),(224,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:26',74,NULL,0,'','','','','','',0,'','','','','','9ac2d8c3-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cu','2021-11-08 10:29:46','attributes','all',0,NULL,'V1'),(223,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:48',74,NULL,0,'','','','','','',0,'','','','','','b71d802b-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cu','2021-11-08 10:30:12','attributes','all',0,NULL,'V1'),(18,7,3,NULL,'NA68832',1,1,0,3,'','','product','','Apple','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df2763a2-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',48,'mobile','cu','2021-05-04 14:07:43','attributes','all',0,NULL,'V1'),(251,7,3,NULL,'NA99259',1,0,0,999,'','','product','','Apple','iphone 11','iphone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df48e350-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:50:50','attributes','all',0,NULL,'V1'),(250,7,3,NULL,'NA99964',1,0,0,999,'','','product','','Apple','iPhone 12','iPhone 12','iPhone 12','iPhone 12','iPhone 12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df4fbd88-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:13','attributes','all',0,NULL,'V1'),(249,7,3,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df58429d-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:03','attributes','all',0,NULL,'V1'),(168,24,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:47:28',74,NULL,0,'','','','','','',0,'','','','','','90024f0a-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-12-15 13:49:11','attributes','all',0,NULL,'V1'),(135,24,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',92,NULL,0,'','','','','','',0,'','','','','','f0fc7f2c-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-12-15 13:51:12','attributes','all',0,NULL,'V1'),(340,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Premium','Konnecta Postpaid Max Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d66d432-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',24,'','cda','2022-02-21 10:03:23','attributes','all',0,NULL,'V1'),(336,50,17,NULL,'',0,1,0,0,'','','offer_prepaid','','','Konnecta Prepaid Max','Konnecta Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-24 08:02:17',89,NULL,0,'','','','','','',0,'','','','','','709a74cb-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cda','2022-02-21 10:04:12','attributes','all',0,NULL,'V1'),(332,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d6e0827-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-15 16:14:04','attributes','all',0,NULL,'V1'),(334,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d5e6537-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',19,'','cda','2022-02-15 16:15:02','attributes','all',0,NULL,'V1'),(333,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d66919b-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cda','2022-02-15 16:14:31','attributes','all',0,NULL,'V1'),(331,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Basic','Konnecta Basic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','5a7f1988-8e78-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cda','2022-02-15 16:00:33','attributes','all',0,NULL,'V1'),(266,11,0,NULL,'',0,0,0,0,'','','product','','Orange','Flybox','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2021-12-30 10:00:30',89,NULL,0,'','','','','','',0,'','','','','','52192130-6957-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-12-30 10:01:32','attributes','all',0,NULL,'V1'),(78,14,0,NULL,'NA77252',1,0,0,999,'','','product','','Alcatel','1066G','1066G','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2024-02-05 20:44:26',59,NULL,0,'','','','','','',0,'','','','','','3b9b75bb-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 08:26:14','attributes','all',0,NULL,'V1'),(75,14,0,NULL,'NA76751',1,0,0,999,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',74,NULL,0,'','','','','','',0,'','','','','','aa9c9224-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 08:30:03','attributes','all',0,NULL,'V1'),(79,14,39,NULL,'NA99715',1,0,0,999,'','','product','','Alcatel','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','04a677c7-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 08:32:45','attributes','all',0,NULL,'V1'),(80,14,39,NULL,'NA99195',1,0,0,999,'','','product','','Alcatel','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','6f0fac0b-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 08:35:40','attributes','all',0,NULL,'V1'),(163,24,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','1595ce71-7393-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 10:33:43','attributes','all',0,NULL,'V1'),(161,24,0,NULL,'NA79511',1,1,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-09-19 13:26:23',59,NULL,0,'','','','','','',0,'','','','','','f5b85283-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:01','attributes','all',0,NULL,'V1'),(166,24,0,NULL,'NA77252',1,1,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-08-21 12:22:00',59,NULL,0,'','','','','','',0,'','','','','','f5c20176-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(167,24,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:45:25',74,NULL,0,'','','','','','',0,'','','','','','f5cb5e43-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(139,24,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-24 09:49:29',74,NULL,0,'','','','','','',0,'','','','','','f5de9a22-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:05','attributes','all',0,NULL,'V1'),(140,24,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5e7f0f3-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:12','attributes','all',0,NULL,'V1'),(169,24,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f0e21a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:12','attributes','all',0,NULL,'V1'),(170,24,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f9bee5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:17','attributes','all',0,NULL,'V1'),(146,24,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f602e11c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:03','attributes','all',0,NULL,'V1'),(147,24,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f60c0b40-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:11','attributes','all',0,NULL,'V1'),(159,24,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f615364f-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:14','attributes','all',0,NULL,'V1'),(171,24,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6277b5b-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:12','attributes','all',0,NULL,'V1'),(172,24,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6306227-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0,NULL,'V1'),(173,24,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f63914d9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:55','attributes','all',0,NULL,'V1'),(160,24,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f641bfba-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:42','attributes','all',0,NULL,'V1'),(181,24,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f64a3f6c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:11','attributes','all',0,NULL,'V1'),(174,24,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f652c6c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:23','attributes','all',0,NULL,'V1'),(138,24,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f65b382a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(182,24,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f663eb07-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:18','attributes','all',0,NULL,'V1'),(158,24,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f66c4ebf-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:44','attributes','all',0,NULL,'V1'),(156,24,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f674cd49-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:52','attributes','all',0,NULL,'V1'),(157,24,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f67d3dfc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:21','attributes','all',0,NULL,'V1'),(137,24,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f685b91c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:38:52','attributes','all',0,NULL,'V1'),(136,24,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f68e4766-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:14','attributes','all',0,NULL,'V1'),(184,24,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f696be74-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0,NULL,'V1'),(186,24,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f69f4752-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0,NULL,'V1'),(141,24,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6a7e231-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:51','attributes','all',0,NULL,'V1'),(142,24,0,NULL,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-02-06 09:16:46',74,NULL,0,'','','','','','',0,'','','','','','f6b0aa50-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(151,24,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6b96303-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:38:56','attributes','all',0,NULL,'V1'),(183,24,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6c1fd6e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:41','attributes','all',0,NULL,'V1'),(164,24,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6cab4b9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0,NULL,'V1'),(175,24,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6d37761-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:50','attributes','all',0,NULL,'V1'),(176,24,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6dc4270-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:26','attributes','all',0,NULL,'V1'),(185,24,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6e52400-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:51','attributes','all',0,NULL,'V1'),(152,24,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6edcc26-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:44','attributes','all',0,NULL,'V1'),(187,24,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6f687c6-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:27','attributes','all',0,NULL,'V1'),(148,24,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6ff3783-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:56','attributes','all',0,NULL,'V1'),(143,24,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f707d4a7-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:58','attributes','all',0,NULL,'V1'),(144,24,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7108112-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:26','attributes','all',0,NULL,'V1'),(165,24,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f71935e4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:59','attributes','all',0,NULL,'V1'),(162,24,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7223409-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-01-12 13:40:08','attributes','all',0,NULL,'V1'),(177,24,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f733ed2e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:00','attributes','all',0,NULL,'V1'),(178,24,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f73ca2db-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:02','attributes','all',0,NULL,'V1'),(155,24,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f74568c0-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:34','attributes','all',0,NULL,'V1'),(145,24,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f74e554a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0,NULL,'V1'),(134,24,0,NULL,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-29 13:34:58',74,NULL,0,'','','','','','',0,'','','','','','f75745a5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-12 13:38:46','attributes','all',0,NULL,'V1'),(188,24,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7606092-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(179,24,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7693297-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-01-12 13:39:24','attributes','all',0,NULL,'V1'),(180,24,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f771e0c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:57','attributes','all',0,NULL,'V1'),(153,24,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f77a8f29-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0,NULL,'V1'),(154,24,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78351cc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:20','attributes','all',0,NULL,'V1'),(189,24,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78c0a04-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(150,24,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7950589-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:39','attributes','all',0,NULL,'V1'),(149,24,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f79de0ee-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:49','attributes','all',0,NULL,'V1'),(243,1,10,NULL,'NA99955',1,0,0,999,'','','product','','Orange','Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-01-20 12:55:57',59,NULL,0,'','','','','','',0,'','','','','','4f939f5b-79f0-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-20 12:56:43','attributes','all',0,NULL,'V1'),(200,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-28 06:16:03',85,NULL,0,'','','','','','',0,'','','','','','1242e8e0-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-03-06 12:41:25','attributes','all',0,NULL,'V1'),(339,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Prestige','Konnecta Postpaid Max Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d6eecab-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-21 10:04:12','attributes','all',0,NULL,'V1'),(338,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Standard','Konnecta Postpaid Max Standard','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d76e45b-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cda','2022-02-21 10:04:50','attributes','all',0,NULL,'V1'),(335,1,0,NULL,'NA101009',1,0,0,999,'','','product','','Samsung','Galaxy S22','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:41:05',84,NULL,0,'','','','','','',0,'','','','','','d63fd194-9319-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',21,'mobile','cu','2022-02-21 13:27:38','attributes','all',0,NULL,'V1'),(341,1,8,NULL,'NA101276',1,0,0,999,'','','product','','Samsung','Galaxy A13','Galaxy A13','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:33:31',84,NULL,0,'','','','','','',0,'','','','','','19c3dcbe-93ec-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',25,'mobile','cu','2022-02-22 14:31:33','attributes','all',0,NULL,'V1'),(337,50,18,NULL,'',0,1,0,0,'','','offer_prepaid','','','Unlimited Prepaid Max','Unlimited Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:39',89,NULL,0,'','','','','','',0,'','','','','','70a25627-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-02-21 10:03:57','attributes','all',0,NULL,'V1'),(342,1,8,NULL,'NA100838',1,0,0,999,'','','product','','Samsung','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:14:21',84,NULL,0,'','','','','','',0,'','','','','','26c45a7a-9552-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',17,'mobile','cu','2022-02-24 09:15:40','attributes','all',0,NULL,'V1'),(349,7,21,NULL,'',0,1,0,0,'','','product','','Orange','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-05-05 08:09:15',59,NULL,0,'','','','','','',0,'','','','','','15f5729a-c566-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-04-26 13:38:57','attributes','all',0,NULL,'V1'),(294,51,0,0,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a42f9a42-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:20:53','attributes','all',0,NULL,'V1'),(299,51,0,0,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a43b2608-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:42','attributes','all',0,NULL,'V1'),(300,51,0,0,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a4464695-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:35','attributes','all',0,NULL,'V1'),(301,51,0,0,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45175ce-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(272,51,0,0,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45cde96-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:23','attributes','all',0,NULL,'V1'),(273,51,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a46824aa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(302,51,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4730519-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(303,51,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a47df9fa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:29','attributes','all',0,NULL,'V1'),(279,51,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4892058-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:07','attributes','all',0,NULL,'V1'),(280,51,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4949a9b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:17','attributes','all',0,NULL,'V1'),(292,51,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a49ee3ba-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:31','attributes','all',0,NULL,'V1'),(268,51,0,0,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4a97c46-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:57','attributes','all',0,NULL,'V1'),(304,51,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4b3fb76-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0,NULL,'V1'),(305,51,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4bdf2f5-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0,NULL,'V1'),(306,51,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4c7f700-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:22','attributes','all',0,NULL,'V1'),(293,51,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4d20694-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0,NULL,'V1'),(314,51,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4dbee29-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(307,51,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4e5c9be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:35','attributes','all',0,NULL,'V1'),(271,51,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4f03c16-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:03','attributes','all',0,NULL,'V1'),(315,51,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4fa3ceb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:25','attributes','all',0,NULL,'V1'),(291,51,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5043653-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:16','attributes','all',0,NULL,'V1'),(289,51,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a50e1dc0-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:55','attributes','all',0,NULL,'V1'),(290,51,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5186534-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(270,51,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5225ef8-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:41','attributes','all',0,NULL,'V1'),(269,51,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a52c65e7-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0,NULL,'V1'),(317,51,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5367510-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:45','attributes','all',0,NULL,'V1'),(319,51,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5405250-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(274,51,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a54a46bf-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:57','attributes','all',0,NULL,'V1'),(275,51,0,0,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a55c44a9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(284,51,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a566ee8a-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:46','attributes','all',0,NULL,'V1'),(316,51,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a57172f3-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:43','attributes','all',0,NULL,'V1'),(297,51,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a57c4b4f-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:46','attributes','all',0,NULL,'V1'),(308,51,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a58703dd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:26','attributes','all',0,NULL,'V1'),(309,51,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59176ad-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:29','attributes','all',0,NULL,'V1'),(318,51,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59bce97-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:52','attributes','all',0,NULL,'V1'),(285,51,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5a5de39-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:47','attributes','all',0,NULL,'V1'),(320,51,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5afeab1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:42','attributes','all',0,NULL,'V1'),(281,51,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5b9f0be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:06','attributes','all',0,NULL,'V1'),(276,51,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5c419f1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:26','attributes','all',0,NULL,'V1'),(277,51,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ce4b7b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:05','attributes','all',0,NULL,'V1'),(298,51,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5d8626e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:22','attributes','all',0,NULL,'V1'),(295,51,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5e347fb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-03 10:21:54','attributes','all',0,NULL,'V1'),(296,51,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ed9c24-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:24','attributes','all',0,NULL,'V1'),(310,51,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5f81fcd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:38','attributes','all',0,NULL,'V1'),(311,51,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a602846e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:51','attributes','all',0,NULL,'V1'),(288,51,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a60cdc45-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(278,51,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a61727ea-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:52','attributes','all',0,NULL,'V1'),(267,51,0,0,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6215be9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:22:05','attributes','all',0,NULL,'V1'),(321,51,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a62bd425-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-05-03 10:20:47','attributes','all',0,NULL,'V1'),(312,51,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a63615d1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-05-03 10:20:45','attributes','all',0,NULL,'V1'),(313,51,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64006b1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:37','attributes','all',0,NULL,'V1'),(286,51,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64a3e6b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:59','attributes','all',0,NULL,'V1'),(287,51,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6543d18-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:41','attributes','all',0,NULL,'V1'),(322,51,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a65e5e92-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:30','attributes','all',0,NULL,'V1'),(283,51,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a668a392-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(282,51,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a672ac3d-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:05','attributes','all',0,NULL,'V1'),(255,49,0,NULL,'NA68012',1,0,0,1,'','','product','','Samsung','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-08-21 12:18:52',92,NULL,0,'','','','','','',0,'','','','','','ad543c1d-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:35:44','attributes','all',0,NULL,'V1'),(256,49,0,NULL,'NA57406',1,0,0,2,'','','product','','Samsung','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad5e2e59-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:19','attributes','all',0,NULL,'V1'),(257,49,0,NULL,'NA69997',1,0,0,3,'','','product','','Samsung','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad67cea7-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:44','attributes','all',0,NULL,'V1'),(258,49,0,NULL,'NA63614',1,0,0,4,'','','product','','Samsung','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad719209-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-05-03 15:36:11','attributes','all',0,NULL,'V1'),(352,14,0,NULL,'NA99508',1,0,0,999,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-10-05 08:07:55',99,NULL,0,'','','','','','',0,'','','','','','4b3a7d19-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-04 15:03:50','attributes','all',0,NULL,'V1'),(351,14,39,NULL,'NA100175',1,0,0,999,'','','product','','Alcatel','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:02',59,NULL,0,'','','','','','',0,'','','','','','4b44cd56-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-04 15:04:24','attributes','all',0,NULL,'V1'),(350,14,39,NULL,'',0,0,0,0,'','','product','','Pack','Alcatel Neo + Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','d3d8d6f9-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-04 15:08:26','attributes','all',0,NULL,'V1'),(353,7,0,NULL,'',0,1,0,0,'','','product','','Pack','Alcatel Neo 1 + Orange Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:48',59,NULL,0,'','','','','','',0,'','','','','','f86c0e85-cc49-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-05 08:04:55','attributes','all',0,NULL,'V1'),(356,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-07-28 13:18:45',92,NULL,0,'','','','','','',0,'','','','','','cb2209e3-0288-11ed-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-13 08:51:08','attributes','all',0,NULL,'V1'),(357,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:19:17',92,NULL,0,'','','','','','',0,'','','','','','bb196cf0-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-07-25 12:39:59','attributes','all',0,NULL,'V1'),(358,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-05-24 13:52:14',106,NULL,0,'','','','','','',0,'','','','','','db9f50da-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',14,'','cda','2022-07-25 12:40:32','attributes','all',0,NULL,'V1'),(360,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:25',92,NULL,0,'','','','','','',0,'','','','','','05a12f65-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:42:05','attributes','all',0,NULL,'V1'),(359,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:23',92,NULL,0,'','','','','','',0,'','','','','','05aaac7e-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:42:25','attributes','all',0,NULL,'V1'),(362,63,29,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:23:18',92,NULL,0,'','','','','','',0,'','','','','','05b3caaa-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-07-25 12:41:52','attributes','all',0,NULL,'V1'),(361,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:24',92,NULL,0,'','','','','','',0,'','','','','','05bcdf80-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:41:19','attributes','all',0,NULL,'V1'),(364,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-01-31 17:13:38',74,NULL,0,'','','','','','',0,'','','','','','71ba0605-1331-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-03 13:38:03','attributes','all',0,NULL,'V1'),(71,14,0,NULL,'NA97011',1,0,0,999,'','','product','','Samsung','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c2f0301-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:06','attributes','all',0,NULL,'V1'),(83,14,0,NULL,'NA73732',1,0,0,999,'','','product','','Itel','it2130','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c397d4e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:56','attributes','all',0,NULL,'V1'),(411,80,51,NULL,'NA99972',1,1,1,5,'','','product','','Apple','FR | iPhone 12 Pro Max','EN | iPhone 12 Pro Max','iPhone 12 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 14:48:18',115,NULL,0,'','','','','','',0,'','','','','','4d2f7201-c53d-4306-a303-dbe451631c32',NULL,NULL,'','','','','phonedir_oxygen',23,'mobile','cdd','2023-11-17 14:49:25','attributes','all',0,NULL,'V1'),(82,14,0,NULL,'NA85691',1,0,0,999,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c4de382-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:12','attributes','all',0,NULL,'V1'),(69,14,0,NULL,'NA99526',1,0,0,999,'','','product','','Samsung','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c5810d9-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:16','attributes','all',0,NULL,'V1'),(81,14,0,NULL,'NA76351',1,0,0,999,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c628373-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:46','attributes','all',0,NULL,'V1'),(68,14,0,NULL,'NA99525',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c6cbb12-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:49','attributes','all',0,NULL,'V1'),(67,14,0,NULL,'NA69131',1,0,0,999,'','','product','','Tecno','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c81f304-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-08-12 07:58:02','attributes','all',0,NULL,'V1'),(77,14,0,NULL,'NA70090',1,0,0,999,'','','product','','Huawei','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c8c14a7-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0,NULL,'V1'),(66,14,0,NULL,'NA86072',1,0,0,999,'','','product','','Apple','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c988c18-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:56','attributes','all',0,NULL,'V1'),(76,14,0,NULL,'NA85531',1,0,0,999,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ca22689-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:31','attributes','all',0,NULL,'V1'),(65,14,0,NULL,'NA86031',1,0,0,999,'','','product','','Apple','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2023-10-05 08:07:07',99,NULL,0,'','','','','','',0,'','','','','','4cabf40e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-08-12 07:57:30','attributes','all',0,NULL,'V1'),(74,14,0,NULL,'NA99367',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cc12cd0-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:14','attributes','all',0,NULL,'V1'),(73,14,0,NULL,'NA99129',1,0,0,999,'','','product','','Samsung','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ccec63d-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0,NULL,'V1'),(72,14,0,NULL,'NA99225',1,0,0,999,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cd7a638-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:45','attributes','all',0,NULL,'V1'),(371,65,0,0,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:04',74,NULL,0,'','','','','','',0,'','','','','','c8df59a9-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-08-29 08:23:07','attributes','all',0,NULL,'V1'),(366,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d31b5354-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-08-29 08:23:36','attributes','all',0,NULL,'V1'),(365,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d324da98-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-08-29 08:24:19','attributes','all',0,NULL,'V1'),(369,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da820a50-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:30','attributes','all',0,NULL,'V1'),(368,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da8bed01-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:24:04','attributes','all',0,NULL,'V1'),(367,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:26',74,NULL,0,'','','','','','',0,'','','','','','da954ca2-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:50','attributes','all',0,NULL,'V1'),(370,65,42,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:38',74,NULL,0,'','','','','','',0,'','','','','','e1bf8e55-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-08-29 08:24:55','attributes','all',0,NULL,'V1'),(355,59,25,NULL,'',0,1,1,0,'','','product','','Xiaomi','Pad 5','Pad 5','AR','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 05:59:46',62,NULL,0,'','','','','','',0,'','','','','','46b0f37b-2e72-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-09-07 06:00:49','attributes','all',0,NULL,'V1'),(372,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Card2wallet','Card2wallet','Card2wallet','Card2wallet','Card2wallet','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-11-21 20:39:02',59,NULL,0,'','','','','','',0,'','','','','','f67b81a7-69db-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-11-21 20:40:23','attributes','all',0,NULL,'V1'),(217,7,0,NULL,'NA99224',1,0,0,999,'','','product','','Samsung','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:46',0,NULL,0,'','','','','','',0,'','','','','','7d73f3cf-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-12-13 13:24:01','attributes','all',0,NULL,'V1'),(382,71,0,NULL,'',0,0,0,0,'','','offer_postpaid','','','sellecta test','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-01-03 15:28:02',59,NULL,0,'','','','','','',0,'','','','','','31e16bed-8b7b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2023-01-03 15:29:26','attributes','all',0,NULL,'V1'),(387,73,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Akama Ral A','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,109,'2023-02-14 13:31:58',109,NULL,0,'','','','','','',0,'','','','','','e0ab0892-ac6b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2023-02-14 13:32:13','attributes','all',0,NULL,'V1'),(383,24,0,NULL,'',0,0,0,0,'','','product','','Apple','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2023-01-31 13:39:50',74,NULL,0,'','','','','','',0,'','','','','','b35d8267-a16c-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2023-01-31 13:39:59','attributes','all',0,NULL,'V1'),(386,73,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Akama','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,108,'2023-02-14 13:50:38',108,NULL,0,'','','','','','',0,'','','','','','c23cf0ab-ac6b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','pd','2023-02-14 13:50:59','attributes','all',0,NULL,'V1'),(24,7,0,NULL,'NA79551',1,1,0,7,'','','product','','Samsung','Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:43',82,NULL,0,'','','','','','',0,'','','','','','3806c3a0-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-05-04 14:08:20','attributes','all',0,NULL,'V1'),(402,87,0,NULL,'',0,1,1,0,'','','product','','Incgo','Pressure Washer - 200 Bar','Pressure Washer - 200 Bar','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 05:54:41',115,NULL,0,'','','','','','',0,'','','','','','e6cadeef-0630-44af-a61f-208df50958e2',NULL,NULL,'','','','','',20,'','cda','2023-09-13 12:24:33','attributes','all',0,NULL,'V1'),(401,87,0,NULL,'',0,1,1,0,'','','product','','Formula 1','Car Wax','Car Wax','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 05:54:42',115,NULL,0,'','','','','','',0,'','','','','','1db09eb3-0f9d-41bc-8b36-969962985cdd',NULL,NULL,'','','','','',7,'','cda','2023-09-13 12:27:32','attributes','all',0,NULL,'V1'),(404,84,0,NULL,'',0,1,1,0,'','','product','','','Osram Projector','Osram Projector','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 10:28:03',115,NULL,0,'','','','','','',0,'','','','','','5a26aee8-2573-4b56-a5ba-c262367b53aa',NULL,NULL,'','','','','',11,'','cda','2023-09-14 06:10:46','attributes','all',0,NULL,'V1'),(403,84,0,NULL,'',0,1,1,0,'','','product','','','Osram LED','Osram LED','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 10:28:05',85,NULL,0,'','','','','','',0,'','','','','','7c70620b-2655-40d0-8c28-91c88f887fb6',NULL,NULL,'','','','','',10,'','cda','2023-09-14 06:09:30','attributes','all',0,NULL,'V1'),(461,77,0,NULL,'',0,1,1,0,'','','product','','','City OEM Alloy','City OEM Alloy','سبائك المدينة','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:26:19',115,NULL,0,'','','','','','',0,'','','','','','5cf9b13e-479d-4044-8d3e-93936dfbcb54',NULL,NULL,'','','','','',12,'','cda','2023-09-14 06:26:55','attributes','all',0,NULL,'V1'),(460,77,0,NULL,'',0,1,1,0,'','','product','','','Civic OEM Alloy','Civic OEM Alloy','Civic OEM Alloy','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:26:21',115,NULL,0,'','','','','','',0,'','','','','','3974d70b-fec5-43ad-b096-7ee42b2e1127',NULL,NULL,'','','','','',6,'','cda','2023-09-14 06:27:07','attributes','all',0,NULL,'V1'),(407,85,56,NULL,'',0,1,1,0,'','','product','','MG Motors','MG ZS Exclusive','MG ZS Exclusive','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:21',115,NULL,0,'','','','','','',0,'','','','','','ab913676-8438-43e2-b3a5-9e0fc621c324',NULL,NULL,'','','','','',6,'','cda','2023-09-14 06:32:14','attributes','all',0,NULL,'V1'),(419,85,57,0,'',0,1,1,0,'','','product','','','Toyota Corolla','Toyota Corolla','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:53',119,NULL,0,'','','','','','',0,'','','','','','00c43ec9-5cdc-49c4-b24d-fb00fec6e9a0',NULL,NULL,'','','','','',9,'','cda','2023-09-14 06:32:31','attributes','all',0,NULL,'V1'),(418,85,57,0,'',0,1,1,0,'','','product','','MG Motors','MG ZS Excite','MG ZS Excite','MG ZS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:56',119,NULL,0,'','','','','','',0,'','','','','','692c63d0-b0ce-45d9-a042-31881bb515be',NULL,NULL,'','','','','',28,'','cda','2023-09-14 06:33:08','attributes','all',0,NULL,'V1'),(533,104,75,NULL,'',0,0,0,0,'','','product','','','3124312','3124312','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,115,'2023-10-25 07:03:01',115,NULL,0,'','','','','','',0,'','','','','','80439e9e-7304-11ee-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2023-10-25 07:03:30','attributes','all',0,NULL,'V1'),(40,12,0,NULL,'NA99368',1,1,0,999,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-17 16:13:35',59,NULL,0,'','','','','','',0,'','','','','','7d73b2d0-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2021-05-28 14:18:22','attributes','all',0,NULL,'V1');
/*!40000 ALTER TABLE `products_v49` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_v_1`
--

DROP TABLE IF EXISTS `products_v_1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_v_1` (
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
  `service_max_slots` int(10) DEFAULT 1 COMMENT 'max consecutive no of slots per service booking',
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
  `allow_questions` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT '0=No , 1=visible/editable logged-in users  , 2= visible/editable all users , 3= editable logged-in / visible all users',
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
  `familie_id` int(11) DEFAULT NULL,
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
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `product_definition_id` int(11) DEFAULT NULL,
  `product_version` varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT 'V1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_v_1`
--

LOCK TABLES `products_v_1` WRITE;
/*!40000 ALTER TABLE `products_v_1` DISABLE KEYS */;
INSERT INTO `products_v_1` VALUES (1,3,0,NULL,'',0,0,0,2,'','','product','','Apple','iPhone 7','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e51ec17f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',17,'','cu',NULL,'attributes','all',0,NULL,'V1'),(2,3,0,NULL,'',0,0,0,7,'','','product','','Samsung','Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e52258e3-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(3,3,0,NULL,'',0,0,0,8,'','','product','','Samsung','Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e524eb7d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(4,3,0,NULL,'',0,0,0,11,'','','product','','Tecno','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',1,NULL,0,'','','','','','',0,'','','','','','e5275f7a-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(5,3,0,NULL,'',0,0,0,3,'','','product','','Apple','iPhone X','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e529a69d-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(6,3,0,NULL,'',0,0,0,1,'','','product','','Alcatel','1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52bfeb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(7,3,0,NULL,'',0,0,0,5,'','','product','','Samsung','Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e52e4cb9-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(8,3,0,NULL,'',0,0,0,6,'','','product','','Samsung','Galaxy A8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e530bbef-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(9,3,0,NULL,'',0,0,0,4,'','','product','','Apple','iPhone XS Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5330b16-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(10,3,0,NULL,'',0,0,0,9,'','','product','','Samsung','S10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e5358bed-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(11,3,0,NULL,'',0,0,0,12,'','','product','','Tecno','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e537c161-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(12,3,0,NULL,'',0,0,0,10,'','','product','','Samsung','S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-22 06:53:16',0,NULL,0,'','','','','','',0,'','','','','','e539c73f-594a-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(19,7,0,NULL,'NA71311',1,1,0,8,'','','product','','Samsung','Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','SM-G955F - Galaxy S8+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:43',82,NULL,0,'','','','','','',0,'','','','','','37e46c49-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',13,'mobile','cu','2021-05-04 14:07:50','attributes','all',0,NULL,'V1'),(30,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','b9fec1af-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-05-18 14:37:20','attributes','all',0,NULL,'V1'),(32,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba0271d1-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cu','2021-05-18 14:37:41','attributes','all',0,NULL,'V1'),(29,9,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-05-18 14:37:17',59,NULL,0,'','','','','','',0,'','','','','','ba050e3d-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-05-18 14:38:44','attributes','all',0,NULL,'V1'),(31,9,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-01-03 15:23:01',59,NULL,0,'','','','','','',0,'','','','','','ba079127-8f96-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cu','2021-05-18 14:38:33','attributes','all',0,NULL,'V1'),(34,7,0,NULL,'NA73732',1,1,0,6,'','','product','','Itel','it2130 new','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-05-11 11:59:20',60,NULL,0,'','','','','','',0,'','','','','','3819aaab-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-05-04 14:08:09','attributes','all',0,NULL,'V1'),(231,1,0,NULL,'',0,0,0,22,'','','product','','','Orange Halona','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:39:59',84,NULL,0,'','','','','','',0,'','','','','','bdaeccfe-1184-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-09 15:44:50','attributes','all',0,NULL,'V1'),(26,7,0,0,'NA70452',1,0,0,11,'','','product','','Tecno','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','Orange Rise 32','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:45',56,NULL,0,'','','','','','',0,'','','','','','3814dd16-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:52','attributes','all',0,NULL,'V1'),(25,7,3,NULL,'NA86072',1,1,0,5,'','','product','','Apple','iPhone XS Max','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','380d4afa-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-05-04 14:06:55','attributes','all',0,NULL,'V1'),(23,7,0,NULL,'NA79511',1,1,0,2,'','','product','','Alcatel','Neo 1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-16 22:04:14',57,NULL,0,'','','','','','',0,'','','','','','3800b9bc-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',12,'mobile','cu','2021-05-04 14:08:04','attributes','all',0,NULL,'V1'),(22,7,0,NULL,'NA76351',1,1,0,10,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:44',82,NULL,0,'','','','','','',0,'','','','','','37f9f305-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-05-04 14:07:50','attributes','all',0,NULL,'V1'),(20,7,0,NULL,'NA78851',1,1,0,9,'','','product','','Samsung','Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','SM-G965F - Galaxy S9+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:44',82,NULL,0,'','','','','','',0,'','','','','','37eae657-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',10,'mobile','cu','2021-05-04 14:07:38','attributes','all',0,NULL,'V1'),(21,7,3,NULL,'NA77753',1,1,0,4,'','','product','','Apple','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-12-14 23:01:44',60,NULL,0,'','','','','','',0,'','','','','','37f16683-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',10,'mobile','cu','2021-05-04 14:06:45','attributes','all',0,NULL,'V1'),(17,6,0,NULL,'',0,0,0,0,'','','product','','Samsung','Galaxy S10+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-08-05 14:01:40',1,NULL,0,'','','','','','',0,'','','','','','280fea73-d724-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu',NULL,'attributes','all',0,NULL,'V1'),(92,7,0,0,'NA80112',1,0,0,12,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:46',56,NULL,0,'','','','','','',0,'','','','','','5d452512-53f8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:25','attributes','all',0,NULL,'V1'),(117,1,0,NULL,'',0,0,0,56,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','0bc7ddd2-4b5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2020-12-31 11:20:05','attributes','all',0,NULL,'V1'),(126,1,0,NULL,'NA99371',1,0,0,54,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','79f5c526-617a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-01-28 15:07:16','attributes','all',0,NULL,'V1'),(133,21,0,NULL,'',0,0,0,0,'','','product','','Test','test','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-02-24 09:42:37',0,NULL,0,'','','','','','',0,'','','','','','a0f996ea-7684-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-02-24 09:43:10','attributes','all',0,NULL,'V1'),(218,7,0,NULL,'',0,1,1,0,'','','product','','OnePlus','Nord','Nord','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2023-04-17 08:42:49',62,NULL,0,'','','','','','',0,'','','','','','8551df06-bf84-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-05-28 07:16:30','attributes','all',0,NULL,'V1'),(41,13,0,NULL,'',0,0,0,0,'','','product','','Testift','testift','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-10-12 09:29:21',0,NULL,0,'','','','','','',0,'','','','','','68d9d606-0c6d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cu',NULL,'attributes','all',0,NULL,'V1'),(42,1,0,NULL,'NA85811',1,0,0,28,'','','product','','Orange','Sanza','Orange Sanza','Orange Sanza','Orange Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','908f5515-0d5a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-11-03 14:53:11','attributes','all',0,NULL,'V1'),(84,15,0,NULL,'NA99191',1,1,1,1,'','','product','','OPPO','Reno 2','Reno 2','Reno 2','Reno 2','Reno 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','5403e5ff-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',24,'mobile','cu','2022-09-07 06:01:45','attributes','all',0,NULL,'V1'),(86,15,0,NULL,'NA97251',1,1,1,4,'','','product','','Samsung','Galaxy Note 9','Galaxy Note 9','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','Galaxy Note 9 - Android Pie Upgrade','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','540fef9a-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-05 04:19:07','attributes','all',0,NULL,'V1'),(85,15,0,NULL,'NA99292',1,1,1,5,'','','product','','OPPO','A91','A91','A91','A91','A91','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','540ace4f-0f94-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',18,'mobile','cu','2021-03-05 04:18:18','attributes','all',0,NULL,'V1'),(43,1,0,NULL,'NA96411',1,0,0,20,'','','product','','Itel','MC20','MC20','MC20','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','41806800-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:34:03','attributes','all',0,NULL,'V1'),(44,1,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ebc041dd-0fbc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:51:45','attributes','all',0,NULL,'V1'),(45,1,0,NULL,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X','iPhone X 64GB','iPhone X 64GB','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','61c0bfa9-0fc0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-30 14:51:54','attributes','all',0,NULL,'V1'),(48,1,0,NULL,'NA99307',1,0,0,45,'','','product','','Samsung','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','43c4e363-0fc2-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 09:54:04','attributes','all',0,NULL,'V1'),(49,1,0,NULL,'NA99308',1,0,0,46,'','','product','','Samsung','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','6ca3550d-0fc3-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:55:03','attributes','all',0,NULL,'V1'),(50,1,0,NULL,'NA99526',1,0,0,53,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','62801c47-0fc4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 11:11:57','attributes','all',0,NULL,'V1'),(51,1,0,NULL,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iPhone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','192596fc-0fc6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 15:51:00','attributes','all',0,NULL,'V1'),(91,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Monthly Mega Plus','Jazz - Monthly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12211677-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:37','attributes','all',0,NULL,'V1'),(90,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','122acaee-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2020-11-03 14:58:31','attributes','all',0,NULL,'V1'),(199,18,0,NULL,'',0,1,1,3,'','','offer_prepaid','','','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','Telenor - Weekly Super 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','1232e5e4-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:42:18','attributes','all',0,NULL,'V1'),(33,7,0,NULL,'NA80551',1,1,1,1,'','','product','','Alcatel','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','1 (Dual SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-17 12:29:40',59,NULL,0,'','','','','','',0,'','','','','','7d73b01d-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',11,'mobile','cu','2021-05-04 14:07:27','attributes','all',0,NULL,'V1'),(35,11,0,NULL,'',0,0,0,0,'','','product','','','Homebox haut-débit 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2020-11-03 14:59:25',1,NULL,0,'','','','','','',0,'','','','','','2a10bb19-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',22,'','cu','2020-11-03 15:01:01','attributes','all',0,NULL,'V1'),(37,11,0,0,'',0,0,0,0,'','','product','','','Airbox 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2022-02-17 15:36:54',56,NULL,0,'','','','','','',0,'','','','','','2a16f2b0-1de5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cu','2022-02-17 15:36:55','attributes','all',0,NULL,'V1'),(97,1,0,NULL,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1','1 (NFC Single SIM)','1 (NFC Single SIM)','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','6e3aef88-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-11-26 10:59:49','attributes','logged',0,NULL,'V1'),(58,1,0,NULL,'NA76351',1,0,0,58,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','e6198413-2fd6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-26 11:03:16','attributes','all',0,NULL,'V1'),(59,1,0,NULL,'NA80112',1,0,0,60,'','','product','','Tecno','R6+','R6+','R6+','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','31c2b493-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:04:46','attributes','all',0,NULL,'V1'),(98,1,0,NULL,'',0,0,0,48,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','c5bfed7f-2fd8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2020-11-26 11:16:57','attributes','all',0,NULL,'V1'),(99,1,0,NULL,'NA99975',1,0,0,49,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','5fe0bbf7-3328-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 16:23:58','attributes','all',0,NULL,'V1'),(102,1,0,NULL,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14a8df75-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:30','attributes','all',0,NULL,'V1'),(103,1,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3','U3 4G','U3 4G','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:57',59,NULL,0,'','','','','','',0,'','','','','','14af9103-4aad-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-30 14:41:55','attributes','all',0,NULL,'V1'),(105,1,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s','iPhone 6s 16GB','iPhone 6s 16GB','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','80638f62-4aae-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 14:51:44','attributes','all',0,NULL,'V1'),(106,1,0,NULL,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','iPhone XS','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','5036f54c-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:12:49','attributes','all',0,NULL,'V1'),(107,1,0,NULL,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max','iPhone XS Max 512GB','iPhone XS Max 512GB','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','f02d2074-4ab1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:16:22','attributes','all',0,NULL,'V1'),(52,1,0,NULL,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','33cb4a44-4ab4-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:33:00','attributes','all',0,NULL,'V1'),(108,1,0,NULL,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','0794ea79-4ab5-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:38:28','attributes','all',0,NULL,'V1'),(109,1,0,NULL,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','ae75c665-4ab6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:51:19','attributes','all',0,NULL,'V1'),(110,1,0,NULL,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','4c394816-4ab7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 15:55:40','attributes','all',0,NULL,'V1'),(96,1,0,NULL,'NA73732',1,0,0,17,'','','product','','Itel','IT2130','IT2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','2281091f-4ab8-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:01:09','attributes','all',0,NULL,'V1'),(111,1,0,NULL,'NA85691',1,0,0,19,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','7973f18c-4abc-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:31:48','attributes','all',0,NULL,'V1'),(62,1,0,NULL,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','Mahpee','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f84fe49c-4abd-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:43:37','attributes','all',0,NULL,'V1'),(63,1,0,NULL,'NA76811',1,0,0,26,'','','product','','Orange','Rise 53','Rise 53','Rise 53','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','37536730-4ac0-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 16:58:55','attributes','all',0,NULL,'V1'),(112,1,0,NULL,'NA97811',1,0,0,27,'','','product','','Orange','Rise 55','Rise 55','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9a4d5326-4ac6-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-30 17:45:19','attributes','all',0,NULL,'V1'),(113,1,0,NULL,'NA99129',1,0,0,38,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3eff26ac-4b4a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:26:31','attributes','all',0,NULL,'V1'),(114,1,0,NULL,'NA99225',1,0,0,39,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','0f5485af-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:40:35','attributes','all',0,NULL,'V1'),(57,1,0,NULL,'NA99197',1,0,0,42,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','ece291b1-4b4c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:46:46','attributes','all',0,NULL,'V1'),(53,1,0,NULL,'NA99212',1,0,0,44,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','a963e4f4-4b4d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 09:51:32','attributes','all',0,NULL,'V1'),(46,1,0,NULL,'NA99730',1,0,0,32,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','0e3e7f7d-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:53:56','attributes','all',0,NULL,'V1'),(47,1,0,NULL,'NA99224',1,0,0,33,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','98b16401-0fc1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 09:54:47','attributes','all',0,NULL,'V1'),(56,1,0,NULL,'NA99128',1,0,0,34,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',1,NULL,0,'','','','','','',0,'','','','','','c82806ff-2fd7-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-11-26 11:09:08','attributes','all',0,NULL,'V1'),(100,1,0,NULL,'NA99374',1,0,0,36,'','','product','','Samsung','Galaxy A11','Galaxy A11','MEA only - A11','MEA only - A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','11495a56-332a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2020-11-30 16:35:50','attributes','all',0,NULL,'V1'),(101,1,0,NULL,'NA99378',1,0,0,47,'','','product','','Samsung','Galaxy M11','MEA only - M11','MEA only - M11','MEA only - M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','4ef8da0c-332d-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-11-30 17:00:05','attributes','all',0,NULL,'V1'),(115,1,0,NULL,'NA97291',1,0,0,50,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','3f8a4505-4b56-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 10:53:10','attributes','all',0,NULL,'V1'),(116,1,0,NULL,'NA97293',1,0,0,51,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','266fbe41-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:07:18','attributes','all',0,NULL,'V1'),(60,1,0,NULL,'NA99367',1,0,0,52,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','bbf20cc9-4b58-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 11:10:20','attributes','all',0,NULL,'V1'),(118,1,0,NULL,'NA96431',1,0,0,57,'','','product','','Tecno','N11','N11','N11','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','19e2818a-4b6a-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 13:14:25','attributes','all',0,NULL,'V1'),(119,1,0,NULL,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','bb045aa5-4b71-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2020-12-31 14:09:26','attributes','all',0,NULL,'V1'),(120,1,0,NULL,'NA99062',1,0,0,18,'','','product','','Itel','IT2132','IT2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','8907ffc6-4b73-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2020-12-31 14:22:06','attributes','all',0,NULL,'V1'),(121,1,0,NULL,'NA84092',1,0,0,21,'','','product','','Mobiwire','AX2408','AX2408','AX2408','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','f7dae2d4-4b74-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2020-12-31 14:32:17','attributes','all',0,NULL,'V1'),(122,1,0,NULL,'NA99960',1,0,0,35,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','100e8834-4b79-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2020-12-31 15:03:01','attributes','all',0,NULL,'V1'),(123,1,0,NULL,'NA99508',1,0,0,30,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','ec3349e3-4b7c-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2020-12-31 15:30:25','attributes','all',0,NULL,'V1'),(124,1,0,NULL,'NA99662',1,0,0,41,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:00',1,NULL,0,'','','','','','',0,'','','','','','d36cae36-4b81-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:04:51','attributes','all',0,NULL,'V1'),(55,1,0,NULL,'NA71191',1,0,0,64,'','','product','','Wiko','Sunny','SUNNY','SUNNY','SUNNY','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','4312afeb-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:07:32','attributes','all',0,NULL,'V1'),(54,1,0,NULL,'NA79491',1,0,0,65,'','','product','','Wiko','Tommy3','TOMMY3','TOMMY3','TOMMY3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-09-21 09:40:01',1,NULL,0,'','','','','','',0,'','','','','','bf7ea052-4b82-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2020-12-31 16:12:16','attributes','all',0,NULL,'V1'),(132,1,0,NULL,'NA99294',1,0,0,61,'','','product','','Tecno','R7+','R7+','R7+','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','5273cd2f-61af-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-01-28 21:26:15','attributes','all',0,NULL,'V1'),(128,1,0,NULL,'NA99210',1,0,0,29,'','','product','','Orange','Sanza 2','Sanza 2','Sanza 2','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','9264ecbd-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:29','attributes','all',0,NULL,'V1'),(129,1,0,NULL,'NA99064',1,0,0,31,'','','product','','Orange','Sanza XL','Sanza XL','Sanza XL','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','92717ac5-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:19','attributes','all',0,NULL,'V1'),(130,1,0,NULL,'NA99736',1,0,0,43,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','92b46e91-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:29:20','attributes','all',0,NULL,'V1'),(131,1,0,NULL,'',0,0,0,55,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',0,NULL,0,'','','','','','',0,'','','','','','93067e8f-6196-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-01-28 18:28:25','attributes','all',0,NULL,'V1'),(192,15,0,NULL,'NA74171',1,1,1,9,'','','product','','Blackberry Mobile','KEYone','KEYone','KEYone','KEYone','KEYone','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',85,NULL,0,'','','','','','',0,'','','','','','7adc0aeb-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-03-06 12:36:56','attributes','all',0,NULL,'V1'),(193,15,0,NULL,'NA99266',1,1,1,8,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7ae4c517-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-03-06 12:35:51','attributes','all',0,NULL,'V1'),(194,15,0,NULL,'NA65430',1,1,1,7,'','','product','','Apple','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','iPad Pro 9.7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7aebe125-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'Tablet','cu','2021-03-06 12:36:22','attributes','all',0,NULL,'V1'),(195,15,0,NULL,'NA83732',1,1,1,11,'','','product','','Samsung','Galaxy S9+','Galaxy S9+','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','AMEA only - SM-G965F - Galaxy S9+ 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af2d920-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-03-06 12:37:03','attributes','all',0,NULL,'V1'),(214,15,0,NULL,'NA99971',1,0,0,6,'','','product','','Apple','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','iPhone 12 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',0,NULL,0,'','','','','','',0,'','','','','','b180c68e-da66-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-07-01 12:21:37','attributes','all',0,NULL,'V1'),(196,15,0,NULL,'NA55627',1,1,1,10,'','','product','','Samsung','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','SM-T715 - Galaxy Tab S2 8.0 (LTE)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:17',62,NULL,0,'','','','','','',0,'','','','','','7af9c988-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'Tablet','cu','2021-03-06 12:35:50','attributes','all',0,NULL,'V1'),(191,15,0,NULL,'',0,1,1,3,'','','product','','','One Plus','One Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',85,NULL,0,'','','','','','',0,'','','','','','7b00e72f-7e78-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-03-06 12:37:24','attributes','all',0,NULL,'V1'),(89,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','123ad363-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',8,'','cu','2020-11-03 14:59:20','attributes','all',0,NULL,'V1'),(198,18,0,NULL,'',0,1,1,2,'','','offer_prepaid','','','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','Jazz - Weekly Mega Plus','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','12185468-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2021-03-06 12:41:24','attributes','all',0,NULL,'V1'),(197,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','Jazz - Sindh Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 06:49:31',62,NULL,0,'','','','','','',0,'','','','','','1206ed96-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-03-06 12:41:12','attributes','all',0,NULL,'V1'),(88,18,0,NULL,'',0,1,1,1,'','','offer_prepaid','','','Jazz - Punjab Package','Jazz - Punjab Package','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-24 13:25:17',62,NULL,0,'','','','','','',0,'','','','','','120fcedb-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cu','2020-11-03 14:59:25','attributes','all',0,NULL,'V1'),(211,1,0,NULL,'',0,0,0,16,'','','product','','Infinix','Hot 9','Hot 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:58',59,NULL,0,'','','','','','',0,'','','','','','b6f0b4fa-8741-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2021-03-17 16:57:06','attributes','all',0,NULL,'V1'),(209,1,0,NULL,'NA99821',1,0,0,25,'','','product','','Orange','Nola play','Nola play','Orange Nola play (New chipset)','Orange Nola play (New chipset)','Orange Nola play (New chipset)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','311b896e-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-03-17 16:10:42','attributes','all',0,NULL,'V1'),(210,1,0,NULL,'NA99680',1,0,0,63,'','','product','','Tecno','Spark 6 Go','Spark Go_POM','Spark Go_POM','Spark Go_POM','Spark Go_POM','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','3123b12c-873b-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-03-17 16:10:32','attributes','all',0,NULL,'V1'),(212,7,0,NULL,'NA99662',1,0,0,999,'','','product','','Samsung','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:47',0,NULL,0,'','','','','','',0,'','','','','','f418e8ad-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:00','attributes','all',0,NULL,'V1'),(213,7,0,NULL,'NA53703',1,0,0,999,'','','product','','Samsung','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','AMEA only - A3 3G DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:47',0,NULL,0,'','','','','','',0,'','','','','','f41f9d0c-ace1-11eb-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-05-04 14:07:30','attributes','all',0,NULL,'V1'),(215,15,0,NULL,'',0,1,1,2,'','','product','','OPPO','F19 Pro','F19 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 06:01:16',62,NULL,0,'','','','','','',0,'','','','','','541df8a9-bf85-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-05-28 07:22:41','attributes','all',0,NULL,'V1'),(254,7,5,NULL,'NA99062',1,0,0,999,'','','product','','Itel','it2132','it2132','it2132','it2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-25 16:41:15',59,NULL,0,'','','','','','',0,'','','','','','81a604c1-4e0e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-25 16:41:57','attributes','all',0,NULL,'V1'),(227,1,0,NULL,'NA99954',1,0,0,24,'','','product','','Orange','Nola fun','Nola fun','Nola fun (itel A1)','Nola fun (itel A1)','Nola fun (itel A1)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','98d508bd-ce9d-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2021-06-16 12:23:06','attributes','all',0,NULL,'V1'),(230,1,0,NULL,'',0,0,0,68,'','','product','','Xiaomi','Redmi Note 9','Redmi Note 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','1a246a1c-f38a-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-08-02 12:08:02','attributes','all',0,NULL,'V1'),(228,1,0,NULL,'',0,0,0,66,'','','product','','Xiaomi','Mi Note 10 lite','Mi Note 10 lite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','02f4b33a-f372-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-08-02 09:14:57','attributes','all',0,NULL,'V1'),(229,1,0,NULL,'',0,0,0,67,'','','product','','Xiaomi','Redmi 9','Redmi 9','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2021-09-21 09:40:01',84,NULL,0,'','','','','','',0,'','','','','','a06253f7-f379-11eb-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-08-02 10:09:46','attributes','all',0,NULL,'V1'),(219,32,0,NULL,'',0,1,0,4,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:10:09',74,NULL,0,'','','','','','',0,'','','','','','e15bf54e-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cu','2021-09-10 10:01:38','attributes','all',0,NULL,'V1'),(220,32,0,NULL,'',0,1,0,3,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:30:51',74,NULL,0,'','','','','','',0,'','','','','','e1629d6f-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',18,'','cu','2021-09-10 10:01:14','attributes','all',0,NULL,'V1'),(221,32,0,NULL,'',0,1,0,2,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-26 09:28:38',74,NULL,0,'','','','','','',0,'','','','','','e16a7bc4-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cu','2021-09-10 10:00:08','attributes','all',0,NULL,'V1'),(222,32,0,NULL,'',0,1,0,1,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-21 14:25:53',74,NULL,0,'','','','','','',0,'','','','','','e170fcae-121d-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',21,'','cu','2021-09-10 10:01:25','attributes','all',0,NULL,'V1'),(127,1,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-09-21 09:39:58',56,NULL,0,'','','','','','',0,'','','','','','e2074089-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2021-01-28 18:28:23','attributes','all',0,NULL,'V1'),(235,1,0,NULL,'NA99808',1,0,0,37,'','','product','','Samsung','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','Galaxy A12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:39:59',59,NULL,0,'','','','','','',0,'','','','','','e2d6f79e-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:27:05','attributes','all',0,NULL,'V1'),(234,1,0,NULL,'NA99373',1,0,0,40,'','','product','','Samsung','Galaxy A21','Galaxy A21','MEA only - A21','MEA only - A21','MEA only - A21','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:00',59,NULL,0,'','','','','','',0,'','','','','','e2efb596-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2021-09-21 09:26:58','attributes','all',0,NULL,'V1'),(232,1,0,NULL,'',0,0,0,59,'','','product','','Tecno','Pop 4 Pro','Pop 4 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e38ca015-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:10','attributes','all',0,NULL,'V1'),(233,1,0,NULL,'',0,0,0,62,'','','product','','Tecno','Spark 6 Air','Spark 6 Air','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-21 09:40:01',59,NULL,0,'','','','','','',0,'','','','','','e3a4d80b-1abd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2021-09-21 09:26:16','attributes','all',0,NULL,'V1'),(236,47,0,NULL,'',0,0,0,0,'','','offer_postpaid','','','Offre Fibre essentiel','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:11:43',59,NULL,0,'','','','','','',0,'','','','','','5b4fa810-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2021-09-22 13:09:57','attributes','all',0,NULL,'V1'),(237,47,0,NULL,'',0,1,1,0,'','','offer_postpaid','','','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','Offre Fibre elite','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-22 13:16:55',59,NULL,0,'','','','','','',0,'','','','','','a1f14aaf-1ba6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-09-22 13:11:55','attributes','all',0,NULL,'V1'),(238,1,0,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','b930a803-1caf-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-23 20:50:16','attributes','all',0,NULL,'V1'),(239,1,0,NULL,'NA100887',1,0,0,999,'','','product','','Apple','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','iPhone 13 mini','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:58',59,NULL,0,'','','','','','',0,'','','','','','2ba30e56-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0,NULL,'V1'),(240,1,0,NULL,'NA100891',1,0,0,999,'','','product','','Apple','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','iPhone 13 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2babc0bd-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-09-30 12:17:22','attributes','all',0,NULL,'V1'),(241,1,0,NULL,'NA100898',1,0,0,999,'','','product','','Apple','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','iPhone 13 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-09-30 12:15:59',59,NULL,0,'','','','','','',0,'','','','','','2bb4778b-21e8-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2021-09-30 12:16:14','attributes','all',0,NULL,'V1'),(190,26,1,NULL,'',0,1,1,0,'','','product','','','Baseus Power Bank','Baseus Power Bank','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-10-13 12:27:56',62,NULL,0,'','','','','','',0,'','','','','','0b5891df-7d23-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2021-03-05 04:15:16','attributes','all',0,NULL,'V1'),(225,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:27:22',74,NULL,0,'','','','','','',0,'','','','','','757155df-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',10,'','cu','2021-11-08 10:28:33','attributes','all',0,NULL,'V1'),(226,33,0,NULL,'',0,1,0,0,'','','offer_prepaid','','','Prepaid - 2V','Prepaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:28:06',74,NULL,0,'','','','','','',0,'','','','','','8fd2b8f8-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',20,'','cu','2021-11-08 10:29:18','attributes','all',0,NULL,'V1'),(224,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 2V','Postpaid - 2V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:26',74,NULL,0,'','','','','','',0,'','','','','','9ac2d8c3-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cu','2021-11-08 10:29:46','attributes','all',0,NULL,'V1'),(223,33,0,NULL,'',0,1,0,0,'','','offer_postpaid','','','Postpaid - 1V','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2021-11-08 10:30:48',74,NULL,0,'','','','','','',0,'','','','','','b71d802b-407e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cu','2021-11-08 10:30:12','attributes','all',0,NULL,'V1'),(18,7,3,NULL,'NA68832',1,1,0,3,'','','product','','Apple','iPhone 7','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df2763a2-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',48,'mobile','cu','2021-05-04 14:07:43','attributes','all',0,NULL,'V1'),(251,7,3,NULL,'NA99259',1,0,0,999,'','','product','','Apple','iphone 11','iphone 11','iphone 11','iphone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df48e350-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:50:50','attributes','all',0,NULL,'V1'),(250,7,3,NULL,'NA99964',1,0,0,999,'','','product','','Apple','iPhone 12','iPhone 12','iPhone 12','iPhone 12','iPhone 12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df4fbd88-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:13','attributes','all',0,NULL,'V1'),(249,7,3,NULL,'NA100889',1,0,0,999,'','','product','','Apple','iPhone 13','iPhone 13','iPhone 13','iPhone 13','iPhone 13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2021-11-19 11:50:20',56,NULL,0,'','','','','','',0,'','','','','','df58429d-492e-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2021-11-19 11:51:03','attributes','all',0,NULL,'V1'),(168,24,0,NULL,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:47:28',74,NULL,0,'','','','','','',0,'','','','','','90024f0a-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-12-15 13:49:11','attributes','all',0,NULL,'V1'),(135,24,0,NULL,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',92,NULL,0,'','','','','','',0,'','','','','','f0fc7f2c-5dad-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2021-12-15 13:51:12','attributes','all',0,NULL,'V1'),(340,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Premium','Konnecta Postpaid Max Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d66d432-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',24,'','cda','2022-02-21 10:03:23','attributes','all',0,NULL,'V1'),(336,50,17,NULL,'',0,1,0,0,'','','offer_prepaid','','','Konnecta Prepaid Max','Konnecta Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-24 08:02:17',89,NULL,0,'','','','','','',0,'','','','','','709a74cb-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',11,'','cda','2022-02-21 10:04:12','attributes','all',0,NULL,'V1'),(332,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','Konnecta Classic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d6e0827-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-15 16:14:04','attributes','all',0,NULL,'V1'),(334,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','Konnecta Premium','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d5e6537-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',19,'','cda','2022-02-15 16:15:02','attributes','all',0,NULL,'V1'),(333,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','Konnecta Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','3d66919b-8e7a-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',16,'','cda','2022-02-15 16:14:31','attributes','all',0,NULL,'V1'),(331,50,12,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Basic','Konnecta Basic','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:17:08',89,NULL,0,'','','','','','',0,'','','','','','5a7f1988-8e78-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',12,'','cda','2022-02-15 16:00:33','attributes','all',0,NULL,'V1'),(266,11,0,NULL,'',0,0,0,0,'','','product','','Orange','Flybox','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2021-12-30 10:00:30',89,NULL,0,'','','','','','',0,'','','','','','52192130-6957-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2021-12-30 10:01:32','attributes','all',0,NULL,'V1'),(78,14,0,NULL,'NA77252',1,0,0,999,'','','product','','Alcatel','1066G','1066G','1066G','1066G','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2024-02-05 20:44:26',59,NULL,0,'','','','','','',0,'','','','','','3b9b75bb-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 08:26:14','attributes','all',0,NULL,'V1'),(75,14,0,NULL,'NA76751',1,0,0,999,'','','product','','Crosscall','Action X3','Action X3','Action X3','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',74,NULL,0,'','','','','','',0,'','','','','','aa9c9224-7381-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 08:30:03','attributes','all',0,NULL,'V1'),(79,14,39,NULL,'NA99715',1,0,0,999,'','','product','','Alcatel','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','Alcatel 1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','04a677c7-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 08:32:45','attributes','all',0,NULL,'V1'),(80,14,39,NULL,'NA99195',1,0,0,999,'','','product','','Alcatel','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','Alcatel U3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','6f0fac0b-7382-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 08:35:40','attributes','all',0,NULL,'V1'),(163,24,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','1595ce71-7393-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 10:33:43','attributes','all',0,NULL,'V1'),(161,24,0,NULL,'NA79511',1,1,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-09-19 13:26:23',59,NULL,0,'','','','','','',0,'','','','','','f5b85283-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:01','attributes','all',0,NULL,'V1'),(166,24,0,NULL,'NA77252',1,1,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-08-21 12:22:00',59,NULL,0,'','','','','','',0,'','','','','','f5c20176-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(167,24,0,NULL,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-31 07:45:25',74,NULL,0,'','','','','','',0,'','','','','','f5cb5e43-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(139,24,0,NULL,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-08-24 09:49:29',74,NULL,0,'','','','','','',0,'','','','','','f5de9a22-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2022-01-12 13:40:05','attributes','all',0,NULL,'V1'),(140,24,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5e7f0f3-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:12','attributes','all',0,NULL,'V1'),(169,24,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f0e21a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:12','attributes','all',0,NULL,'V1'),(170,24,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f5f9bee5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:17','attributes','all',0,NULL,'V1'),(146,24,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f602e11c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:03','attributes','all',0,NULL,'V1'),(147,24,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f60c0b40-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:11','attributes','all',0,NULL,'V1'),(159,24,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f615364f-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:14','attributes','all',0,NULL,'V1'),(171,24,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6277b5b-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:12','attributes','all',0,NULL,'V1'),(172,24,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f6306227-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0,NULL,'V1'),(173,24,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f63914d9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:55','attributes','all',0,NULL,'V1'),(160,24,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f641bfba-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:42','attributes','all',0,NULL,'V1'),(181,24,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f64a3f6c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:11','attributes','all',0,NULL,'V1'),(174,24,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f652c6c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:23','attributes','all',0,NULL,'V1'),(138,24,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:17',74,NULL,0,'','','','','','',0,'','','','','','f65b382a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(182,24,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f663eb07-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:18','attributes','all',0,NULL,'V1'),(158,24,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f66c4ebf-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:44','attributes','all',0,NULL,'V1'),(156,24,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f674cd49-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:52','attributes','all',0,NULL,'V1'),(157,24,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f67d3dfc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:21','attributes','all',0,NULL,'V1'),(137,24,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f685b91c-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-01-12 13:38:52','attributes','all',0,NULL,'V1'),(136,24,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f68e4766-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:14','attributes','all',0,NULL,'V1'),(184,24,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f696be74-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0,NULL,'V1'),(186,24,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f69f4752-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:08','attributes','all',0,NULL,'V1'),(141,24,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6a7e231-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:51','attributes','all',0,NULL,'V1'),(142,24,0,NULL,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-02-06 09:16:46',74,NULL,0,'','','','','','',0,'','','','','','f6b0aa50-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(151,24,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6b96303-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:38:56','attributes','all',0,NULL,'V1'),(183,24,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6c1fd6e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:41','attributes','all',0,NULL,'V1'),(164,24,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6cab4b9-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0,NULL,'V1'),(175,24,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:18',74,NULL,0,'','','','','','',0,'','','','','','f6d37761-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:50','attributes','all',0,NULL,'V1'),(176,24,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6dc4270-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:26','attributes','all',0,NULL,'V1'),(185,24,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6e52400-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:51','attributes','all',0,NULL,'V1'),(152,24,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6edcc26-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:44','attributes','all',0,NULL,'V1'),(187,24,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6f687c6-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:27','attributes','all',0,NULL,'V1'),(148,24,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f6ff3783-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:56','attributes','all',0,NULL,'V1'),(143,24,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f707d4a7-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:58','attributes','all',0,NULL,'V1'),(144,24,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7108112-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:26','attributes','all',0,NULL,'V1'),(165,24,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f71935e4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:38:59','attributes','all',0,NULL,'V1'),(162,24,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f7223409-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-01-12 13:40:08','attributes','all',0,NULL,'V1'),(177,24,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f733ed2e-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:40:00','attributes','all',0,NULL,'V1'),(178,24,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f73ca2db-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:40:02','attributes','all',0,NULL,'V1'),(155,24,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:19',74,NULL,0,'','','','','','',0,'','','','','','f74568c0-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:34','attributes','all',0,NULL,'V1'),(145,24,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f74e554a-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:57','attributes','all',0,NULL,'V1'),(134,24,0,NULL,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-29 13:34:58',74,NULL,0,'','','','','','',0,'','','','','','f75745a5-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-12 13:38:46','attributes','all',0,NULL,'V1'),(188,24,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7606092-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-01-12 13:38:48','attributes','all',0,NULL,'V1'),(179,24,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7693297-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-01-12 13:39:24','attributes','all',0,NULL,'V1'),(180,24,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f771e0c4-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:57','attributes','all',0,NULL,'V1'),(153,24,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f77a8f29-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-01-12 13:40:17','attributes','all',0,NULL,'V1'),(154,24,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78351cc-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:20','attributes','all',0,NULL,'V1'),(189,24,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f78c0a04-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-01-12 13:39:43','attributes','all',0,NULL,'V1'),(150,24,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f7950589-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:39:39','attributes','all',0,NULL,'V1'),(149,24,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-05-03 15:35:20',74,NULL,0,'','','','','','',0,'','','','','','f79de0ee-73ac-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-01-12 13:38:49','attributes','all',0,NULL,'V1'),(243,1,10,NULL,'NA99955',1,0,0,999,'','','product','','Orange','Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','Orange Sanza style','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-01-20 12:55:57',59,NULL,0,'','','','','','',0,'','','','','','4f939f5b-79f0-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',7,'mobile','cu','2022-01-20 12:56:43','attributes','all',0,NULL,'V1'),(200,18,0,NULL,'',0,1,1,4,'','','offer_prepaid','','','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','Telenor - Monthly Plus Bundle','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-01-28 06:16:03',85,NULL,0,'','','','','','',0,'','','','','','1242e8e0-7d19-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',9,'','cu','2021-03-06 12:41:25','attributes','all',0,NULL,'V1'),(339,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Prestige','Konnecta Postpaid Max Prestige','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d6eecab-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',15,'','cda','2022-02-21 10:04:12','attributes','all',0,NULL,'V1'),(338,50,16,NULL,'',0,1,0,0,'','','offer_postpaid','','','Konnecta Postpaid Max Standard','Konnecta Postpaid Max Standard','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:48',89,NULL,0,'','','','','','',0,'','','','','','7d76e45b-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',13,'','cda','2022-02-21 10:04:50','attributes','all',0,NULL,'V1'),(335,1,0,NULL,'NA101009',1,0,0,999,'','','product','','Samsung','Galaxy S22','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','Galaxy S22 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:41:05',84,NULL,0,'','','','','','',0,'','','','','','d63fd194-9319-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',21,'mobile','cu','2022-02-21 13:27:38','attributes','all',0,NULL,'V1'),(341,1,8,NULL,'NA101276',1,0,0,999,'','','product','','Samsung','Galaxy A13','Galaxy A13','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','Galaxy A13 5G - 4GB-128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:33:31',84,NULL,0,'','','','','','',0,'','','','','','19c3dcbe-93ec-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',25,'mobile','cu','2022-02-22 14:31:33','attributes','all',0,NULL,'V1'),(337,50,18,NULL,'',0,1,0,0,'','','offer_prepaid','','','Unlimited Prepaid Max','Unlimited Prepaid Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-02-23 17:16:39',89,NULL,0,'','','','','','',0,'','','','','','70a25627-92fd-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-02-21 10:03:57','attributes','all',0,NULL,'V1'),(342,1,8,NULL,'NA100838',1,0,0,999,'','','product','','Samsung','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','Galaxy A03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,84,'2022-02-24 09:14:21',84,NULL,0,'','','','','','',0,'','','','','','26c45a7a-9552-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',17,'mobile','cu','2022-02-24 09:15:40','attributes','all',0,NULL,'V1'),(349,7,21,NULL,'',0,1,0,0,'','','product','','Orange','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,89,'2022-05-05 08:09:15',59,NULL,0,'','','','','','',0,'','','','','','15f5729a-c566-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-04-26 13:38:57','attributes','all',0,NULL,'V1'),(294,51,0,0,'NA79511',1,0,0,1,'','','product','','Alcatel','1','1 (NFC Single SIM)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a42f9a42-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:20:53','attributes','all',0,NULL,'V1'),(299,51,0,0,'NA77252',1,0,0,2,'','','product','','Alcatel','1066','1066G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a43b2608-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:42','attributes','all',0,NULL,'V1'),(300,51,0,0,'NA75031',1,0,0,3,'','','product','','Alcatel','U3','U3 4G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:22',74,NULL,0,'','','','','','',0,'','','','','','a4464695-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:35','attributes','all',0,NULL,'V1'),(301,51,0,0,'NA68870',1,0,0,4,'','','product','','Apple','iPhone 6s','iPhone 6s 16GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45175ce-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(272,51,0,0,'NA68832',1,0,0,5,'','','product','','Apple','iPhone 7','iPhone 7 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a45cde96-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:23','attributes','all',0,NULL,'V1'),(273,51,0,0,'NA77753',1,0,0,6,'','','product','','Apple','iPhone X','iPhone X 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a46824aa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(302,51,0,0,'NA99590',1,0,0,7,'','','product','','Apple','iPhone XS','iPhone XS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4730519-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(303,51,0,0,'NA86071',1,0,0,8,'','','product','','Apple','iPhone XS Max','iPhone XS Max 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a47df9fa-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:29','attributes','all',0,NULL,'V1'),(279,51,0,0,'NA99259',1,0,0,9,'','','product','','Apple','iPhone 11','iphone 11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4892058-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:07','attributes','all',0,NULL,'V1'),(280,51,0,0,'NA99264',1,0,0,10,'','','product','','Apple','iPhone 11 Pro','iPhone 11 Pro','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4949a9b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:17','attributes','all',0,NULL,'V1'),(292,51,0,0,'NA99266',1,0,0,11,'','','product','','Apple','iPhone 11 Pro Max','iPhone 11 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a49ee3ba-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:31','attributes','all',0,NULL,'V1'),(268,51,0,0,'NA86093',1,0,0,12,'','','product','','Apple','iPhone XR Test','iPhone XR 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4a97c46-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:57','attributes','all',0,NULL,'V1'),(304,51,0,0,'NA76751',1,0,0,13,'','','product','','Crosscall','Action X3','Action X3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4b3fb76-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0,NULL,'V1'),(305,51,0,0,'NA70090',1,0,0,14,'','','product','','Huawei','MediaPad T3 10','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4bdf2f5-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0,NULL,'V1'),(306,51,0,0,'NA85531',1,0,0,15,'','','product','','Huawei','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4c7f700-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:22','attributes','all',0,NULL,'V1'),(293,51,0,0,'NA73732',1,0,0,16,'','','product','','Itel','IT2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4d20694-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:15','attributes','all',0,NULL,'V1'),(314,51,0,0,'NA99062',1,0,0,17,'','','product','','Itel','IT2132','it2132','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:23',74,NULL,0,'','','','','','',0,'','','','','','a4dbee29-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(307,51,0,0,'NA85691',1,0,0,18,'','','product','','Itel','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4e5c9be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:35','attributes','all',0,NULL,'V1'),(271,51,0,0,'NA96411',1,0,0,19,'','','product','','Itel','MC20','MC20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4f03c16-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:03','attributes','all',0,NULL,'V1'),(315,51,0,0,'NA84092',1,0,0,20,'','','product','','Mobiwire','AX2408','AX2408','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a4fa3ceb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:25','attributes','all',0,NULL,'V1'),(291,51,0,0,'NA76811',1,0,0,21,'','','product','','Orange','Rise 53','Rise 53','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5043653-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:16','attributes','all',0,NULL,'V1'),(289,51,0,0,'NA97811',1,0,0,22,'','','product','','Orange','Rise 55','Orange Rise 55 (Maxcom MS514)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a50e1dc0-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:55','attributes','all',0,NULL,'V1'),(290,51,0,0,'NA84071',1,0,0,23,'','','product','','Orange','Mahpee','Mahpee','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5186534-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(270,51,0,0,'NA85811',1,0,0,24,'','','product','','Orange','Sanza','Orange Sanza','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5225ef8-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:21:41','attributes','all',0,NULL,'V1'),(269,51,0,0,'NA99210',1,0,0,25,'','','product','','Orange','Sanza 2','Sanza 2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a52c65e7-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:01','attributes','all',0,NULL,'V1'),(317,51,0,0,'NA99508',1,0,0,26,'','','product','','Orange','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5367510-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:45','attributes','all',0,NULL,'V1'),(319,51,0,0,'NA99064',1,0,0,27,'','','product','','Orange','Sanza XL','Sanza XL','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a5405250-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:47','attributes','all',0,NULL,'V1'),(274,51,0,0,'NA99730',1,0,0,28,'','','product','','Samsung','Galaxy A01','MEA only - A01 - 32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a54a46bf-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:57','attributes','all',0,NULL,'V1'),(275,51,0,0,'NA99224',1,0,0,29,'','','product','','Samsung','Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a55c44a9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:25','attributes','all',0,NULL,'V1'),(284,51,0,0,'NA99128',1,0,0,30,'','','product','','Samsung','Galaxy A2 Core','AMEA only - A2 Core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a566ee8a-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:46','attributes','all',0,NULL,'V1'),(316,51,0,0,'NA99960',1,0,0,31,'','','product','','Samsung','Galaxy A3 core','Galaxy A3 core','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:24',74,NULL,0,'','','','','','',0,'','','','','','a57172f3-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:43','attributes','all',0,NULL,'V1'),(297,51,0,0,'NA99374',1,0,0,32,'','','product','','Samsung','Galaxy A11','MEA only - A11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a57c4b4f-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:46','attributes','all',0,NULL,'V1'),(308,51,0,0,'NA99129',1,0,0,33,'','','product','','Samsung','Galaxy A20','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a58703dd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:26','attributes','all',0,NULL,'V1'),(309,51,0,0,'NA99225',1,0,0,34,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59176ad-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:29','attributes','all',0,NULL,'V1'),(318,51,0,0,'NA99662',1,0,0,35,'','','product','','Samsung','Galaxy A21s','SM-A217F - Galaxy A21s - 4GB 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a59bce97-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:52','attributes','all',0,NULL,'V1'),(285,51,0,0,'NA99197',1,0,0,36,'','','product','','Samsung','Galaxy A30s','SM-A307F - Galaxy A30s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5a5de39-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:47','attributes','all',0,NULL,'V1'),(320,51,0,0,'NA99736',1,0,0,37,'','','product','','Samsung','Galaxy A31','SM-A315G - Galaxy A31 - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5afeab1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:20:42','attributes','all',0,NULL,'V1'),(281,51,0,0,'NA99212',1,0,0,38,'','','product','','Samsung','Galaxy A50','SM-A505FN - Galaxy A50','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5b9f0be-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:06','attributes','all',0,NULL,'V1'),(276,51,0,0,'NA99307',1,0,0,39,'','','product','','Samsung','Galaxy A51','Galaxy A51','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5c419f1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:20:26','attributes','all',0,NULL,'V1'),(277,51,0,0,'NA99308',1,0,0,40,'','','product','','Samsung','Galaxy A71','Galaxy A71','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ce4b7b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:05','attributes','all',0,NULL,'V1'),(298,51,0,0,'NA99378',1,0,0,41,'','','product','','Samsung','Galaxy M11','MEA only - M11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5d8626e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:22','attributes','all',0,NULL,'V1'),(295,51,0,0,'',0,0,0,42,'','','product','','Samsung','Galaxy Note 20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5e347fb-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-03 10:21:54','attributes','all',0,NULL,'V1'),(296,51,0,0,'NA99975',1,0,0,43,'','','product','','Samsung','Galaxy Note 20 Ultra','Note 20 Ultra MSU','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5ed9c24-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:24','attributes','all',0,NULL,'V1'),(310,51,0,0,'NA97291',1,0,0,44,'','','product','','Samsung','Galaxy S10','SM-G973F - Galaxy S10 - 512GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a5f81fcd-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:38','attributes','all',0,NULL,'V1'),(311,51,0,0,'NA97293',1,0,0,45,'','','product','','Samsung','Galaxy S10+','SM-G975F - Galaxy S10+ 1TB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a602846e-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:51','attributes','all',0,NULL,'V1'),(288,51,0,0,'NA99367',1,0,0,46,'','','product','','Samsung','Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:25',74,NULL,0,'','','','','','',0,'','','','','','a60cdc45-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(278,51,0,0,'NA99526',1,0,0,47,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a61727ea-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:52','attributes','all',0,NULL,'V1'),(267,51,0,0,'NA99371',1,0,0,48,'','','product','','Samsung','Galaxy S20 Ultra','SM-G988B - Galaxy S20 Ultra','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6215be9-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',5,'mobile','cu','2022-05-03 10:22:05','attributes','all',0,NULL,'V1'),(321,51,0,0,'',0,0,0,49,'','','product','','Samsung','Galaxy Z Flip','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a62bd425-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2022-05-03 10:20:47','attributes','all',0,NULL,'V1'),(312,51,0,0,'',0,0,0,50,'','','product','','Tecno','DroidPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a63615d1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-05-03 10:20:45','attributes','all',0,NULL,'V1'),(313,51,0,0,'NA96431',1,0,0,51,'','','product','','Tecno','N11','N11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64006b1-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:37','attributes','all',0,NULL,'V1'),(286,51,0,0,'NA76351',1,0,0,52,'','','product','','Tecno','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a64a3e6b-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-03 10:21:59','attributes','all',0,NULL,'V1'),(287,51,0,0,'NA80112',1,0,0,53,'','','product','','Tecno','R6+','R6+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a6543d18-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:21:41','attributes','all',0,NULL,'V1'),(322,51,0,0,'NA99294',1,0,0,54,'','','product','','Tecno','R7+','R7+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a65e5e92-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-03 10:20:30','attributes','all',0,NULL,'V1'),(283,51,0,0,'NA71191',1,0,0,55,'','','product','','Wiko','Sunny','SUNNY','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a668a392-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:21:26','attributes','all',0,NULL,'V1'),(282,51,0,0,'NA79491',1,0,0,56,'','','product','','Wiko','Tommy3','TOMMY3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-05-03 10:20:26',74,NULL,0,'','','','','','',0,'','','','','','a672ac3d-caca-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',2,'mobile','cu','2022-05-03 10:22:05','attributes','all',0,NULL,'V1'),(255,49,0,NULL,'NA68012',1,0,0,1,'','','product','','Samsung','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','AMEA only - Galaxy Grand Prime Plus DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-08-21 12:18:52',92,NULL,0,'','','','','','',0,'','','','','','ad543c1d-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:35:44','attributes','all',0,NULL,'V1'),(256,49,0,NULL,'NA57406',1,0,0,2,'','','product','','Samsung','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','AMEA only - SM-E500H - Galaxy E5 3G','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad5e2e59-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:19','attributes','all',0,NULL,'V1'),(257,49,0,NULL,'NA69997',1,0,0,3,'','','product','','Samsung','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','AMEA only - SM-G610FD - Galaxy J7 Prime DS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad67cea7-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-05-03 15:36:44','attributes','all',0,NULL,'V1'),(258,49,0,NULL,'NA63614',1,0,0,4,'','','product','','Samsung','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','SM-T580 - Galaxy Tab A 10.1 (2016) WiFi','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,'','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','',NULL,'',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-05-03 15:35:36',92,NULL,0,'','','','','','',0,'','','','','','ad719209-caf6-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-05-03 15:36:11','attributes','all',0,NULL,'V1'),(352,14,0,NULL,'NA99508',1,0,0,999,'','','product','','Orange','Sanza touch','Sanza touch','Sanza touch','Sanza touch','Sanza touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-10-05 08:07:55',99,NULL,0,'','','','','','',0,'','','','','','4b3a7d19-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-05-04 15:03:50','attributes','all',0,NULL,'V1'),(351,14,39,NULL,'NA100175',1,0,0,999,'','','product','','Alcatel','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','Alcatel 1 NEO 2021','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:02',59,NULL,0,'','','','','','',0,'','','','','','4b44cd56-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',3,'mobile','cu','2022-05-04 15:04:24','attributes','all',0,NULL,'V1'),(350,14,39,NULL,'',0,0,0,0,'','','product','','Pack','Alcatel Neo + Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-07-21 20:14:03',59,NULL,0,'','','','','','',0,'','','','','','d3d8d6f9-cbbb-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-04 15:08:26','attributes','all',0,NULL,'V1'),(353,7,0,NULL,'',0,1,0,0,'','','product','','Pack','Alcatel Neo 1 + Orange Sanza Touch','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:48',59,NULL,0,'','','','','','',0,'','','','','','f86c0e85-cc49-11ec-8636-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-05-05 08:04:55','attributes','all',0,NULL,'V1'),(356,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-07-28 13:18:45',92,NULL,0,'','','','','','',0,'','','','','','cb2209e3-0288-11ed-8636-fa163ed11cf5',NULL,NULL,'','','','','',4,'','cda','2022-07-13 08:51:08','attributes','all',0,NULL,'V1'),(357,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:19:17',92,NULL,0,'','','','','','',0,'','','','','','bb196cf0-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-07-25 12:39:59','attributes','all',0,NULL,'V1'),(358,63,27,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-05-24 13:52:14',106,NULL,0,'','','','','','',0,'','','','','','db9f50da-0c16-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',14,'','cda','2022-07-25 12:40:32','attributes','all',0,NULL,'V1'),(360,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:25',92,NULL,0,'','','','','','',0,'','','','','','05a12f65-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:42:05','attributes','all',0,NULL,'V1'),(359,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:23',92,NULL,0,'','','','','','',0,'','','','','','05aaac7e-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:42:25','attributes','all',0,NULL,'V1'),(362,63,29,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2022-07-28 13:23:18',92,NULL,0,'','','','','','',0,'','','','','','05b3caaa-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-07-25 12:41:52','attributes','all',0,NULL,'V1'),(361,63,28,NULL,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,92,'2023-03-13 14:04:24',92,NULL,0,'','','','','','',0,'','','','','','05bcdf80-0c17-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-07-25 12:41:19','attributes','all',0,NULL,'V1'),(364,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-01-31 17:13:38',74,NULL,0,'','','','','','',0,'','','','','','71ba0605-1331-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-03 13:38:03','attributes','all',0,NULL,'V1'),(71,14,0,NULL,'NA97011',1,0,0,999,'','','product','','Samsung','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','Galaxy S10e (128GB)','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c2f0301-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:06','attributes','all',0,NULL,'V1'),(83,14,0,NULL,'NA73732',1,0,0,999,'','','product','','Itel','it2130','it2130','it2130','it2130','it2130','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c397d4e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:56','attributes','all',0,NULL,'V1'),(411,80,51,NULL,'NA99972',1,1,1,5,'','','product','','Apple','FR | iPhone 12 Pro Max','EN | iPhone 12 Pro Max','iPhone 12 Pro Max','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 14:48:18',115,NULL,0,'','','','','','',0,'','','','','','4d2f7201-c53d-4306-a303-dbe451631c32',NULL,NULL,'','','','','phonedir_oxygen',23,'mobile','cdd','2023-11-17 14:49:25','attributes','all',0,NULL,'V1'),(82,14,0,NULL,'NA85691',1,0,0,999,'','','product','','Itel','MC10','MC10','MC10','MC10','MC10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:47',0,NULL,0,'','','','','','',0,'','','','','','4c4de382-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:12','attributes','all',0,NULL,'V1'),(69,14,0,NULL,'NA99526',1,0,0,999,'','','product','','Samsung','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','SM-G985F - Galaxy S20+ - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c5810d9-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:16','attributes','all',0,NULL,'V1'),(81,14,0,NULL,'NA76351',1,0,0,999,'','','product','','Tecno','NX','NX','NX','NX','NX','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c628373-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:46','attributes','all',0,NULL,'V1'),(68,14,0,NULL,'NA99525',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','SM-G980F - Galaxy S20 - EE - 128GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c6cbb12-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:49','attributes','all',0,NULL,'V1'),(67,14,0,NULL,'NA69131',1,0,0,999,'','','product','','Tecno','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','DroiPad 10D','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c81f304-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'Tablet','cu','2022-08-12 07:58:02','attributes','all',0,NULL,'V1'),(77,14,0,NULL,'NA70090',1,0,0,999,'','','product','','Huawei','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','MediaPad T3 10 LTE','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c8c14a7-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0,NULL,'V1'),(66,14,0,NULL,'NA86072',1,0,0,999,'','','product','','Apple','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','iPhone XS Max 256GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4c988c18-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:56','attributes','all',0,NULL,'V1'),(76,14,0,NULL,'NA85531',1,0,0,999,'','','product','','Huawei','P30','P30','P30','P30','P30','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ca22689-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:31','attributes','all',0,NULL,'V1'),(65,14,0,NULL,'NA86031',1,0,0,999,'','','product','','Apple','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','iPhone XS 64GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2023-10-05 08:07:07',99,NULL,0,'','','','','','',0,'','','','','','4cabf40e-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',4,'mobile','cu','2022-08-12 07:57:30','attributes','all',0,NULL,'V1'),(74,14,0,NULL,'NA99367',1,0,0,999,'','','product','','Samsung','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','SM-G980F - Galaxy S20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cc12cd0-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:58:14','attributes','all',0,NULL,'V1'),(73,14,0,NULL,'NA99129',1,0,0,999,'','','product','','Samsung','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','AMEA only - SM-A202F - Galaxy A20 - 3GB-32GB','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4ccec63d-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:56:58','attributes','all',0,NULL,'V1'),(72,14,0,NULL,'NA99225',1,0,0,999,'','','product','','Samsung','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','Galaxy A20s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,56,'2022-08-12 07:56:48',0,NULL,0,'','','','','','',0,'','','','','','4cd7a638-1a14-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-08-12 07:57:45','attributes','all',0,NULL,'V1'),(371,65,0,0,'',0,0,0,0,'','','offer_prepaid','','','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:04',74,NULL,0,'','','','','','',0,'','','','','','c8df59a9-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cda','2022-08-29 08:23:07','attributes','all',0,NULL,'V1'),(366,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A2','Prepqid - 2V A2','Prepqid - 2V A2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d31b5354-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',7,'','cda','2022-08-29 08:23:36','attributes','all',0,NULL,'V1'),(365,65,40,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - A1','Prepaid - 2V - A1','Prepaid - 2V - A1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:13',74,NULL,0,'','','','','','',0,'','','','','','d324da98-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2022-08-29 08:24:19','attributes','all',0,NULL,'V1'),(369,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B3','Prepaid - 2V - B3','Prepaid - 2V - B3','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da820a50-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:30','attributes','all',0,NULL,'V1'),(368,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B2','Prepaid - 2V - B2','Prepaid - 2V - B2','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:25',74,NULL,0,'','','','','','',0,'','','','','','da8bed01-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:24:04','attributes','all',0,NULL,'V1'),(367,65,41,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - B1','Prepaid - 2V - B1','Prepaid - 2V - B1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:26',74,NULL,0,'','','','','','',0,'','','','','','da954ca2-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-08-29 08:23:50','attributes','all',0,NULL,'V1'),(370,65,42,0,'',0,0,0,0,'','','offer_prepaid','','','Prepaid - 2V - C1','Prepaid - 2V - C1','Prepaid - 2V - C1','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2022-08-29 08:23:38',74,NULL,0,'','','','','','',0,'','','','','','e1bf8e55-2773-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',6,'','cda','2022-08-29 08:24:55','attributes','all',0,NULL,'V1'),(355,59,25,NULL,'',0,1,1,0,'','','product','','Xiaomi','Pad 5','Pad 5','AR','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,62,'2022-09-07 05:59:46',62,NULL,0,'','','','','','',0,'','','','','','46b0f37b-2e72-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-09-07 06:00:49','attributes','all',0,NULL,'V1'),(372,63,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Card2wallet','Card2wallet','Card2wallet','Card2wallet','Card2wallet','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2022-11-21 20:39:02',59,NULL,0,'','','','','','',0,'','','','','','f67b81a7-69db-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',5,'','cda','2022-11-21 20:40:23','attributes','all',0,NULL,'V1'),(217,7,0,NULL,'NA99224',1,0,0,999,'','','product','','Samsung','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','AMEA only - Galaxy A10s','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-04-17 08:42:46',0,NULL,0,'','','','','','',0,'','','','','','7d73f3cf-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',1,'mobile','cu','2022-12-13 13:24:01','attributes','all',0,NULL,'V1'),(382,71,0,NULL,'',0,0,0,0,'','','offer_postpaid','','','sellecta test','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,59,'2023-01-03 15:28:02',59,NULL,0,'','','','','','',0,'','','','','','31e16bed-8b7b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2023-01-03 15:29:26','attributes','all',0,NULL,'V1'),(387,73,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Akama Ral A','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,109,'2023-02-14 13:31:58',109,NULL,0,'','','','','','',0,'','','','','','e0ab0892-ac6b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',2,'','cu','2023-02-14 13:32:13','attributes','all',0,NULL,'V1'),(383,24,0,NULL,'',0,0,0,0,'','','product','','Apple','Airtime','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,74,'2023-01-31 13:39:50',74,NULL,0,'','','','','','',0,'','','','','','b35d8267-a16c-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','cda','2023-01-31 13:39:59','attributes','all',0,NULL,'V1'),(386,73,0,NULL,'',0,0,0,0,'','','offer_prepaid','','','Akama','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,108,'2023-02-14 13:50:38',108,NULL,0,'','','','','','',0,'','','','','','c23cf0ab-ac6b-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',3,'','pd','2023-02-14 13:50:59','attributes','all',0,NULL,'V1'),(24,7,0,NULL,'NA79551',1,1,0,7,'','','product','','Samsung','Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','SM-A600FN - Galaxy A6','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-04-17 08:42:43',82,NULL,0,'','','','','','',0,'','','','','','3806c3a0-ed26-11ea-a30c-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',6,'mobile','cu','2021-05-04 14:08:20','attributes','all',0,NULL,'V1'),(402,87,0,NULL,'',0,1,1,0,'','','product','','Incgo','Pressure Washer - 200 Bar','Pressure Washer - 200 Bar','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 05:54:41',115,NULL,0,'','','','','','',0,'','','','','','e6cadeef-0630-44af-a61f-208df50958e2',NULL,NULL,'','','','','',20,'','cda','2023-09-13 12:24:33','attributes','all',0,NULL,'V1'),(401,87,0,NULL,'',0,1,1,0,'','','product','','Formula 1','Car Wax','Car Wax','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 05:54:42',115,NULL,0,'','','','','','',0,'','','','','','1db09eb3-0f9d-41bc-8b36-969962985cdd',NULL,NULL,'','','','','',7,'','cda','2023-09-13 12:27:32','attributes','all',0,NULL,'V1'),(404,84,0,NULL,'',0,1,1,0,'','','product','','','Osram Projector','Osram Projector','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 10:28:03',115,NULL,0,'','','','','','',0,'','','','','','5a26aee8-2573-4b56-a5ba-c262367b53aa',NULL,NULL,'','','','','',11,'','cda','2023-09-14 06:10:46','attributes','all',0,NULL,'V1'),(403,84,0,NULL,'',0,1,1,0,'','','product','','','Osram LED','Osram LED','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-11-17 10:28:05',85,NULL,0,'','','','','','',0,'','','','','','7c70620b-2655-40d0-8c28-91c88f887fb6',NULL,NULL,'','','','','',10,'','cda','2023-09-14 06:09:30','attributes','all',0,NULL,'V1'),(461,77,0,NULL,'',0,1,1,0,'','','product','','','City OEM Alloy','City OEM Alloy','سبائك المدينة','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:26:19',115,NULL,0,'','','','','','',0,'','','','','','5cf9b13e-479d-4044-8d3e-93936dfbcb54',NULL,NULL,'','','','','',12,'','cda','2023-09-14 06:26:55','attributes','all',0,NULL,'V1'),(460,77,0,NULL,'',0,1,1,0,'','','product','','','Civic OEM Alloy','Civic OEM Alloy','Civic OEM Alloy','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:26:21',115,NULL,0,'','','','','','',0,'','','','','','3974d70b-fec5-43ad-b096-7ee42b2e1127',NULL,NULL,'','','','','',6,'','cda','2023-09-14 06:27:07','attributes','all',0,NULL,'V1'),(407,85,56,NULL,'',0,1,1,0,'','','product','','MG Motors','MG ZS Exclusive','MG ZS Exclusive','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:21',115,NULL,0,'','','','','','',0,'','','','','','ab913676-8438-43e2-b3a5-9e0fc621c324',NULL,NULL,'','','','','',6,'','cda','2023-09-14 06:32:14','attributes','all',0,NULL,'V1'),(419,85,57,0,'',0,1,1,0,'','','product','','','Toyota Corolla','Toyota Corolla','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:53',119,NULL,0,'','','','','','',0,'','','','','','00c43ec9-5cdc-49c4-b24d-fb00fec6e9a0',NULL,NULL,'','','','','',9,'','cda','2023-09-14 06:32:31','attributes','all',0,NULL,'V1'),(418,85,57,0,'',0,1,1,0,'','','product','','MG Motors','MG ZS Excite','MG ZS Excite','MG ZS','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,119,'2023-09-14 06:31:56',119,NULL,0,'','','','','','',0,'','','','','','692c63d0-b0ce-45d9-a042-31881bb515be',NULL,NULL,'','','','','',28,'','cda','2023-09-14 06:33:08','attributes','all',0,NULL,'V1'),(533,104,75,NULL,'',0,0,0,0,'','','product','','','3124312','3124312','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,1,1,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,115,'2023-10-25 07:03:01',115,NULL,0,'','','','','','',0,'','','','','','80439e9e-7304-11ee-a9d6-fa163ed11cf5',NULL,NULL,'','','','','',1,'','cda','2023-10-25 07:03:30','attributes','all',0,NULL,'V1'),(40,12,0,NULL,'NA99368',1,1,0,999,'','','product','','Samsung','Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','SM-G985F - Galaxy S20+','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',NULL,0,0,'','',0,0,1,0,0,'00,15,30,45','','','',0,0,'no','','','','','','','','','','',0,0,0,0,1,'2023-11-17 16:13:35',59,NULL,0,'','','','','','',0,'','','','','','7d73b2d0-2dbf-11ed-a9d6-fa163ed11cf5',NULL,NULL,'','','','','phonedir_oxygen',8,'mobile','cu','2021-05-28 14:18:22','attributes','all',0,NULL,'V1');
/*!40000 ALTER TABLE `products_v_1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotions` (
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
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Table structure for table `quantitylimits`
--

DROP TABLE IF EXISTS `quantitylimits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quantitylimits` (
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
-- Dumping data for table `quantitylimits`
--

LOCK TABLES `quantitylimits` WRITE;
/*!40000 ALTER TABLE `quantitylimits` DISABLE KEYS */;
/*!40000 ALTER TABLE `quantitylimits` ENABLE KEYS */;
UNLOCK TABLES;

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
  PRIMARY KEY (`ptype`,`id`)
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
-- Table structure for table `subsidies`
--

DROP TABLE IF EXISTS `subsidies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subsidies` (
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
-- Dumping data for table `subsidies`
--

LOCK TABLES `subsidies` WRITE;
/*!40000 ALTER TABLE `subsidies` DISABLE KEYS */;
/*!40000 ALTER TABLE `subsidies` ENABLE KEYS */;
UNLOCK TABLES;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-05 20:21:56
