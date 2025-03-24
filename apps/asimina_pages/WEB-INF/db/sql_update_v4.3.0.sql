--------------- Ahsan Start 19 July 2023 ---------------
insert into page (name,url,rang,icon) values ('Global Information','/dev_pages/admin/globalData.jsp',1003,'globe');
insert into config (code,val) values ('CUSTOM_ERROR_PAGE','/home/etn/.nginx_asimina/');

        ------  Add default language id depending upon site, same for insert query ------
alter table libraries_files add column lang_id int(11) not null default 1;
INSERT INTO libraries_files (SELECT library_id,file_id,page_position,sort_order,2 FROM libraries_files  WHERE lang_id=1);
                        ------ Till Here ------
ALTER TABLE libraries_files DROP PRIMARY KEY;
ALTER TABLE libraries_files ADD PRIMARY KEY (library_id, file_id, lang_id);


ALTER TABLE files_tbl
ADD COLUMN description TEXT,
ADD COLUMN alt_name VARCHAR(300),
ADD COLUMN removal_date DATE,
ADD COLUMN thumbnail varchar(100);

DROP VIEW IF EXISTS files;
CREATE VIEW files AS SELECT * FROM files_tbl WHERE is_deleted = 0;

CREATE TABLE media_tags (
    id INT(11) AUTO_INCREMENT NOT NULL,
    file_id INT(11) NOT NULL,
    tag VARCHAR(100),
    PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


--------------- Ahsan End 9 August 2023 ---------------


alter table structured_contents_tbl modify name varchar(255) not null;
alter table structured_contents_published modify name varchar(255) not null;


--------------- Mahin & Ahsan Start 29 August 2023 ---------------

CREATE TABLE bloc_template_description (     
    id INT PRIMARY KEY AUTO_INCREMENT,     
    bloc_template_id INT NOT NULL,     
    description TEXT,     
    image_info VARCHAR(255)
) ENGINE=MYISAM DEFAULT CHARSET=utf8mb3;

------------ in js code data will be [["trigger","JS code"],["trigger2","JS code2"]]
CREATE TABLE section_field_advance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    entity_id INT(11) NOT NULL,
    entity_type ENUM('section', 'field') NOT NULL,
    display TINYINT(1) NOT NULL DEFAULT 1,
    unique_type ENUM('none', 'custom', 'auto') NOT NULL DEFAULT 'none',
    modifiable ENUM('always', 'create', 'never') NOT NULL DEFAULT 'always',
    reg_exp varchar(100),
    css_code TEXT,
    js_code TEXT,
    unique key (entity_id,entity_type)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO section_field_advance (entity_id,entity_type) SELECT id,'field' FROM sections_fields;
INSERT INTO section_field_advance (entity_id,entity_type) SELECT id,'section' FROM bloc_templates_sections;

alter table bloc_templates_sections add column is_collapse tinyint(1) not null default 1, add column description text;

------------ aspect ratio will be in value column for image and query text in case of is_query for both free and other.
------------ in case of free query text in value and in case of other ["id,val","query"]
ALTER TABLE sections_fields
ADD COLUMN description TEXT,
ADD COLUMN select_type ENUM('select', 'search') NOT NULL DEFAULT 'select',
ADD COLUMN is_query TINYINT(1) DEFAULT 0,
ADD COLUMN query_type ENUM('free', 'catalog', 'content', 'page', 'data', 'blocs');
ALTER TABLE blocs ADD COLUMN `unique_id` varchar(250) DEFAULT NULL;

ALTER TABLE structured_contents_tbl ADD COLUMN `unique_id` varchar(250) DEFAULT NULL;
drop view structured_contents;
create view structured_contents as select * from structured_contents_tbl where is_deleted = 0;
--------------- Mahin & Ahsan End 15 Sep 2023 ---------------


-- umair
insert into config (code, val) value ('allow_domains_load_menu', '');
