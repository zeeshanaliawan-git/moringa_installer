ALTER TABLE pages
ADD COLUMN dl_page_type   varchar(200) NOT NULL DEFAULT '' AFTER template_id,
ADD COLUMN dl_sub_level_1 varchar(200) NOT NULL DEFAULT '' AFTER dl_page_type,
ADD COLUMN dl_sub_level_2 varchar(200) NOT NULL DEFAULT '' AFTER dl_sub_level_1;

ALTER TABLE structured_contents_details
MODIFY COLUMN content_data mediumtext NOT NULL;

ALTER TABLE structured_contents_details_published
MODIFY COLUMN content_data mediumtext NOT NULL;

ALTER TABLE bloc_templates
MODIFY COLUMN css_code mediumtext NOT NULL,
MODIFY COLUMN js_code mediumtext NOT NULL;

ALTER TABLE pages
MODIFY COLUMN dynamic_html mediumtext NOT NULL;

ALTER TABLE rss_feeds
MODIFY COLUMN ch_extra_params mediumtext NOT NULL COMMENT 'extra param-values stored as JSON';

ALTER TABLE rss_feeds_items
MODIFY COLUMN description mediumtext NOT NULL,
MODIFY COLUMN extra_params mediumtext  COMMENT 'extra param-values stored as JSON';

ALTER TABLE sections_fields
MODIFY COLUMN value mediumtext NOT NULL,
MODIFY COLUMN default_value mediumtext NOT NULL;

-- 2020-06-07
CREATE TABLE pages_forms (
  page_id int(11) unsigned NOT NULL,
  form_id varchar(36) NOT NULL,
  sort_order int(2) unsigned NOT NULL,
  PRIMARY KEY (page_id,form_id,sort_order)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
