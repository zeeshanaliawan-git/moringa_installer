update dev_commons.config set val = '4.1.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.1.0.1' where code = 'CSS_JS_VERSION';

-------------------Mahin start 18 May 2023 --------------------

CREATE TABLE dev_commons.access_tokens (
  `token` varchar(255) NOT NULL,
  `api_key` varchar(100) NOT NULL,
  `issue_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expiration` datetime NOT NULL DEFAULT (current_timestamp() + interval 30 minute),
  `api_id` varchar(100) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

CREATE TABLE dev_commons.api_keys (
  `id` varchar(100) NOT NULL DEFAULT '',
  `key` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL DEFAULT '',
  `is_prod` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`key`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

CREATE TABLE idcheck_doc_capture_conf (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcheck_iframe_conf_id INT NOT NULL,
    capture_code VARCHAR(255) NOT NULL,
    doc_type VARCHAR(255),
    optional TINYINT(1) NOT NULL DEFAULT 0,
    verso_handling ENUM('DEFAULT', 'MANDATORY', 'OPTIONAL'),
    liveness_ref_location ENUM('ONBOARDING', 'CIS'),
    liveness_ref_value VARCHAR(255),
    with_doc_liveness TINYINT(1) NOT NULL DEFAULT 0,
    liveness_label VARCHAR(255),
    liveness_description VARCHAR(255),
    UNIQUE (capture_code, idcheck_iframe_conf_id)
);


CREATE TABLE idcheck_iframe_conf (
    id INT(10) AUTO_INCREMENT PRIMARY KEY,
    site_id INT(10) UNIQUE NOT NULL,
    success_redirect_url VARCHAR(255),
    error_redirect_url VARCHAR(255),
    auto_redirect TINYINT(1) NOT NULL DEFAULT 0,
    notification_type ENUM('EMAIL', 'PHONE', 'NONE'),
    notification_value VARCHAR(255),
    realm VARCHAR(255),
    fileUid VARCHAR(255),
    file_launch_check TINYINT(1) NOT NULL DEFAULT 0,
    file_check_wait TINYINT(1) NOT NULL DEFAULT 0,
    file_tags VARCHAR(255),
    ident_code VARCHAR(255),
    iframe_display TINYINT(1) NOT NULL DEFAULT 0,
    iframe_redirect_parent TINYINT(1) NOT NULL DEFAULT 0,
    biometric_consent TINYINT(1) NOT NULL DEFAULT 0,
    legal_hide_link TINYINT(1) NOT NULL DEFAULT 0,
    legal_external_link VARCHAR(255),
    iframe_capt_mode_desk ENUM('CAMERA', 'UPLOAD', 'PROMPT'), 
    iframe_capt_mode_mob ENUM('CAMERA', 'UPLOAD', 'PROMPT') 
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-------------------Mahin end 18 May 2023 --------------------
