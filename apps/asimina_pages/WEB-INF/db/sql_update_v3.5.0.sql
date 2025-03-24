-----------------Start 20 June 2022 Ahsan------------------
ALTER TABLE bloc_templates_tbl ADD CONSTRAINT uk_blocs_name UNIQUE (`is_deleted`,`site_id`,`custom_id`);
ALTER TABLE libraries_tbl ADD CONSTRAINT uk_library_name UNIQUE (`is_deleted`,`site_id`,`name`);
ALTER TABLE freemarker_pages_tbl ADD CONSTRAINT uk_freemarker_name UNIQUE (`is_deleted`,`site_id`,`folder_id`,`name`);
delete from config where code='TRASH_FOLDER';
-----------------End 20 June 2022 Ahsan------------------

-- start 27 Jun 2022 --
ALTER TABLE bloc_templates_libraries
    ADD COLUMN id int(11) NOT NULL AUTO_INCREMENT AFTER bloc_template_id,
DROP PRIMARY KEY,
ADD PRIMARY KEY (id);
-- end 27 Jun 2022 --

-- start 4 JUL 2022 ---
DROP TABLE IF EXISTS variables;
CREATE TABLE variables  (
       id int(11) NOT NULL AUTO_INCREMENT,
       name varchar(500) NOT NULL,
       value varchar(500) NOT NULL,
       site_id int(11) NOT NULL,
       created_ts datetime(0) NOT NULL,
       created_by int(11) NOT NULL,
       is_editable tinyint(1) NOT NULL DEFAULT 1,
       PRIMARY KEY (id)
) ENGINE=MyISAM default charset=utf8;

INSERT INTO dev_catalog.page (name, url, parent, rang, new_tab, icon, parent_icon) VALUES ('Variables', '/dev_pages/admin/variables.jsp', 'Developer', '836', '0', 'chevron-right', 'layout');
-- end 4 JUL 2022 --
