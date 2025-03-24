---------------------start 24/5/2022 Ahsan--------------------------
create table batch_imports(
	id int NOT NULL AUTO_INCREMENT,
	batch_id varchar(100) not null,
	name varchar(100),
	site_id varchar(100),
	status enum('waiting','processing','loaded','importing','imported','import error','ignored','load error') DEFAULT 'waiting',
	info text,
	message	text,
	created_ts timestamp NOT NULL DEFAULT current_timestamp(),
	created_by int(11) DEFAULT NULL,
	updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP(),
	is_deleted TinyInt(1) NOT NULL DEFAULT 0,
	deleted_by int(11) DEFAULT NULL,
	PRIMARY KEY (id)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;

create table batch_imports_items(
	id int NOT NULL AUTO_INCREMENT,
	batch_table_id varchar(36) not null,
	site_id varchar(100),
	name varchar(100),
	item_id varchar(100),
	type varchar(100),
	error varchar(100),
	status varchar(100),
	process enum('validated','import','importing','imported','import error','ignored','load error') DEFAULT 'validated',
	item_data MEDIUMTEXT,
	created_on timestamp NOT NULL DEFAULT current_timestamp(),
	is_deleted TinyInt(1) NOT NULL DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (batch_table_id) REFERENCES batch_imports(id)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;


ALTER TABLE dev_pages.freemarker_pages RENAME TO dev_pages.freemarker_pages_tbl;
ALTER TABLE dev_pages.freemarker_pages_tbl ADD deleted_by Int(11) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.freemarker_pages AS SELECT * FROM dev_pages.freemarker_pages_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.structured_contents RENAME TO dev_pages.structured_contents_tbl;
ALTER TABLE dev_pages.structured_contents_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_pages.structured_contents_tbl ADD deleted_by Int(11) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.structured_contents AS SELECT * FROM dev_pages.structured_contents_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.pages RENAME TO dev_pages.pages_tbl;
ALTER TABLE dev_pages.pages_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_pages.pages_tbl ADD deleted_by Int(11) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.pages AS SELECT * FROM dev_pages.pages_tbl WHERE is_deleted =0;

ALTER TABLE dev_pages.folders RENAME TO dev_pages.folders_tbl;
ALTER TABLE dev_pages.folders_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_pages.folders_tbl ADD deleted_by Int(11) NOT NULL DEFAULT 0;
CREATE VIEW dev_pages.folders AS SELECT * FROM dev_pages.folders_tbl WHERE is_deleted =0;

DROP VIEW dev_pages.structured_contents_folders;
CREATE VIEW dev_pages.structured_contents_folders AS SELECT * FROM dev_pages.folders where type = 'contents';

DROP VIEW dev_pages.stores_folders;
CREATE VIEW dev_pages.stores_folders AS SELECT * FROM dev_pages.folders where type = 'stores';

DROP VIEW dev_pages.pages_folders;
CREATE VIEW dev_pages.pages_folders AS SELECT * FROM dev_pages.folders where type = 'pages';

ALTER TABLE files_tbl DROP INDEX uk_files_name_type;
ALTER TABLE files_tbl ADD CONSTRAINT uk_files_name_type UNIQUE (is_deleted,site_id,file_name,type);

ALTER TABLE folders_tbl DROP INDEX uk_folders;
ALTER TABLE folders_tbl ADD CONSTRAINT uk_folders UNIQUE (is_deleted,site_id,`type`,parent_folder_id,name);

ALTER TABLE pages_tbl DROP INDEX uk_pages_path_variant_lang_folder;
ALTER TABLE pages_tbl ADD CONSTRAINT uk_pages_path_variant_lang_folder UNIQUE (`is_deleted`,`site_id`,`path`,`variant`,`langue_code`,`folder_id`);

INSERT INTO config (CODE,val) VALUES('TRASH_FOLDER','trash/');

INSERT INTO dev_commons.config (CODE,val, comments) VALUES('TRASH_FOLDER','/home/etn/temp/asimina/trash/', 'This should be outside webapps');

ALTER TABLE page_templates_tbl DROP INDEX uk_page_template_custom_id;
ALTER TABLE page_templates_tbl ADD CONSTRAINT uk_page_template_custom_id UNIQUE (`is_deleted`,`site_id`,`custom_id`);
---------------------End 6/6/2022 Ahsan--------------------------

drop view pages_blocs;
CREATE VIEW pages_blocs AS 
SELECT p.id as page_id, ppb.bloc_id, ppb.sort_order, ppb.type
FROM freemarker_pages bp
LEFT JOIN pages p  ON p.parent_page_id = bp.id AND p.type = 'freemarker'
JOIN parent_pages_blocs ppb ON ppb.type = 'freemarker' and ppb.page_id = bp.id
UNION
SELECT scd.page_id , ppb.bloc_id, ppb.sort_order, ppb.type
FROM structured_contents sc
JOIN structured_contents_details scd ON scd.content_id  = sc.id
JOIN parent_pages_blocs ppb ON ppb.type = 'structured' and ppb.page_id = sc.id
WHERE sc.type = 'page';


drop view pages_forms;
CREATE VIEW pages_forms AS 
SELECT p.id as page_id, ppf.form_id, ppf.sort_order, ppf.type
FROM freemarker_pages bp
JOIN pages p ON p.parent_page_id = bp.id AND p.type = 'freemarker'
JOIN parent_pages_forms ppf ON ppf.type = 'freemarker' and ppf.page_id = bp.id
UNION
SELECT scd.page_id , ppf.form_id, ppf.sort_order, ppf.type
FROM structured_contents sc
JOIN structured_contents_details scd ON scd.content_id  = sc.id
JOIN parent_pages_forms ppf ON ppf.type = 'structured' and ppf.page_id = sc.id
WHERE sc.type = 'page';


ALTER TABLE dev_pages.structured_contents_published ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
ALTER TABLE dev_pages.structured_contents_published ADD deleted_by Int(11) NOT NULL DEFAULT 0;

alter table pages_tbl add index idxPpId (parent_page_id);