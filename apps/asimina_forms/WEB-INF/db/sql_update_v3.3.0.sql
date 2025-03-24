drop view page;
create view page as select * from dev_catalog.page;

ALTER TABLE dev_forms.process_forms_unpublished RENAME TO process_forms_unpublished_tbl;
ALTER TABLE dev_forms.process_forms_unpublished_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_forms.process_forms_unpublished AS SELECT * FROM process_forms_unpublished_tbl WHERE is_deleted =0;

ALTER TABLE dev_forms.process_forms ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;

---- Start 4/5/2022 Ahsan ----
CREATE TABLE original_forms_names (
  id INT NOT NULL AUTO_INCREMENT,
  site_id INT NOT NULL,
  table_name varchar(255) NOT NULL,
  table_new_name varchar(255) NOT NULL,
  created_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

---- End 4/5/2022 Ahsan ----