-- START 04-02-2021 --
CREATE TABLE blocs_details (
    id            int(11) unsigned NOT NULL AUTO_INCREMENT,
    bloc_id       int(11) unsigned NOT NULL,
    langue_id     int(1) unsigned NOT NULL,
    template_data mediumtext NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY bloc_lang (bloc_id, langue_id)
) ENGINE = MyISAM DEFAULT CHARSET = utf8;

INSERT IGNORE INTO blocs_details(bloc_id, langue_id, template_data)
SELECT b.id AS bloc_id, l.langue_id, b.template_data
FROM blocs b, language l
order by b.id, l.langue_id;

ALTER TABLE blocs
CHANGE COLUMN template_data template_data_old mediumtext NOT NULL DEFAULT '';

-- END 04-02-2021 --

CREATE TABLE `sections_fields_details` (
  `field_id` int(11) unsigned NOT NULL,
  `langue_id` int(2) unsigned NOT NULL,
  `default_value` mediumtext NOT NULL,
  `placeholder` varchar(500) NOT NULL DEFAULT '',
  PRIMARY KEY (`field_id`, `langue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into sections_fields_details (field_id, langue_id, default_value, placeholder)
select sf.id, l.langue_id, sf.default_value, sf.placeholder from sections_fields sf join language l;

create table sections_fields_v3_1_bkup as select * from sections_fields;

alter table sections_fields drop default_value;

alter table sections_fields drop placeholder;
-- Start 17-2-2022 --
ALTER TABLE sections_fields
ADD COLUMN is_meta_variable  tinyint(1) NOT NULL DEFAULT 0 AFTER is_indexed;
-- End 17-2-2022 --

-- START 21-02-2021 --

CREATE TABLE page_templates_items_blocs_bk_menusmigration
SELECT * FROM page_templates_items_blocs;

CREATE TABLE menu_js_details_bk_menusmigration
SELECT * FROM menu_js_details;

-- END 21-02-2021 --

-- These are added for expert system v2 otherwise its json breaks always ---
alter table structured_contents_details drop fd_content_data_3;

alter table structured_contents_details add fd_content_data_3 mediumtext as (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(content_data,'#slash#/', '/'), '#slash#n',''),'#slash#"',''''), '#slash#t',''),'#slash#','\\')) persistent;

alter table structured_contents_details_published add fd_content_data_3 mediumtext;

update structured_contents_details_published a inner join structured_contents_details b on b.id  = a.id and b.content_id = a.content_id and b.langue_id = a.langue_id set a.fd_content_data_3 = b.fd_content_data_3;


create table page_templates_items_blocs_v3_1_bkup as select * from page_templates_items_blocs;
