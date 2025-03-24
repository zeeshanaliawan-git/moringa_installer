
-------------------- MAHIN 19/06/23 --------------------
ALTER TABLE process_forms ADD delete_uploads Tinyint(1) not null default 1;
ALTER TABLE process_forms_unpublished_tbl ADD delete_uploads Tinyint(1) not null default 1;

DROP VIEW IF EXISTS process_forms_unpublished;

CREATE VIEW `process_forms_unpublished` AS
SELECT
    `process_forms_unpublished_tbl`.`form_id` AS `form_id`,
    `process_forms_unpublished_tbl`.`process_name` AS `process_name`,
    `process_forms_unpublished_tbl`.`table_name` AS `table_name`,
    `process_forms_unpublished_tbl`.`created_by` AS `created_by`,
    `process_forms_unpublished_tbl`.`created_on` AS `created_on`,
    `process_forms_unpublished_tbl`.`updated_on` AS `updated_on`,
    `process_forms_unpublished_tbl`.`updated_by` AS `updated_by`,
    `process_forms_unpublished_tbl`.`is_email_cust` AS `is_email_cust`,
    `process_forms_unpublished_tbl`.`is_email_bk_ofc` AS `is_email_bk_ofc`,
    `process_forms_unpublished_tbl`.`cust_eid` AS `cust_eid`,
    `process_forms_unpublished_tbl`.`bk_ofc_eid` AS `bk_ofc_eid`,
    `process_forms_unpublished_tbl`.`site_id` AS `site_id`,
    `process_forms_unpublished_tbl`.`variant` AS `variant`,
    `process_forms_unpublished_tbl`.`template` AS `template`,
    `process_forms_unpublished_tbl`.`meta_description` AS `meta_description`,
    `process_forms_unpublished_tbl`.`meta_keywords` AS `meta_keywords`,
    `process_forms_unpublished_tbl`.`form_class` AS `form_class`,
    `process_forms_unpublished_tbl`.`html_form_id` AS `html_form_id`,
    `process_forms_unpublished_tbl`.`form_method` AS `form_method`,
    `process_forms_unpublished_tbl`.`form_enctype` AS `form_enctype`,
    `process_forms_unpublished_tbl`.`form_autocomplete` AS `form_autocomplete`,
    `process_forms_unpublished_tbl`.`redirect_url` AS `redirect_url`,
    `process_forms_unpublished_tbl`.`btn_align` AS `btn_align`,
    `process_forms_unpublished_tbl`.`label_display` AS `label_display`,
    `process_forms_unpublished_tbl`.`form_width` AS `form_width`,
    `process_forms_unpublished_tbl`.`form_js` AS `form_js`,
    `process_forms_unpublished_tbl`.`type` AS `type`,
    `process_forms_unpublished_tbl`.`form_css` AS `form_css`,
    `process_forms_unpublished_tbl`.`to_publish` AS `to_publish`,
    `process_forms_unpublished_tbl`.`to_publish_by` AS `to_publish_by`,
    `process_forms_unpublished_tbl`.`to_publish_ts` AS `to_publish_ts`,
    `process_forms_unpublished_tbl`.`version` AS `version`,
    `process_forms_unpublished_tbl`.`to_unpublish` AS `to_unpublish`,
    `process_forms_unpublished_tbl`.`to_unpublish_by` AS `to_unpublish_by`,
    `process_forms_unpublished_tbl`.`to_unpublish_ts` AS `to_unpublish_ts`,
    `process_forms_unpublished_tbl`.`is_deleted` AS `is_deleted`,
    `process_forms_unpublished_tbl`.`is_sms` AS `is_sms`,
    `process_forms_unpublished_tbl`.`cust_sms_id` AS `cust_sms_id`,
    `process_forms_unpublished_tbl`.`delete_uploads` AS `delete_uploads`
FROM
    `process_forms_unpublished_tbl`
WHERE
    `process_forms_unpublished_tbl`.`is_deleted` = 0;

------------------------------------------------------------------------------------------------