CREATE TABLE  `form_result_fields_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `form_search_fields_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(36) NOT NULL,
  `field_id` varchar(36) NOT NULL,
  `show_range` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_name` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `mails_unpublished` (
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

CREATE TABLE  `mail_config_unpublished` (
  `id` int(10) unsigned NOT NULL,
  `ordertype` varchar(75) NOT NULL DEFAULT '',
  `email_to` mediumtext DEFAULT NULL,
  `where_clause` mediumtext DEFAULT NULL,
  `attach` varchar(255) DEFAULT NULL,
  `email_cc` mediumtext DEFAULT NULL,
  `email_ci` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`,`ordertype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `process_forms_unpublished` (
  `form_id` varchar(36) NOT NULL,
  `process_name` varchar(50) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_on` datetime DEFAULT NULL,
  `updated_by` varchar(20) DEFAULT NULL,
  `is_email_cust` char(1) not null DEFAULT '0',
  `is_email_bk_ofc` char(1) not null DEFAULT '0',
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
  `btn_align` char(1) not null DEFAULT 'r',
  `label_display` char(3) not null DEFAULT 'tal',
  `form_width` char(10) DEFAULT '',
  `form_js` longtext DEFAULT NULL,
  `type` varchar(25) NOT NULL DEFAULT 'simple',
  `form_css` longtext DEFAULT NULL,
  `to_publish` tinyint(1) NOT NULL DEFAULT 0,
  `to_publish_by` int(11) DEFAULT NULL,
  `to_publish_ts` datetime DEFAULT NULL,
  `version` int(10) NOT NULL DEFAULT 0,
  `to_unpublish` tinyint(1) NOT NULL DEFAULT 0,
  `to_unpublish_by` int(11) DEFAULT NULL,
  `to_unpublish_ts` datetime DEFAULT NULL,
  PRIMARY KEY (`form_id`),
  UNIQUE KEY `process_name` (`process_name`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `process_form_descriptions_unpublished` (
  `form_id` varchar(36) NOT NULL,
  `langue_id` int(1) NOT NULL COMMENT 'language for which the resource was added',
  `page_path` varchar(500) NOT NULL DEFAULT '',
  `title` varchar(255) DEFAULT '',
  `success_msg` text DEFAULT NULL,
  `submit_btn_lbl` varchar(255) DEFAULT '',
  `cancel_btn_lbl` varchar(255) DEFAULT '',
  PRIMARY KEY (`form_id`,`langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `process_form_fields_unpublished` (
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_id` (`form_id`,`field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `process_form_field_descriptions_unpublished` (
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

CREATE TABLE  `process_form_lines_unpublished` (
  `id` varchar(36) NOT NULL,
  `form_id` varchar(36) NOT NULL,
  `line_id` varchar(50) DEFAULT '',
  `line_class` varchar(50) DEFAULT '',
  `line_width` char(10) DEFAULT '',
  `line_seq` char(10) DEFAULT '0',
  PRIMARY KEY (`form_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  `freq_rules_unpublished` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` varchar(50) NOT NULL DEFAULT '',
  `field_id` varchar(50) NOT NULL DEFAULT '',
  `frequency` varchar(50) NOT NULL DEFAULT '',
  `period` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;	

INSERT INTO form_result_fields_unpublished (id,form_id,field_id,display_order) SELECT id,form_id,field_id,display_order FROM form_result_fields;
INSERT INTO form_search_fields_unpublished (id,form_id,field_id,show_range,display_order) SELECT id,form_id,field_id,show_range,display_order FROM form_search_fields;
INSERT INTO mails_unpublished (id,sujet,de,type,attachs,seq,sujet_lang_2,sujet_lang_3,sujet_lang_4,sujet_lang_5,template_type) SELECT id,sujet,de,type,attachs,seq,sujet_lang_2,sujet_lang_3,sujet_lang_4,sujet_lang_5,template_type FROM mails;
INSERT INTO mail_config_unpublished (id,ordertype,email_to,where_clause,attach,email_cc,email_ci) SELECT id,ordertype,email_to,where_clause,attach,email_cc,email_ci FROM mail_config;
INSERT INTO process_forms_unpublished (form_id,process_name,table_name,created_by,created_on,updated_on,updated_by,is_email_cust,is_email_bk_ofc,cust_eid,bk_ofc_eid,site_id,variant,template,meta_description,meta_keywords,form_class,html_form_id,form_method,form_enctype,form_autocomplete,redirect_url,btn_align,label_display,form_width,form_js,type,form_css) SELECT form_id,process_name,table_name,created_by,created_on,updated_on,updated_by,is_email_cust,is_email_bk_ofc,cust_eid,bk_ofc_eid,site_id,variant,template,meta_description,meta_keywords,form_class,html_form_id,form_method,form_enctype,form_autocomplete,redirect_url,btn_align,label_display,form_width,form_js,type,form_css FROM process_forms;
INSERT INTO process_form_descriptions_unpublished (form_id,langue_id,page_path,title,success_msg,submit_btn_lbl,cancel_btn_lbl) SELECT form_id,langue_id,page_path,title,success_msg,submit_btn_lbl,cancel_btn_lbl FROM process_form_descriptions;
INSERT INTO process_form_fields_unpublished (id,form_id,field_id,seq_order,label_id,field_type,db_column_name,font_weight,font_size,color,name,maxlength,required,rule_field,add_no_of_days,start_time,end_time,time_slice,default_time_value,autocomplete_char_after,element_autocomplete_query,element_trigger,element_id,type,element_option_class,element_option_others,element_option_query,resizable_col_class,always_visible,regx_exp,group_of_fields,file_extension,img_width,img_height,img_alt,img_murl,href_chckbx,href_target,img_href_url,btn_id,container_bkcolor,text_align,text_border,site_key,theme,recaptcha_data_size,custom_css,line_id,min_range,max_range,step_range,img_url,default_country_code,allow_country_code,allow_national_mode,local_country_name,hidden,custom_classes,is_deletable,date_format,file_browser_val) SELECT id,form_id,field_id,seq_order,label_id,field_type,db_column_name,font_weight,font_size,color,name,maxlength,required,rule_field,add_no_of_days,start_time,end_time,time_slice,default_time_value,autocomplete_char_after,element_autocomplete_query,element_trigger,element_id,type,element_option_class,element_option_others,element_option_query,resizable_col_class,always_visible,regx_exp,group_of_fields,file_extension,img_width,img_height,img_alt,img_murl,href_chckbx,href_target,img_href_url,btn_id,container_bkcolor,text_align,text_border,site_key,theme,recaptcha_data_size,custom_css,line_id,min_range,max_range,step_range,img_url,default_country_code,allow_country_code,allow_national_mode,local_country_name,hidden,custom_classes,is_deletable,date_format,file_browser_val FROM process_form_fields;
INSERT INTO process_form_field_descriptions_unpublished (form_id,field_id,langue_id,label,placeholder,err_msg,value,options,option_query) SELECT form_id,field_id,langue_id,label,placeholder,err_msg,value,options,option_query FROM process_form_field_descriptions;
INSERT INTO process_form_lines_unpublished (id,form_id,line_id,line_class,line_width,line_seq) SELECT id,form_id,line_id,line_class,line_width,line_seq FROM process_form_lines;
INSERT INTO freq_rules_unpublished (id,form_id,field_id,frequency,period) SELECT id,form_id,field_id,frequency,period FROM freq_rules;

ALTER TABLE process_forms ADD COLUMN `to_publish` tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE process_forms ADD COLUMN `to_publish_by` int(11) DEFAULT NULL;
ALTER TABLE process_forms ADD COLUMN `to_publish_ts` datetime DEFAULT NULL;

ALTER TABLE process_forms ADD COLUMN `to_unpublish` tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE process_forms ADD COLUMN `to_unpublish_by` int(11) DEFAULT NULL;
ALTER TABLE process_forms ADD COLUMN `to_unpublish_ts` datetime DEFAULT NULL;

ALTER TABLE process_forms ADD COLUMN `version` int(10) NOT NULL DEFAULT 0;
