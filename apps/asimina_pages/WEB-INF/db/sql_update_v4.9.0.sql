
 /* Added by Awais For Templates Multilang */
CREATE TABLE bloc_template_description_backup_09_07_2024 AS
SELECT *
FROM bloc_template_description;

TRUNCATE TABLE bloc_template_description;

ALTER TABLE bloc_template_description
ADD COLUMN lang_id INT(11) AFTER bloc_template_id;

INSERT INTO bloc_template_description (bloc_template_id, lang_id, description, image_info)
SELECT 
    bt.id,
    sl.langue_id,
    btd.description,
    btd.image_info
FROM 
    bloc_template_description_backup_09_07_2024 btd
JOIN 
    bloc_templates bt ON btd.bloc_template_id = bt.id
JOIN 
    dev_commons.sites_langs sl ON bt.site_id = sl.site_id;

 /* Ended */

/* Added by Awais For Tag Moving and Replacing */
 CREATE TABLE tags_history (
    id INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    lang_id INT(11) NOT NULL,
    item_id INT(11) NOT NULL,
    item_type VARCHAR(50) NOT NULL,
    old_data mediumtext NOT NULL,
    new_data mediumtext NOT NULL,
    updated_by INT(11) NOT NULL,
    created_ts DATETIME NOT NULL
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

---------------Ahsan Start 5 Aug 2024---------------
alter table sections_fields add column field_specific_data text not null default '{}';
alter table products_map_pages modify column product_id varchar(100);

create table structure_mappings(
    id int(11) not null auto_increment,
    lang_page_id int(11) not null,
    bloc_id int(11) not null,
    primary key (id)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;


create table bloc_tree (
    parent_bloc_id int(11) not null,
    bloc_id int(11) NOT NULL,
    langue_id int(1) unsigned not null,
	primary key (parent_bloc_id, bloc_id, langue_id)	
) ENGINE=MYISAM DEFAULT CHARSET=utf8;
