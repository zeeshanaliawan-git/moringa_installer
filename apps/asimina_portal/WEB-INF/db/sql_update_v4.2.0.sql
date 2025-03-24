----------------- 26/06/2023 MAHIN -----------------

INSERT INTO config(`code`,`val`) 
VALUES 
  ("IDCHECK_TEST_END_POINT","https://sdkweb-test.idcheck.io/rest/v1/idcheckio-sdk-web/"),
  ("IDCHECK_TEST_GET_TOKEN_END_POINT","https://api-test.ariadnext.com/auth/realms/customer-identity/protocol/openid-connect/token"),
  ("IDCHECK_PROD_END_POINT","https://sdkweb.idcheck.ariadnext.io/rest/v1/idcheckio-sdk-web/"),
  ("IDCHECK_PROD_GET_TOKEN_END_POINT","https://api.idcheck.ariadnext.io/auth/realms/customer-identity/protocol/openid-connect/token"),
  ("IDCHECK_GRANT_TYPE","password"),
  ("IDCHECK_CLIENT_ID","cis-api-client"),
  ("IDCHECK_USERNAME","orange@ariadnext.com"),
  ("IDCHECK_PASSWORD","S0gv8U*lWxTD"),
  ("IDCHECK_BROKER","orange");

CREATE TABLE idcheck_access_tokens (
  `token` varchar(255) NOT NULL,
  `access_token` text NOT NULL,
  `access_token_expires_in` datetime NOT NULL,
  `refresh_token` text NOT NULL,
  `refresh_token_expires_in` datetime NOT NULL,
  `token_type` varchar(100) NOT NULL,
  `link_sent` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `idcheck_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `is_active` tinyint(1) NOT NULL default 0,
  `site_id` int(10) UNSIGNED NOT NULL,
  `path_name` varchar(20) NOT NULL,
  `support_email` varchar(100) NULL,
  `link_validity` varchar(100) NULL,
  `email_sender_name` varchar(30) NULL,
  `block_upload` tinyint(1) NOT NULL DEFAULT 0,
  `capture_desktop` ENUM("CAMERA","PROMPT","UPLOAD") DEFAULT NULL,
  `capture_mobile` ENUM("CAMERA","PROMPT","UPLOAD") DEFAULT NULL,
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
  `head_logo_align` ENUM("LEFT","RIGHT","CENTER") DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uc_site` (`site_id`),
  UNIQUE KEY `uc_code` (`code`,`site_id`)
) ENGINE=MyISAM CHARSET=utf8;


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
) ENGINE=MyISAM CHARSET=utf8;

----------------------------------------------------