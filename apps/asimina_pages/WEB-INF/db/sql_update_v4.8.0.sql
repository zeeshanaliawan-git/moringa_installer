------------- Start Ahsan 30 May 2024 -------------

ALTER TABLE bloc_templates_tbl MODIFY COLUMN type ENUM('block','feed_view','structured_content','structured_page','store','menu','simple_product','simple_virtual_product','configurable_product','configurable_virtual_product');
DROP VIEW IF EXISTS bloc_templates;
CREATE VIEW bloc_templates AS SELECT * FROM bloc_templates_tbl WHERE is_deleted = 0;

ALTER TABLE bloc_templates_sections ADD COLUMN is_new_product_item TINYINT(1) DEFAULT 0;
ALTER TABLE sections_fields ADD COLUMN is_new_product_item TINYINT(1) DEFAULT 0;

CREATE TABLE template_reserved_ids (
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    uuid VARCHAR(36) NOT NULL DEFAULT UUID(),
    template_type ENUM('configurable_product','simple_product') NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    item_id VARCHAR(50) NOT NULL
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

INSERT INTO template_reserved_ids (template_type,item_type, item_id) VALUES 
('configurable_product','section','main_information'),
('configurable_product','section','product_general_informations'),
('configurable_product','section','product_main_informations'),
('configurable_product','section','product_variants'),
('configurable_product','section','product_variants_variant_x'),
('configurable_product','section','product_variants_variant_x_specifications'),
('configurable_product','field','system_product_name'),
('configurable_product','field','product_id'),
('configurable_product','field','product_general_informations_product_id'),
('configurable_product','field','product_general_informations_manufacturer'),
('configurable_product','field','product_general_informations_short_description'),
('configurable_product','field','product_general_informations_long_description'),
('configurable_product','field','product_general_informations_image'),
('configurable_product','field','product_general_informations_tags'),
('configurable_product','field','product_variants_variant_x_id'),
('configurable_product','field','product_variants_variant_x_name'),
('configurable_product','field','product_variants_variant_x_ean'),
('configurable_product','field','product_variants_variant_x_sku'),
('configurable_product','field','product_variants_variant_x_price_price'),
('configurable_product','field','product_variants_variant_x_price_frequency'),
('configurable_product','field','product_variants_variant_x_price_display'),
('configurable_product','field','product_variants_variant_x_short_description'),
('configurable_product','field','product_variants_variant_x_long_description'),
('configurable_product','field','product_variants_variant_x_attributes'),
('configurable_product','field','product_variants_variant_x_image'),
('configurable_product','field','product_variants_variant_x_tags'),
('configurable_product','field','product_variants_variant_x_specifications_x_spec'),
('simple_product','section','product_main_informations'),
('simple_product','section','product_general_informations'),
('simple_product','section','product_specifications'),
('simple_product','field','system_product_name'),
('simple_product','field','product_id'),
('simple_product','field','product_general_informations_product_id'),
('simple_product','field','product_general_informations_variant_id'),
('simple_product','field','product_general_informations_ean'),
('simple_product','field','product_general_informations_sku'),
('simple_product','field','product_general_informations_manufacturer'),
('simple_product','field','product_general_informations_price_price'),
('simple_product','field','product_general_informations_price_frequency'),
('simple_product','field','product_general_informations_price_display'),
('simple_product','field','product_general_informations_short_description'),
('simple_product','field','product_general_informations_long_description'),
('simple_product','field','product_general_informations_image'),
('simple_product','field','product_general_informations_tags'),
('simple_product','field','product_attributes'),
('simple_product','field','product_specifications_x_spec');

alter table structured_contents_tbl add column structured_version varchar(10) not null default 'V1';
DROP VIEW IF EXISTS structured_contents;
CREATE VIEW structured_contents AS SELECT * FROM structured_contents_tbl WHERE is_deleted = 0;

alter table pages_tbl add column page_version varchar(10) not null default 'V1';
DROP VIEW IF EXISTS pages;
CREATE VIEW pages AS SELECT * FROM pages_tbl WHERE is_deleted = 0;

alter table folders_tbl add column folder_version varchar(10) not null default 'V1';
DROP VIEW IF EXISTS folders;
CREATE VIEW folders AS SELECT * FROM folders_tbl WHERE is_deleted = 0;

DROP VIEW IF EXISTS pages_folders;
CREATE VIEW pages_folders AS SELECT * FROM folders WHERE TYPE='pages';

DROP VIEW IF EXISTS stores_folders;
CREATE VIEW stores_folders AS SELECT * FROM folders WHERE TYPE='stores';

DROP VIEW IF EXISTS structured_contents_folders;
CREATE VIEW structured_contents_folders AS SELECT * FROM folders WHERE TYPE='contents';

CREATE TABLE products_map_pages(
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    product_id int(11) not null,
    page_id int(11) not null,
    UNIQUE KEY `uk_ref_product_page` (`product_id`,`page_id`)
)ENGINE=MYISAM DEFAULT CHARSET=utf8;

alter table bloc_templates_sections add index idx_tempalte_id (`bloc_template_id`);
------------- End Ahsan 5 July 2024 -------------


ALTER TABLE blocs ADD COLUMN triggers MEDIUMTEXT;

alter table sections_fields add index idx1(section_id, custom_id);


alter table partoo_services_work add index idx1 (services_id);

alter table structured_contents_published drop index idx_site_id;
alter table structured_contents_published add index idx1 (site_id, uuid);
alter table structured_contents_details add index idx2 (page_id);

ALTER TABLE partoo_contents MODIFY COLUMN ctype ENUM('store','folder','section'), ADD COLUMN group_id INT(11);
